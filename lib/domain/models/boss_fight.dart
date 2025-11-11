/// BossFight domain model.
/// Represents a boss fight: enemies, conditions, rewards and related logic.
class BossFight {
  final String id;
  final String chapterId;
  final int bossMaxHp;
  final int currentBossHp;
  final List<Reward> playerDeck;
  final BossFightState state;
  final List<Quiz> adaptiveQuizzes;

  BossFight({
    required this.id,
    required this.chapterId,
    required this.bossMaxHp,
    required this.currentBossHp,
    required this.playerDeck,
    required this.state,
    this.adaptiveQuizzes = const [],
  });
}

enum BossFightState { notStarted, playerTurn, bossTurn, victory, defeat }
