import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/repositories/persistence_repository.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/player_progress.dart';
import '../../domain/models/reward.dart';

/// Store globale condiviso del giocatore (F3, US-03; F5, US-05).
///
/// Tiene un'istanza condivisa di [PlayerProgress] (prima nessuno la
/// possedeva) e il set dei topic per cui la reward è già stata riscattata
/// (limite 1 reward/topic).
///
/// Se [persistence] è fornita, ogni mutazione viene salvata in automatico
/// (fire-and-forget); [load]/[wipe] gestiscono restore e reset manuale.
class PlayerViewModel with ChangeNotifier {
  final PersistenceRepository? _persistence;
  PlayerProgress _progress;
  final Set<String> _claimedRewardTopics = {};

  PlayerViewModel({
    PlayerProgress? initialProgress,
    Set<String>? claimedTopics,
    PersistenceRepository? persistence,
  })  : _progress = initialProgress ?? PlayerProgress.initial(),
        _persistence = persistence {
    if (claimedTopics != null) _claimedRewardTopics.addAll(claimedTopics);
  }

  PlayerProgress get progress => _progress;
  PlayerInventory get inventory => _progress.inventory;
  Set<String> get claimedRewardTopics =>
      Set.unmodifiable(_claimedRewardTopics);

  bool isTopicClaimed(String topicId) =>
      _claimedRewardTopics.contains(topicId);

  bool get isInventoryFull => !inventory.hasEmptySlots;

  /// True se esiste un progresso da continuare (topic completati, XP,
  /// reward, boss o claim).
  bool get hasProgress =>
      _progress.completedTopicIds.isNotEmpty ||
      _claimedRewardTopics.isNotEmpty ||
      _progress.experience > 0 ||
      _progress.inventory.rewards.isNotEmpty ||
      _progress.bossFights.isNotEmpty;

  bool canClaim(String topicId) =>
      !isTopicClaimed(topicId) && !isInventoryFull;

  /// Riscatta [reward] per [topicId].
  /// Ritorna false (e ignora) se il topic ha già riscosso o se
  /// l'inventario è pieno.
  bool claimReward(String topicId, Reward reward) {
    if (isTopicClaimed(topicId)) return false;
    if (isInventoryFull) return false;
    _progress = _progress.addReward(reward.copyWith(isSelected: true));
    _claimedRewardTopics.add(topicId);
    _autosave();
    notifyListeners();
    return true;
  }

  /// Delega a [PlayerProgress.addCompletedTopic] (+100xp).
  void addCompletedTopic(String topicId) {
    _progress = _progress.addCompletedTopic(topicId);
    _autosave();
    notifyListeners();
  }

  bool isBossDefeated(String bossId) =>
      _progress.bossFights.containsKey(bossId);

  /// Registra la vittoria contro [boss].
  /// Ritorna true solo alla prima vittoria (unica a dare +100 XP);
  /// le vittorie successive aggiornano il fight ma senza XP.
  /// Non assegna reward: il claim passa da [claimReward] via
  /// RewardChoiceScreen (topicId = bossId).
  bool recordBossVictory(BossFight boss) {
    final isFirst = !isBossDefeated(boss.id);
    final victorious = boss.copyWith(state: BossFightState.victory);
    _progress = _progress.copyWith(
      bossFights: {..._progress.bossFights, boss.id: victorious},
      experience: isFirst ? _progress.experience + 100 : _progress.experience,
    );
    _autosave();
    notifyListeners();
    return isFirst;
  }

  /// Ripristina il save da [persistence]; ritorna false se assente.
  Future<bool> load() async {
    final persistence = _persistence;
    if (persistence == null) return false;
    final saved = await persistence.loadPlayerProgress();
    if (saved == null) return false;
    _progress = saved;
    _claimedRewardTopics
      ..clear()
      ..addAll(await persistence.loadClaimedRewardTopics());
    notifyListeners();
    return true;
  }

  /// Azzera progresso + claim e cancella il save (Nuovo percorso / Reset).
  Future<void> wipe() async {
    _progress = PlayerProgress.initial();
    _claimedRewardTopics.clear();
    await _persistence?.resetProgress();
    notifyListeners();
  }

  void _autosave() {
    final persistence = _persistence;
    if (persistence == null) return;
    unawaited(persistence.savePlayerProgress(_progress));
    unawaited(
      persistence.saveClaimedRewardTopics(_claimedRewardTopics),
    );
  }
}
