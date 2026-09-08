import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/hub_config.dart';

/// Client minimo del Gamification Hub (F7, offline-first).
///
/// Contratto (vedi `docs/assignment/hub_setup.md`):
/// - Auth: `POST /auth {username, password, origin: "GAME"}` → Bearer 24h.
/// - Eventi: `POST /executions {gameId, playerId, actionId, data}` con
///   `data` sempre presente (anche `{}`) e chiavi snake_case.
///
/// Errori MAI propagati: [login] e [execute] ritornano `bool`, loggano con
/// [debugPrint] (mai `print`) e non lanciano mai. Così i flussi locali
/// (XP, badge, save) non possono rompersi se l'Hub è irraggiungibile.
abstract class EngineClient {
  /// Invia un evento best-effort; true se accettato dall'Hub.
  Future<bool> execute({
    required String actionId,
    required String playerId,
    Map<String, dynamic> data = const {},
  });

  /// Classifica XP (`overall_xp`): lista ordinata per posizione.
  /// Ritorna lista vuota su qualsiasi errore/offline, mai throw.
  Future<List<LeaderboardEntry>> getLeaderboard();

  /// Stato giocatore: XP, livelli, badge. Ritorna null in caso di errore.
  Future<Map<String, dynamic>?> getPlayerState(String playerId);
}

/// Riga della classifica XP dell'Hub (Fase 1B-D).
///
/// Shape API: `GET /games/{gameId}/classifications/overall_xp/board` →
/// `{board: {content: [{position, playerId, score}]}}`.
@immutable
class LeaderboardEntry {
  final int position;
  final String playerId;
  final int score;

  const LeaderboardEntry({
    required this.position,
    required this.playerId,
    required this.score,
  });

  /// Parsing tollerante: chiavi mancanti → valori di default (mai throw).
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    int asInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawPlayer = json['playerId'] ?? json['player_id'] ?? '';
    return LeaderboardEntry(
      position: asInt(json['position']),
      playerId: rawPlayer is String ? rawPlayer : '$rawPlayer',
      score: asInt(json['score']),
    );
  }

  /// Estrae la lista tollerando le forme `{board:{content:[...]}}`,
  /// `{content:[...]}` e lista nuda (mai throw).
  static List<LeaderboardEntry> parseBoard(Object? decoded) {
    try {
      Object? content = decoded;
      if (content is Map<String, dynamic>) {
        final board = content['board'];
        if (board is Map<String, dynamic>) {
          content = board['content'];
        } else {
          content = content['content'] ?? content['board'];
        }
      }
      if (content is! List) return const [];
      return content
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntry.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Implementazione HTTP di [EngineClient] con `http.Client` iniettabile.
///
/// Senza credenziali (`--dart-define=HUB_USER/HUB_PASS` assenti) resta offline:
/// [login]/[execute] ritornano subito false senza toccare la rete.
class HttpEngineClient implements EngineClient {
  final http.Client _client;
  final String baseUrl;
  final String gameId;
  final String classification;
  final String username;
  final String password;

  String? _token;

  HttpEngineClient({
    http.Client? client,
    this.baseUrl = HubConfig.baseUrl,
    this.gameId = HubConfig.gameId,
    this.classification = HubConfig.overallXpClassification,
    this.username = const String.fromEnvironment('HUB_USER', defaultValue: ''),
    this.password = const String.fromEnvironment('HUB_PASS', defaultValue: ''),
  }) : _client = client ?? http.Client();

  /// True quando mancano le credenziali: nessuna chiamata di rete.
  bool get isOffline => username.isEmpty || password.isEmpty;

  /// Login a runtime (token Bearer 24h); re-login trasparente se chiamato
  /// di nuovo. Ritorna false (mai throw) se offline o in caso di errore.
  Future<bool> login() async {
    if (isOffline) return false;
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'origin': 'GAME',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Hub login fallito: HTTP ${response.statusCode}');
        return false;
      }
      final token = _extractToken(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (token == null || token.isEmpty) {
        debugPrint('Hub login fallito: token assente nella risposta');
        return false;
      }
      _token = token;
      return true;
    } on TimeoutException {
      debugPrint('Hub login fallito: timeout');
      return false;
    } catch (e) {
      debugPrint('Hub login fallito: $e');
      return false;
    }
  }

  @override
  Future<bool> execute({
    required String actionId,
    required String playerId,
    Map<String, dynamic> data = const {},
  }) async {
    if (isOffline) return false;
    try {
      if (_token == null && !await login()) return false;
      var ok = await _postExecution(actionId, playerId, data);
      if (!ok) {
        // Token scaduto (24h) o 401: un re-login trasparente + un retry.
        _token = null;
        if (!await login()) return false;
        ok = await _postExecution(actionId, playerId, data);
      }
      return ok;
    } catch (e) {
      debugPrint('Hub execute($actionId) fallito: $e');
      return false;
    }
  }

  /// Classifica XP `overall_xp` (Fase 1B-D): GET board con Bearer.
  /// Lista vuota su offline o qualsiasi errore, mai throw.
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    if (isOffline) return const [];
    try {
      if (_token == null && !await login()) return const [];
      var board = await _getBoard();
      if (board == null) {
        // Token scaduto (24h) o 401: un re-login trasparente + un retry.
        _token = null;
        if (!await login()) return const [];
        board = await _getBoard();
      }
      if (board == null) return const [];
      return LeaderboardEntry.parseBoard(board);
    } catch (e) {
      debugPrint('Hub getLeaderboard fallito: $e');
      return const [];
    }
  }

  /// GET board grezzo (decoded JSON) o null in caso di errore/401.
  Future<Object?> _getBoard() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/games/$gameId/classifications/$classification/board'),
            headers: {'Authorization': 'Bearer $_token'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 401) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Hub getLeaderboard HTTP ${response.statusCode}');
        return null;
      }
      return jsonDecode(response.body);
    } on TimeoutException {
      debugPrint('Hub getLeaderboard fallito: timeout');
      return null;
    } catch (e) {
      debugPrint('Hub getLeaderboard fallito: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPlayerState(String playerId) async {
    if (isOffline || playerId.isEmpty) return null;
    try {
      if (_token == null && !await login()) return null;
      var state = await _getPlayerStateImpl(playerId);
      if (state == null) {
        _token = null;
        if (!await login()) return null;
        state = await _getPlayerStateImpl(playerId);
      }
      return state;
    } catch (e) {
      debugPrint('Hub getPlayerState fallito: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getPlayerStateImpl(String playerId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/games/$gameId/players/$playerId'),
            headers: {'Authorization': 'Bearer $_token'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 401) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Hub getPlayerState HTTP ${response.statusCode}');
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _postExecution(
    String actionId,
    String playerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/executions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: jsonEncode({
              'gameId': gameId,
              'playerId': playerId,
              'actionId': actionId,
              'data': data,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      if (!ok) {
        debugPrint('Hub execute($actionId) HTTP ${response.statusCode}');
      }
      return ok;
    } on TimeoutException {
      debugPrint('Hub execute($actionId) fallito: timeout');
      return false;
    } catch (e) {
      debugPrint('Hub execute($actionId) fallito: $e');
      return false;
    }
  }

  /// Estrae il token tollerando le forme comuni (`token`, `accessToken`,
  /// `access_token`, anche annidato in `data`).
  static String? _extractToken(Map<String, dynamic> json) {
    for (final key in ['token', 'accessToken', 'access_token']) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) return _extractToken(data);
    return null;
  }
}

/// Fake no-op di [EngineClient] (sempre successo): fallback offline e
/// test del cablaggio senza rete. Registra le chiamate per le asserzioni.
/// [leaderboardSeed] alimenta [getLeaderboard] nei test (default vuota).
class FakeEngineClient implements EngineClient {
  /// Esito simulato di [execute] (default true = successo).
  bool result;

  /// Eventi inviati: `{actionId, playerId, data}`.
  final List<Map<String, dynamic>> calls = [];

  /// Righe simulate della classifica (Fase 1B-D).
  final List<LeaderboardEntry> leaderboardSeed;

  FakeEngineClient({this.result = true, List<LeaderboardEntry>? leaderboardSeed})
      : leaderboardSeed = List.unmodifiable(leaderboardSeed ?? const []);

  @override
  Future<bool> execute({
    required String actionId,
    required String playerId,
    Map<String, dynamic> data = const {},
  }) async {
    calls.add({
      'actionId': actionId,
      'playerId': playerId,
      'data': Map<String, dynamic>.from(data),
    });
    return result;
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async =>
      List<LeaderboardEntry>.unmodifiable(leaderboardSeed);

  @override
  Future<Map<String, dynamic>?> getPlayerState(String playerId) async => null;
}
