import 'package:equatable/equatable.dart';
import 'quiz.dart';
import 'reward.dart';

enum BossFightState { notStarted, playerTurn, bossTurn, victory, defeat }
enum BossActionType { normalAttack, specialAttack, heal, statusEffect }

class BossFight extends Equatable {
  final String id;
  final String chapterId;
  final String name;
  final int maxHp;
  final int currentHp;
  final int maxPlayerHp;
  final int currentPlayerHp;
  final List<Reward> playerDeck;
  final List<Reward> availableRewards;
  final BossFightState state;
  final List<Quiz> adaptiveQuizzes;
  final int currentTurn;
  final String lastAction;

  const BossFight({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.maxHp,
    required this.currentHp,
    this.maxPlayerHp = 100,
    this.currentPlayerHp = 100,
    this.playerDeck = const [],
    this.availableRewards = const [],
    this.state = BossFightState.notStarted,
    this.adaptiveQuizzes = const [],
    this.currentTurn = 0,
    this.lastAction = '',
  });

  double get bossHpPercentage => currentHp / maxHp;
  double get playerHpPercentage => currentPlayerHp / maxPlayerHp;

  bool get isBossDefeated => currentHp <= 0;
  bool get isPlayerDefeated => currentPlayerHp <= 0;

  List<BossActionType> get availableBossActions {
    if (bossHpPercentage <= 0.25) {
      return [BossActionType.specialAttack, BossActionType.statusEffect];
    } else if (bossHpPercentage <= 0.5) {
      return [BossActionType.specialAttack, BossActionType.normalAttack];
    } else if (bossHpPercentage <= 0.75) {
      return [BossActionType.normalAttack, BossActionType.heal];
    }
    return [BossActionType.normalAttack];
  }

  BossFight copyWith({
    int? currentHp,
    int? currentPlayerHp,
    BossFightState? state,
    List<Reward>? playerDeck,
    int? currentTurn,
    String? lastAction,
  }) {
    return BossFight(
      id: id,
      chapterId: chapterId,
      name: name,
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      maxPlayerHp: maxPlayerHp,
      currentPlayerHp: currentPlayerHp ?? this.currentPlayerHp,
      playerDeck: playerDeck ?? this.playerDeck,
      availableRewards: availableRewards,
      state: state ?? this.state,
      adaptiveQuizzes: adaptiveQuizzes,
      currentTurn: currentTurn ?? this.currentTurn,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [
    id,
    chapterId,
    name,
    maxHp,
    currentHp,
    maxPlayerHp,
    currentPlayerHp,
    playerDeck,
    availableRewards,
    state,
    adaptiveQuizzes,
    currentTurn,
    lastAction,
  ];
}

class BossAction extends Equatable {
  final BossActionType type;
  final int damage;
  final String description;
  final String? quizId;

  const BossAction({
    required this.type,
    required this.damage,
    required this.description,
    this.quizId,
  });

  @override
  List<Object?> get props => [type, damage, description, quizId];
}
