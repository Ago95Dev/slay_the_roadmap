import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _progressKey = 'dart_quest_progress';

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progress);
      await prefs.setString(_progressKey, jsonString);
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  Future<Map<String, dynamic>?> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);
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
      await prefs.remove(_progressKey);
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
    await prefs.setString('user_pwd_$username', password);
  }

  Future<bool> checkLocalUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPwd = prefs.getString('user_pwd_$username');
    return savedPwd == password;
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
