import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class StorageService {
  static const String _progressKey = 'dart_quest_progress';

  Future<String> _getProgressKey() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('current_user');
    if (user != null && user.isNotEmpty) {
      return '${_progressKey}_$user';
    }
    return _progressKey;
  }

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progress);
      final key = await _getProgressKey();
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  Future<Map<String, dynamic>?> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getProgressKey();
      final jsonString = prefs.getString(key);
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
      final key = await _getProgressKey();
      await prefs.remove(key);
    } catch (e) {
      print('Failed to reset progress: $e');
    }
  }

  // --- Auth & Profile ---
  Future<bool> checkUserExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_pwd_$username');
  }

  Future<void> saveLocalUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes).toString();
    await prefs.setString('user_pwd_$username', hash);
  }

  Future<bool> checkLocalUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPwd = prefs.getString('user_pwd_$username');
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes).toString();
    return savedPwd == hash || savedPwd == password; // Fallback for old unhashed passwords
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
