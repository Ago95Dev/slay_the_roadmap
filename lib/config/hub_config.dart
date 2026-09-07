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
  static const String quizCompletedAction = 'quiz_completed';
  static const String claimRewardAction = 'claim_reward';
  static const String bossDefeatedAction = 'boss_defeated';

  /// XP assegnati dall'Hub per ogni quiz passato (soglie livello locali
  /// in `PlayerProgress`: L1 0 / L2 100 / L3 500, uguali all'Hub).
  static const int quizXpAmount = 100;
  static const String overallXpClassification = 'overall_xp';
}
