class Topic {
  final String id;
  final String title;
  final String description;
  final TopicType type;
  final List<Topic> subtopics;
  final TopicStatus status;
  final bool isExpanded;
  final List<String> prerequisites;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    this.type = TopicType.core,
    this.subtopics = const [],
    this.status = TopicStatus.locked,
    this.isExpanded = false,
    this.prerequisites = const [],
  });

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    TopicType? type,
    List<Topic>? subtopics,
    TopicStatus? status,
    bool? isExpanded,
    List<String>? prerequisites,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      subtopics: subtopics ?? this.subtopics,
      status: status ?? this.status,
      isExpanded: isExpanded ?? this.isExpanded,
      prerequisites: prerequisites ?? this.prerequisites,
    );
  }
}

enum TopicStatus { locked, inProgress, completed }
enum TopicType { core, optional }

class Quiz {
  final String id;
  final String topicId;
  final List<Question> questions;
  final int passingThreshold;

  Quiz({
    required this.id,
    required this.topicId,
    required this.questions,
    this.passingThreshold = 80,
  });
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  String? selectedAnswer;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedAnswer,
  });
}

class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final String previewAsset;
  final Map<String, dynamic> effect;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.previewAsset,
    required this.effect,
  });
}

enum RewardType { attack, defense, utility, special }

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

class PlayerProgress {
  final List<Topic> completedTopics;
  final List<Reward> obtainedRewards;
  final Map<String, int> bossProgress;

  PlayerProgress({
    required this.completedTopics,
    required this.obtainedRewards,
    required this.bossProgress,
  });

  factory PlayerProgress.initial() {
    return PlayerProgress(
      completedTopics: [],
      obtainedRewards: [],
      bossProgress: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedTopics': completedTopics.map((t) => t.id).toList(),
      'obtainedRewards': obtainedRewards.map((r) => r.id).toList(),
      'bossProgress': bossProgress,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      completedTopics: [],
      obtainedRewards: [],
      bossProgress: Map<String, int>.from(json['bossProgress'] ?? {}),
    );
  }
}
