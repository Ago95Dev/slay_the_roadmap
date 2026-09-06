import 'dart:async';

import 'package:flutter/material.dart';
import '../../config/hub.dart';
import '../../data/repositories/persistence_repository.dart';
import '../../data/services/engine_client.dart';
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

  /// Hub best-effort (F7): null = offline, flussi locali invariati.
  EngineClient? _engine;

  /// playerId stabile `slay_<...>`; fallback: `progress.playerId`.
  String _hubPlayerId = '';

  PlayerViewModel({
    PlayerProgress? initialProgress,
    Set<String>? claimedTopics,
    PersistenceRepository? persistence,
    EngineClient? engine,
    String hubPlayerId = '',
  })  : _progress = initialProgress ?? PlayerProgress.initial(),
        _persistence = persistence,
        _engine = engine,
        _hubPlayerId = hubPlayerId {
    if (claimedTopics != null) _claimedRewardTopics.addAll(claimedTopics);
  }

  /// Collega l'Hub dopo la costruzione (bootstrap in `main`).
  void attachEngine(EngineClient engine, {String hubPlayerId = ''}) {
    _engine = engine;
    _hubPlayerId = hubPlayerId;
  }

  String get _effectiveHubPlayerId =>
      _hubPlayerId.isNotEmpty ? _hubPlayerId : _progress.playerId;

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
  /// Ritorna true se l'XP ha fatto scattare un level-up (il chiamante
  /// mostra il dialog "Livello N raggiunto!" una sola volta).
  /// Chiamato solo a quiz passato (verifica in `TopicDetailScreen`): invia
  /// best-effort `quiz_completed {xp_amount:100, badge:topicId}` all'Hub,
  /// mai bloccante, mai un fallimento locale.
  ///
  /// Effetti serie/vite (GamiDOC/Toda): streak +1, +1 vita fino a max 3,
  /// bonus +25 XP a ogni multiplo di 3 (il chiamante mostra
  /// "Serie xN! +25 XP").
  bool addCompletedTopic(String topicId) {
    final before = _progress.level;
    final newStreak = _progress.streak + 1;
    final newLives = (_progress.lives + 1).clamp(0, PlayerProgress.maxLives);
    final bonus =
        newStreak % PlayerProgress.streakBonusEvery == 0 ? PlayerProgress.streakBonusXp : 0;
    final updated = _progress.addCompletedTopic(topicId).copyWith(
          streak: newStreak,
          lives: newLives,
          experience: _progress.experience + 100 + bonus,
        );
    _progress = updated;
    _autosave();
    notifyListeners();
    unawaited(
      _engine?.execute(
        actionId: HubConfig.quizCompletedAction,
        playerId: _effectiveHubPlayerId,
        data: {'xp_amount': HubConfig.quizXpAmount, 'badge': topicId},
      ),
    );
    return _progress.level > before;
  }

  /// Quiz topic fallito: azzera la serie (streak 0). Le vite non cambiano.
  void recordQuizFail() {
    if (_progress.streak == 0) return;
    _progress = _progress.copyWith(streak: 0);
    _autosave();
    notifyListeners();
  }

  /// Sconfitta boss: -1 vita (min 0). Ritorna le vite rimaste.
  int recordBossDefeat() {
    final remaining = (_progress.lives - 1).clamp(0, PlayerProgress.maxLives);
    _progress = _progress.copyWith(lives: remaining);
    _autosave();
    notifyListeners();
    return remaining;
  }

  /// Ingresso boss bloccato a 0 vite.
  bool get canEnterBoss => _progress.lives > 0;

  bool isBossDefeated(String bossId) =>
      _progress.bossFights.containsKey(bossId);

  /// Registra la vittoria contro [boss].
  /// Ritorna true solo alla prima vittoria (unica a dare +100 XP);
  /// le vittorie successive aggiornano il fight ma senza XP.
  /// Non assegna reward: il claim passa da [claimReward] via
  /// RewardChoiceScreen (topicId = bossId).
  /// Solo alla prima vittoria invia best-effort `boss_defeated
  /// {badge:bossId}` all'Hub, mai bloccante, mai un fallimento locale.
  bool recordBossVictory(BossFight boss) {
    final isFirst = !isBossDefeated(boss.id);
    final victorious = boss.copyWith(state: BossFightState.victory);
    _progress = _progress.copyWith(
      bossFights: {..._progress.bossFights, boss.id: victorious},
      experience: isFirst ? _progress.experience + 100 : _progress.experience,
    );
    _autosave();
    notifyListeners();
    if (isFirst) {
      unawaited(
        _engine?.execute(
          actionId: HubConfig.bossDefeatedAction,
          playerId: _effectiveHubPlayerId,
          data: {'badge': boss.id},
        ),
      );
    }
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
