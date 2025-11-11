/// Shared preferences service.
/// Wrapper over SharedPreferences for simple key/value storage used in the app.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/player_progress.dart';
import '../repositories/persistence_repository.dart';

class SharedPreferencesService implements PersistenceRepository {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  @override
  Future<void> savePlayerProgress(PlayerProgress progress) async {
    final json = progress.toJson();
    await _prefs.setString('player_progress', jsonEncode(json));
  }

  @override
  Future<PlayerProgress> loadPlayerProgress() async {
    final jsonString = _prefs.getString('player_progress');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return PlayerProgress.fromJson(json);
    }
    return PlayerProgress.initial();
  }

  @override
  Future<void> resetProgress() async {
    await _prefs.remove('player_progress');
  }
}
