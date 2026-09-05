import '../../domain/models/player_progress.dart';

abstract class PersistenceRepository {
  Future<void> savePlayerProgress(PlayerProgress progress);
  Future<PlayerProgress> loadPlayerProgress();
  Future<void> resetProgress();
}
