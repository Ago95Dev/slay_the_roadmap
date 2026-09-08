import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/player_progress.dart';
import '../repositories/persistence_repository.dart';

/// Implementazione [PersistenceRepository] su `shared_preferences` (F5, US-05).
///
/// Tutto il save vive sotto la singola chiave [saveKey] come JSON di
/// `{progress, completedTopicIds, claimedRewardTopics}`.
class SharedPreferencesPersistence implements PersistenceRepository {
  static const String saveKey = 'slay_save_v1';

  /// Chiave del save per utente (Fase 3): globale oppure
  /// `slay_save_v1_<username>` quando loggato.
  static String saveKeyForUser(String? username) {
    if (username == null || username.isEmpty) return saveKey;
    return '${saveKey}_$username';
  }

  final SharedPreferences? _overrides;

  /// Utente proprietario del save (`null` = globale legacy). Usare
  /// [forUser] per lo scope per-utente (Fase 3).
  final String? username;

  /// Chiave effettiva di questo repository (per-utente o globale).
  String get effectiveSaveKey => saveKeyForUser(username);

  /// [_overrides] serve solo ai test (istanza già pronta, niente platform
  /// channel); in app usare il costruttore senza argomenti.
  SharedPreferencesPersistence([this._overrides, this.username]);

  /// Scope per-utente (Fase 3): stesso envelope, chiave dedicata.
  factory SharedPreferencesPersistence.forUser(
    SharedPreferences prefs,
    String? username,
  ) =>
      SharedPreferencesPersistence(prefs, username);

  Future<SharedPreferences> get _prefs async =>
      _overrides ?? await SharedPreferences.getInstance();

  @override
  Future<void> savePlayerProgress(PlayerProgress progress) async {
    final prefs = await _prefs;
    final raw = prefs.getString(effectiveSaveKey);
    final claimed = raw == null
        ? <String>[]
        : List<String>.from(
            (jsonDecode(raw) as Map<String, dynamic>)['claimedRewardTopics']
                    as List? ??
                const [],
          );
    await _write(prefs, progress, claimed.toSet());
  }

  @override
  Future<PlayerProgress?> loadPlayerProgress() async {
    final envelope = await _readEnvelope();
    if (envelope == null) return null;
    try {
      return PlayerProgress.fromJson(
        Map<String, dynamic>.from(envelope['progress'] as Map),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> resetProgress() async {
    final prefs = await _prefs;
    await prefs.remove(effectiveSaveKey);
  }

  @override
  Future<void> saveClaimedRewardTopics(Set<String> topicIds) async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    PlayerProgress? progress;
    if (envelope != null) {
      try {
        progress = PlayerProgress.fromJson(
          Map<String, dynamic>.from(envelope['progress'] as Map),
        );
      } on Exception {
        progress = null;
      }
    }
    progress ??= PlayerProgress.initial();
    await _write(prefs, progress, topicIds);
  }

  @override
  Future<Set<String>> loadClaimedRewardTopics() async {
    final envelope = await _readEnvelope();
    if (envelope == null) return {};
    final list = (envelope['claimedRewardTopics'] as List?) ?? const [];
    return List<String>.from(list).toSet();
  }

  @override
  Future<bool> hasSave() async {
    final prefs = await _prefs;
    final raw = prefs.getString(effectiveSaveKey);
    if (raw == null || raw.isEmpty) return false;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final progress = Map<String, dynamic>.from(envelope['progress'] as Map);
      final completed =
          List<String>.from(progress['completedTopicIds'] as List? ?? const []);
      final claimed =
          List<String>.from(envelope['claimedRewardTopics'] as List? ?? const []);
      final xp = (progress['experience'] as num?)?.toInt() ?? 0;
      final rewards =
          ((progress['inventory'] as Map?)?['rewards'] as List?) ?? const [];
      final bosses = (progress['bossFights'] as Map?) ?? const {};
      return completed.isNotEmpty ||
          claimed.isNotEmpty ||
          xp > 0 ||
          rewards.isNotEmpty ||
          bosses.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _readEnvelope() async {
    final prefs = await _prefs;
    final raw = prefs.getString(effectiveSaveKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Exception {
      return null;
    }
  }

  Future<void> _write(
    SharedPreferences prefs,
    PlayerProgress progress,
    Set<String> claimed,
  ) async {
    final envelope = {
      'progress': progress.toJson(),
      'completedTopicIds': progress.completedTopicIds,
      'claimedRewardTopics': claimed.toList(),
    };
    await prefs.setString(effectiveSaveKey, jsonEncode(envelope));
  }
}
