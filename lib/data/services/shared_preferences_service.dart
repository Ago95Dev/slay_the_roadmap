import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/player_progress.dart';
import '../repositories/persistence_repository.dart';

class SharedPreferencesService implements PersistenceRepository {
  final SharedPreferences _prefs;
  static const String _progressKey = 'player_progress';

  SharedPreferencesService(this._prefs);

  @override
  Future<void> savePlayerProgress(PlayerProgress progress) async {
    try {
      final json = progress.toJson();
      await _prefs.setString(_progressKey, jsonEncode(json));
      print('Progress saved successfully');
    } catch (e) {
      print('Error saving progress: $e');
      throw Exception('Failed to save progress');
    }
  }

  @override
  Future<PlayerProgress> loadPlayerProgress() async {
    try {
      final jsonString = _prefs.getString(_progressKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return PlayerProgress.fromJson(json);
      }
      print('No saved progress found, returning initial progress');
      return PlayerProgress.initial();
    } catch (e) {
      print('Error loading progress: $e');
      return PlayerProgress.initial();
    }
  }

  @override
  Future<void> resetProgress() async {
    try {
      await _prefs.remove(_progressKey);
      print('Progress reset successfully');
    } catch (e) {
      print('Error resetting progress: $e');
      throw Exception('Failed to reset progress');
    }
  }
}
