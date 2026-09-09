/// Config pubblica del Gamification Hub (F7).
///
/// Contiene SOLO valori non sensibili: [baseUrl] e [gameId] sono pubblici
/// per design (il gameId viaggia in ogni payload `/executions`).
/// Le credenziali di login arrivano via `--dart-define=HUB_USER/HUB_PASS`
/// (mai nel repo): senza, l'app resta offline-first.
abstract final class HubConfig {
  /// Base URL delle API (senza trailing slash).
  static const String baseUrl =
      'https://gamification-api.createlab-univaq.it/api/v1';

  /// Game "Slay The Code" (owner `slay`), creato da console.
  static const String gameId = '6a9dbf66cc89679981fe7893';

  /// Action inviate dall'app (contratto in `docs/assignment/hub_setup.md`).
  /// Specchio 1:1 delle fonti XP locali (scelta B): punteggio Hub = XP app.
  static const String quizCompletedAction = 'quiz_completed';
  static const String claimRewardAction = 'claim_reward';
  static const String bossDefeatedAction = 'boss_defeated';
  static const String topicCompletedAction = 'topic_completed';
  static const String resourceViewedAction = 'resource_viewed';
  static const String dungeonClearedAction = 'dungeon_cleared';
  static const String dailyLoginAction = 'daily_login';

  /// XP assegnati dall'Hub per ogni quiz passato (soglie livello locali
  /// in `PlayerProgress.levelThresholds`: curva 10 livelli
  /// 0/100/500/1000/1600/2300/3100/4000/5000/6100, uguale all'Hub).
  static const int quizXpAmount = 100;

  /// XP specchio delle altre fonti locali (single source per i payload Hub;
  /// i numeri locali restano nei loro punti di assegnazione, invariati).
  static const int topicCompletedXp = 50;
  static const int resourceViewedXp = 30;
  static const int dungeonClearedXp = 200;
  static const int dailyLoginXp = 25;
  static const String overallXpClassification = 'overall_xp';
}
