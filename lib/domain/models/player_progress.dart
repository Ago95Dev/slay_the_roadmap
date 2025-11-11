import 'package:equatable/equatable.dart';
import 'topic.dart';
import 'reward.dart';
import 'quiz.dart';
import 'boss_fight.dart';

class PlayerProgress extends Equatable {
  final String playerId;
  final String playerName;
  final int experience;
  final int level;
  final List<String> completedTopicIds;
  final List<QuizResult> quizResults;
  final PlayerInventory inventory;
  final Map<String, BossFight> bossFights;
  final DateTime lastSaved;

  const PlayerProgress({
    required this.playerId,
    required this.playerName,
    this.experience = 0,
    this.level = 1,
    this.completedTopicIds = const [],
    this.quizResults = const [],
    required this.inventory,
    this.bossFights = const {},
    required this.lastSaved,
  });

  factory PlayerProgress.initial() {
    return PlayerProgress(
      playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
      playerName: 'Adventurer',
      experience: 0,
      level: 1,
      completedTopicIds: [],
      quizResults: [],
      inventory: const PlayerInventory(rewards: []),
      bossFights: {},
      lastSaved: DateTime.now(),
    );
  }

  bool isTopicCompleted(String topicId) => completedTopicIds.contains(topicId);

  PlayerProgress addCompletedTopic(String topicId) {
    return copyWith(
      completedTopicIds: [...completedTopicIds, topicId],
      experience: experience + 100,
    );
  }

  PlayerProgress addQuizResult(QuizResult result) {
    return copyWith(
      quizResults: [...quizResults, result],
    );
  }

  PlayerProgress addReward(Reward reward) {
    return copyWith(
      inventory: inventory.addReward(reward),
    );
  }

  PlayerProgress updateBossFight(BossFight bossFight) {
    return copyWith(
      bossFights: {...bossFights, bossFight.id: bossFight},
    );
  }

  PlayerProgress copyWith({
    String? playerId,
    String? playerName,
    int? experience,
    int? level,
    List<String>? completedTopicIds,
    List<QuizResult>? quizResults,
    PlayerInventory? inventory,
    Map<String, BossFight>? bossFights,
    DateTime? lastSaved,
  }) {
    return PlayerProgress(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      experience: experience ?? this.experience,
      level: level ?? this.level,
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
      quizResults: quizResults ?? this.quizResults,
      inventory: inventory ?? this.inventory,
      bossFights: bossFights ?? this.bossFights,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'experience': experience,
      'level': level,
      'completedTopicIds': completedTopicIds,
      'quizResults': quizResults.map((r) => _quizResultToJson(r)).toList(),
      'inventory': {
        'rewards': inventory.rewards.map((r) => _rewardToJson(r)).toList(),
        'maxSlots': inventory.maxSlots,
      },
      'bossFights': bossFights.map((key, value) => MapEntry(key, _bossFightToJson(value))),
      'lastSaved': lastSaved.toIso8601String(),
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      playerId: json['playerId'],
      playerName: json['playerName'],
      experience: json['experience'],
      level: json['level'],
      completedTopicIds: List<String>.from(json['completedTopicIds']),
      quizResults: (json['quizResults'] as List).map((r) => _quizResultFromJson(r)).toList(),
      inventory: PlayerInventory(
        rewards: (json['inventory']['rewards'] as List).map((r) => _rewardFromJson(r)).toList(),
        maxSlots: json['inventory']['maxSlots'],
      ),
      bossFights: (json['bossFights'] as Map).map((key, value) => MapEntry(key, _bossFightFromJson(value))),
      lastSaved: DateTime.parse(json['lastSaved']),
    );
  }

  static Map<String, dynamic> _quizResultToJson(QuizResult result) => {
    'quizId': result.quizId,
    'correctAnswers': result.correctAnswers,
    'totalQuestions': result.totalQuestions,
    'percentage': result.percentage,
    'passed': result.passed,
    'completedAt': result.completedAt.toIso8601String(),
  };

  static QuizResult _quizResultFromJson(Map<String, dynamic> json) => QuizResult(
    quizId: json['quizId'],
    correctAnswers: json['correctAnswers'],
    totalQuestions: json['totalQuestions'],
    percentage: json['percentage'],
    passed: json['passed'],
    completedAt: DateTime.parse(json['completedAt']),
  );

  static Map<String, dynamic> _rewardToJson(Reward reward) => {
    'id': reward.id,
    'name': reward.name,
    'description': reward.description,
    'type': reward.type.index,
    'rarity': reward.rarity.index,
    'icon': reward.icon,
    'effects': reward.effects,
    'isSelected': reward.isSelected,
  };

  static Reward _rewardFromJson(Map<String, dynamic> json) => Reward(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: RewardType.values[json['type']],
    rarity: RewardRarity.values[json['rarity']],
    icon: json['icon'],
    effects: Map<String, dynamic>.from(json['effects']),
    isSelected: json['isSelected'],
  );

  static Map<String, dynamic> _bossFightToJson(BossFight boss) => {
    'id': boss.id,
    'chapterId': boss.chapterId,
    'name': boss.name,
    'maxHp': boss.maxHp,
    'currentHp': boss.currentHp,
    'maxPlayerHp': boss.maxPlayerHp,
    'currentPlayerHp': boss.currentPlayerHp,
    'playerDeck': boss.playerDeck.map(_rewardToJson).toList(),
    'availableRewards': boss.availableRewards.map(_rewardToJson).toList(),
    'state': boss.state.index,
    'currentTurn': boss.currentTurn,
    'lastAction': boss.lastAction,
  };

  static BossFight _bossFightFromJson(Map<String, dynamic> json) => BossFight(
    id: json['id'],
    chapterId: json['chapterId'],
    name: json['name'],
    maxHp: json['maxHp'],
    currentHp: json['currentHp'],
    maxPlayerHp: json['maxPlayerHp'],
    currentPlayerHp: json['currentPlayerHp'],
    playerDeck: (json['playerDeck'] as List).map((r) => _rewardFromJson(r)).toList(),
    availableRewards: (json['availableRewards'] as List).map((r) => _rewardFromJson(r)).toList(),
    state: BossFightState.values[json['state']],
    adaptiveQuizzes: [], // Simplified for now
    currentTurn: json['currentTurn'],
    lastAction: json['lastAction'],
  );

  @override
  List<Object?> get props => [
    playerId,
    playerName,
    experience,
    level,
    completedTopicIds,
    quizResults,
    inventory,
    bossFights,
    lastSaved,
  ];
}
