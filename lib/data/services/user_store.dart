import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/player_progress.dart';
import '../../domain/models/user_profile.dart';
import 'shared_preferences_persistence.dart';

/// Store dei profili locali + login/registrazione (F10, prototype-grade).
///
/// - Indice utenti in [indexKey], un record `slay_profile_<id>` per utente,
///   un save `slay_data_<id>` per utente (stesso formato del legacy).
/// - Password: hash FNV-1a 32-bit con salt, solo verifica in locale.
///   NON è sicurezza reale (niente PBKDF2/bcrypt, niente rate limiting):
///   va bene per sbloccare un save sul proprio device, dichiarato come
///   prototype nel GamiDOC. Niente dipendenze extra (solo `dart:convert`).
/// - Migrazione una-tantum: il vecchio `slay_save_v1` viene copiato tale
///   e quale in `slay_data_<id>` di un utente "Giocatore" al primo avvio;
///   dopo di che `slay_save_v1` è ignorato (mai più letto né scritto).
class UserStore {
  static const String indexKey = 'slay_users_index';
  static const String activeKey = 'slay_users_active';
  static const String migratedKey = 'slay_users_migrated';
  static const String migratedDefaultName = 'Giocatore';

  final SharedPreferences prefs;

  UserStore(this.prefs);

  static String profileKey(String userId) => 'slay_profile_$userId';

  // ---------------------------------------------------------------- hash

  /// Hash FNV-1a 32-bit di `salt:password` (hex, 8 cifre).
  ///
  /// Scelta prototype documentata: veloce da calcolare e senza
  /// dipendenze, ma NON resistente a brute-force (niente stretching,
  /// niente memoria-hard). Non riusare per nulla di remoto.
  static String hashPassword(String salt, String password) {
    var hash = 0x811c9dc5;
    const prime = 0x01000193;
    for (final byte in utf8.encode('$salt:$password')) {
      hash ^= byte;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String _newSalt(String username) =>
      '${DateTime.now().microsecondsSinceEpoch}_${username.hashCode}';

  static String _newUserId(int count) =>
      'u_${DateTime.now().millisecondsSinceEpoch}_$count';

  // -------------------------------------------------------------- lettura

  List<String> listUserIds() =>
      List<String>.from(prefs.getStringList(indexKey) ?? const []);

  /// Tutti i profili registrati (record corrotti saltati in silenzio).
  List<UserProfile> listUsers() {
    final out = <UserProfile>[];
    for (final id in listUserIds()) {
      final raw = prefs.getString(profileKey(id));
      if (raw == null || raw.isEmpty) continue;
      try {
        out.add(UserProfile.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map)));
      } on Exception {
        continue;
      }
    }
    return out;
  }

  /// Cerca per nome (case-insensitive, spazi trimmirati), null se assente.
  UserProfile? findByName(String username) {
    final needle = username.trim().toLowerCase();
    for (final profile in listUsers()) {
      if (profile.displayName.toLowerCase() == needle) return profile;
    }
    return null;
  }

  UserProfile? activeUser() {
    final id = prefs.getString(activeKey);
    if (id == null || id.isEmpty) return null;
    final raw = prefs.getString(profileKey(id));
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } on Exception {
      return null;
    }
  }

  Future<void> setActive(UserProfile? profile) async {
    if (profile == null) {
      await prefs.remove(activeKey);
    } else {
      await prefs.setString(activeKey, profile.userId);
    }
  }

  Future<void> logout() => setActive(null);

  /// Persistenza del save isolato del profilo [userId].
  SharedPreferencesPersistence dataFor(String userId) =>
      SharedPreferencesPersistence.forUser(prefs, userId);

  // ------------------------------------------------------- registrazione

  /// Registra un nuovo profilo e lo rende attivo. Lancia [StateError] se
  /// lo username è vuoto o già preso (confronto case-insensitive) o se
  /// la password è vuota.
  Future<UserProfile> register({
    required String username,
    required String password,
  }) async {
    final name = username.trim();
    if (name.isEmpty) {
      throw StateError('Scegli un nome utente non vuoto.');
    }
    if (password.isEmpty) {
      throw StateError('Scegli una password non vuota.');
    }
    if (findByName(name) != null) {
      throw StateError('Nome "$name" già in uso: scegli un altro nome.');
    }
    final userId = _newUserId(listUserIds().length);
    final salt = _newSalt(name);
    final profile = UserProfile(
      userId: userId,
      displayName: name,
      passwordSalt: salt,
      passwordHash: hashPassword(salt, password),
      createdAt: DateTime.now(),
    );
    await prefs.setString(profileKey(userId), jsonEncode(profile.toJson()));
    await prefs.setStringList(indexKey, [...listUserIds(), userId]);
    // Save fresco per-utente (nome = displayName).
    await dataFor(userId).savePlayerProgress(
      PlayerProgress.initial().copyWith(playerName: name),
    );
    await setActive(profile);
    return profile;
  }

  /// Login locale: ritorna il profilo e lo rende attivo, null se utente
  /// sconosciuto o password errata. Il profilo migrato (senza password)
  /// accede con qualsiasi password (solo sblocco locale).
  Future<UserProfile?> login({
    required String username,
    required String password,
  }) async {
    final profile = findByName(username);
    if (profile == null) return null;
    if (profile.hasPassword &&
        hashPassword(profile.passwordSalt, password) !=
            profile.passwordHash) {
      return null;
    }
    await setActive(profile);
    return profile;
  }

  // ------------------------------------------------------------ migrazione

  /// Migrazione una-tantum dal save singolo (F10): copia byte-identica
  /// di `slay_save_v1` in `slay_data_<id>` di un nuovo utente
  /// "Giocatore" (senza password) e lo rende attivo. Ritorna il profilo
  /// creato, null se già migrato o se nessun save legacy esiste.
  /// Dopo questa chiamata `slay_save_v1` è ignorato per sempre.
  Future<UserProfile?> migrateLegacyIfNeeded() async {
    if (prefs.getBool(migratedKey) == true) return null;
    await prefs.setBool(migratedKey, true);
    if (listUserIds().isNotEmpty) return null;
    final raw = prefs.getString(SharedPreferencesPersistence.saveKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      jsonDecode(raw);
    } on Exception {
      return null;
    }
    var name = migratedDefaultName;
    var suffix = 2;
    while (findByName(name) != null) {
      name = '$migratedDefaultName $suffix';
      suffix++;
    }
    final userId = _newUserId(0);
    final profile = UserProfile(
      userId: userId,
      displayName: name,
      createdAt: DateTime.now(),
    );
    await prefs.setString(profileKey(userId), jsonEncode(profile.toJson()));
    await prefs.setStringList(indexKey, [userId]);
    await prefs.setString(
        SharedPreferencesPersistence.dataKey(userId), raw);
    await setActive(profile);
    return profile;
  }
}
