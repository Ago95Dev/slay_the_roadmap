import '../../domain/models/player_progress.dart';

/// Contratto di persistenza del save (F5, US-05).
///
/// Il save vive sotto la chiave `slay_save_v1` (globale legacy) oppure
/// `slay_save_v1_<username>` per utente (Fase 3) come JSON di
/// `{progress, completedTopicIds, claimedRewardTopics}`; `completedTopicIds`
/// è ridondante (vive già in [PlayerProgress]) ma tenuto per letture veloci
/// e debug del save.
abstract class PersistenceRepository {
  Future<void> savePlayerProgress(PlayerProgress progress);
  Future<PlayerProgress?> loadPlayerProgress();
  Future<void> resetProgress();

  /// Set dei topic per cui la reward è già stata riscattata (limite 1/topic).
  Future<void> saveClaimedRewardTopics(Set<String> topicIds);
  Future<Set<String>> loadClaimedRewardTopics();

  /// True se esiste un save non vuoto.
  Future<bool> hasSave();
}
