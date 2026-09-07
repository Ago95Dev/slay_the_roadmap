import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/campaign.dart';

/// Identità stabile del giocatore sull'Hub (F7, F11).
///
/// Un player Hub per coppia (utente, campagna) → `slay_<userId>_<campaignId>`
/// (disegno utenti_campagne_hub §2): XP/badge/leaderboard remoti sono già
/// per-utente e per-campagna senza cambi Hub. Il vecchio id globale
/// `slay_<timestamp>` ([key]) resta solo per compatibilità coi test F7.
abstract final class HubIdentity {
  static const String key = 'slay_hub_player_id';
  static const String prefix = 'slay_';

  /// Nuovo id mai usato altrove (solo per test/generazione).
  static String newId() =>
      '$prefix${DateTime.now().millisecondsSinceEpoch}'
      '${DateTime.now().microsecond % 1000}';

  /// Carica l'id salvato o lo crea e lo persiste (sempre non-vuoto).
  static Future<String> loadOrCreate(SharedPreferences prefs) async {
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = newId();
    await prefs.setString(key, id);
    return id;
  }

  /// playerId Hub della coppia (utente, campagna), mai vuoto.
  static String playerIdFor(String userId,
      [String? campaignId]) =>
      '$prefix${userId}_${campaignId ?? CampaignRepository.webFoundationsId}';
}
