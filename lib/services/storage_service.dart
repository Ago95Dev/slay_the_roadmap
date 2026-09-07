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
}
