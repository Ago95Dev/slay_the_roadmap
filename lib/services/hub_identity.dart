import 'package:shared_preferences/shared_preferences.dart';

/// Identità stabile del giocatore sull'Hub (F7).
///
/// `playerId` libero `slay_<timestamp_ms>` generato una sola volta e salvato
/// in SharedPreferences (chiave [key]); auto-creato al primo avvio e poi
/// riusato per ogni evento. Niente dipendenze extra (id DateTime-based).
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
}
