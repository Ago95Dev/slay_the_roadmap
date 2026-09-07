import 'dart:async';

import 'package:flutter/material.dart';
import '../../config/hub.dart';
import '../../data/repositories/persistence_repository.dart';
import '../../data/services/engine_client.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/campaign_lore.dart';
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
  /// XP del bonus giornaliero (Fase 1B-E, locale, una-tantum al giorno).
  static const int dailyRewardXp = 25;

  /// Data odierna in formato `yyyy-MM-dd` (zero-padded, ora locale).
  static String dailyDateString(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

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

  /// playerId Hub effettivo (Fase 1B-D): usato per evidenziare "Tu".
  String get hubPlayerId => _effectiveHubPlayerId;

  /// Engine collegato (null = offline). Mai usato per logica locale.
  EngineClient? get engine => _engine;

  /// True quando la classifica non è consultabile (Fase 1B-D):
  /// nessun engine oppure [HttpEngineClient] senza credenziali.
  bool get isLeaderboardOffline {
    final engine = _engine;
    if (engine == null) return true;
    if (engine is HttpEngineClient) return engine.isOffline;
    return false;
  }

  /// Classifica XP best-effort (Fase 1B-D): lista vuota su offline/errore,
  /// mai throw (garantito da [EngineClient.getLeaderboard]).
  Future<List<LeaderboardEntry>> fetchLeaderboard() {
    final engine = _engine;
    if (engine == null) return Future.value(const <LeaderboardEntry>[]);
    return engine.getLeaderboard();
  }

  PlayerProgress get progress => _progress;
  PlayerInventory get inventory => _progress.inventory;
  Set<String> get claimedRewardTopics =>
      Set.unmodifiable(_claimedRewardTopics);

  bool isTopicClaimed(String topicId) =>
      _claimedRewardTopics.contains(topicId);

  bool get isInventoryFull => !inventory.hasEmptySlots;

  /// True se esiste un progresso da continuare (topic completati, XP,
  /// reward, boss, claim, intro viste o finale mostrato).
  bool get hasProgress =>
      _progress.completedTopicIds.isNotEmpty ||
      _claimedRewardTopics.isNotEmpty ||
      _progress.experience > 0 ||
      _progress.inventory.rewards.isNotEmpty ||
      _progress.bossFights.isNotEmpty ||
      _progress.seenChapterIntros.isNotEmpty ||
      _progress.campaignCompletionSeen ||
      _progress.activeTitle.isNotEmpty ||
      _progress.avatarIconIndex != 0 ||
      _progress.avatarFrameIndex != 0;

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
          maxStreak:
              newStreak > _progress.maxStreak ? newStreak : _progress.maxStreak,
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

  /// Intro capitolo già mostrata in questo save (Fase 1B-A).
  bool hasSeenChapterIntro(String chapterId) =>
      _progress.seenChapterIntros.contains(chapterId);

  /// Segna l'intro del capitolo come mostrata (una-tantum per save).
  void markChapterIntroSeen(String chapterId) {
    if (hasSeenChapterIntro(chapterId)) return;
    _progress = _progress.copyWith(
      seenChapterIntros: [..._progress.seenChapterIntros, chapterId],
    );
    _autosave();
    notifyListeners();
  }

  /// Finale campagna già mostrato per questo completamento (Fase 1B-A).
  bool get hasSeenCampaignCompletion => _progress.campaignCompletionSeen;

  /// Segna il finale come mostrato (una volta per completamento).
  void markCampaignCompletionSeen() {
    if (_progress.campaignCompletionSeen) return;
    _progress = _progress.copyWith(campaignCompletionSeen: true);
    _autosave();
    notifyListeners();
  }

  /// Titolo capitolo (Fase 1B-B): assegnato solo a capitolo interamente
  /// completato ([chapterComplete]) E boss sconfitto ([bossDefeated]).
  /// L'ultimo titolo vinto diventa attivo (sovrascrive il precedente).
  /// Ritorna true solo se un nuovo titolo è stato assegnato.
  bool checkAndAwardChapterTitle(
    String chapterId, {
    required bool chapterComplete,
    required bool bossDefeated,
  }) {
    if (!chapterComplete || !bossDefeated) return false;
    final title = chapterTitles[chapterId];
    if (title == null || title.isEmpty) return false;
    if (_progress.activeTitle == title) return false;
    _progress = _progress.copyWith(activeTitle: title);
    _autosave();
    notifyListeners();
    return true;
  }

  /// Scorta per boss: risolve il capitolo da [bossId] e assegna il
  /// titolo se [chapterComplete] è true e il boss risulta sconfitto.
  bool checkAndAwardTitleForBoss(
    String bossId, {
    required bool chapterComplete,
  }) {
    final chapterId = chapterIdForBossId(bossId);
    if (chapterId == null) return false;
    return checkAndAwardChapterTitle(
      chapterId,
      chapterComplete: chapterComplete,
      bossDefeated: isBossDefeated(bossId),
    );
  }

  /// Avatar (Fase 1B-B): indici clampati alle opzioni disponibili.
  void setAvatar({int? iconIndex, int? frameIndex}) {
    final icons = PlayerProgress.avatarIcons.length;
    final frames = PlayerProgress.avatarFrameColorValues.length;
    final nextIcon =
        (iconIndex ?? _progress.avatarIconIndex).clamp(0, icons - 1);
    final nextFrame =
        (frameIndex ?? _progress.avatarFrameIndex).clamp(0, frames - 1);
    if (nextIcon == _progress.avatarIconIndex &&
        nextFrame == _progress.avatarFrameIndex) {
      return;
    }
    _progress = _progress.copyWith(
      avatarIconIndex: nextIcon,
      avatarFrameIndex: nextFrame,
    );
    _autosave();
    notifyListeners();
  }

  /// True se la ricompensa giornaliera è ancora da riscattare oggi
  /// (Fase 1B-E, locale): oggi != [PlayerProgress.lastDailyClaim].
  bool get isDailyRewardAvailable =>
      _progress.lastDailyClaim != dailyDateString(DateTime.now());

  /// Riscatta il bonus giornaliero (+[dailyRewardXp] XP, una sola volta
  /// al giorno). Ritorna true al primo claim del giorno, false se già
  /// riscattata oggi (nessun XP). Il [now] opzionale serve solo ai test.
  bool claimDailyReward({DateTime? now}) {
    final today = dailyDateString(now ?? DateTime.now());
    if (_progress.lastDailyClaim == today) return false;
    _progress = _progress.copyWith(
      experience: _progress.experience + dailyRewardXp,
      lastDailyClaim: today,
    );
    _autosave();
    notifyListeners();
    return true;
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
  /// L'identità (nome/id) è conservata: il reset cancella i progressi di
  /// gioco, non il profilo (F10: il nome resta quello dell'utente attivo).
  Future<void> wipe() async {
    final name = _progress.playerName;
    final id = _progress.playerId;
    _progress = PlayerProgress.initial()
        .copyWith(playerName: name, playerId: id);
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
