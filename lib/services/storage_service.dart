import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class StorageService {
  static const String _progressKey = 'dart_quest_progress';

  /// Chiave del save per utente: globale (legacy/anonimo) oppure
  /// `dart_quest_progress_<username>` quando loggato (Fase 3).
  static String progressKeyForUser(String? username) {
    if (username == null || username.isEmpty) return _progressKey;
    return '${_progressKey}_$username';
  }

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = progressKeyForUser(prefs.getString('current_user'));
      final jsonString = jsonEncode(progress);
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  /// Variante esplicita per utente (test / reload mirato).
  Future<void> saveProgressForUser(
    String? username,
    Map<String, dynamic> progress,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progress);
      await prefs.setString(progressKeyForUser(username), jsonString);
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  Future<Map<String, dynamic>?> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = progressKeyForUser(prefs.getString('current_user'));
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to load progress: $e');
    }
    return null;
  }

  /// Variante esplicita per utente (test / reload mirato).
  Future<Map<String, dynamic>?> loadProgressForUser(String? username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(progressKeyForUser(username));
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to load progress: $e');
    }
    return null;
  }

  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = progressKeyForUser(prefs.getString('current_user'));
      await prefs.remove(key);
    } catch (e) {
      print('Failed to reset progress: $e');
    }
  }

  /// Reset mirato di un utente (test / wipe selettivo).
  Future<void> resetProgressForUser(String? username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(progressKeyForUser(username));
    } catch (e) {
      print('Failed to reset progress: $e');
    }
  }

  // --- Auth & Profile (Fase 3: hash salato v2 + migrazione v1) ---

  static String _v1Key(String username) => 'user_pwd_$username';
  static String _v2Key(String username) => 'user_pwd_v2_$username';

  /// `salt$sha256(salt+password)`: salt esadecimale da 16 byte random.
  static String hashWithSalt(String saltHex, String password) {
    return sha256.convert(utf8.encode('$saltHex$password')).toString();
  }

  static String generateSaltHex([int lengthBytes = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(lengthBytes, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<bool> checkUserExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_v2Key(username)) ||
        prefs.containsKey(_v1Key(username));
  }

  Future<void> saveLocalUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = generateSaltHex();
    final hash = hashWithSalt(salt, password);
    await prefs.setString(_v2Key(username), '$salt\$$hash');
    // Il legacy v1 non deve sopravvivere accanto al v2.
    await prefs.remove(_v1Key(username));
  }

  Future<bool> checkLocalUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final v2 = prefs.getString(_v2Key(username));
    if (v2 != null) {
      // Solo v2: nessun fallback permanente al plaintext/v1.
      final sep = v2.indexOf(r'$');
      if (sep <= 0) return false;
      final salt = v2.substring(0, sep);
      final expected = v2.substring(sep + 1);
      if (salt.isEmpty || expected.isEmpty) return false;
      return hashWithSalt(salt, password) == expected;
    }
    // Migrazione una tantum dal legacy v1 (hash non salato o plaintext):
    // al primo login riuscito si re-hash in v2 e si cancella v1.
    final v1 = prefs.getString(_v1Key(username));
    if (v1 == null) return false;
    final v1hash = sha256.convert(utf8.encode(password)).toString();
    if (v1 == v1hash || v1 == password) {
      final salt = generateSaltHex();
      final hash = hashWithSalt(salt, password);
      await prefs.setString(_v2Key(username), '$salt\$$hash');
      await prefs.remove(_v1Key(username));
      return true;
    }
    return false;
  }

  Future<void> saveCurrentUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', username);
  }

  Future<String?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
}
