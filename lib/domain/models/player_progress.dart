import 'package:equatable/equatable.dart';
import 'reward.dart';
import 'quiz.dart';
import 'boss_fight.dart';

class PlayerProgress extends Equatable {
  /// Soglie XP (F6, uguali al futuro Hub): L1 0 / L2 100 / L3 500.
  static const int level2Threshold = 100;
  static const int level3Threshold = 500;
  static const int maxLevel = 3;

  /// Vite per i boss fight (GamiDOC): 3 di default, max 3.
  static const int maxLives = 3;

  /// Ogni [streakBonusEvery] quiz passati di fila, bonus [streakBonusXp] XP.
  static const int streakBonusEvery = 3;
  static const int streakBonusXp = 25;

  /// Livello calcolato da [experience] (unica fonte di verità, anche per
  /// l'Hub futuro). 0–99 → 1, 100–499 → 2, 500+ → 3.
  static int levelForXp(int experience) {
    if (experience >= level3Threshold) return 3;
    if (experience >= level2Threshold) return 2;
    return 1;
  }

  final String playerId;
  final String playerName;
  final int experience;
  final List<String> completedTopicIds;
  final List<QuizResult> quizResults;
  final PlayerInventory inventory;
  final Map<String, BossFight> bossFights;
  final DateTime lastSaved;

  /// Vite rimaste per i boss fight (default 3, max 3, persistite).
  final int lives;

  /// Serie di quiz topic passati di fila (default 0, persistita).
  final int streak;

  /// Miglior serie di quiz passati di fila (default 0, persistita).
  final int maxStreak;

  /// Intro capitoli già mostrate (Fase 1B-A, default [], persistite):
  /// ogni intro appare una sola volta per save, fino a New Run.
  final List<String> seenChapterIntros;

  /// Finale campagna già mostrato (Fase 1B-A, default false, persistito):
  /// la schermata "Campagna completata!" appare una volta per
  /// completamento, non a ogni apertura della roadmap.
  final bool campaignCompletionSeen;

  /// Livello derivato da [experience] (F6: niente più level salvato).
  int get level => levelForXp(experience);

  /// Soglia XP del prossimo livello (null al livello massimo).
  int? get xpForNextLevel {
    if (level >= maxLevel) return null;
    return level == 1 ? level2Threshold : level3Threshold;
  }

  /// XP mancanti al prossimo livello (null al livello massimo).
  int? get xpToNextLevel {
    final next = xpForNextLevel;
    if (next == null) return null;
    return next - experience;
  }

  /// Frazione 0..1 verso il prossimo livello (1.0 al livello massimo).
  /// L1: xp/100; L2: (xp-100)/400.
  double get xpProgress {
    if (level >= maxLevel) return 1.0;
    if (level == 1) {
      return (experience / level2Threshold).clamp(0.0, 1.0);
    }
    final span = level3Threshold - level2Threshold;
    return ((experience - level2Threshold) / span).clamp(0.0, 1.0);
  }

  const PlayerProgress({
    required this.playerId,
    required this.playerName,
    this.experience = 0,
    // Parametro conservato per compatibilità con i save v1 e il codice
    // esistente: ignorato, il livello è sempre ricalcolato da experience.
    int? level,
    this.completedTopicIds = const [],
    this.quizResults = const [],
    required this.inventory,
    this.bossFights = const {},
    required this.lastSaved,
    this.lives = maxLives,
    this.streak = 0,
    this.maxStreak = 0,
    this.seenChapterIntros = const [],
    this.campaignCompletionSeen = false,
  });

  factory PlayerProgress.initial() {
    return PlayerProgress(
      playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
      playerName: 'Adventurer',
      experience: 0,
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
    // Ignorato (compat): il livello è sempre derivato da experience.
    int? level,
    List<String>? completedTopicIds,
    List<QuizResult>? quizResults,
    PlayerInventory? inventory,
    Map<String, BossFight>? bossFights,
    DateTime? lastSaved,
    int? lives,
    int? streak,
    int? maxStreak,
    List<String>? seenChapterIntros,
    bool? campaignCompletionSeen,
  }) {
    return PlayerProgress(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      experience: experience ?? this.experience,
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
      quizResults: quizResults ?? this.quizResults,
      inventory: inventory ?? this.inventory,
      bossFights: bossFights ?? this.bossFights,
      lastSaved: lastSaved ?? this.lastSaved,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      seenChapterIntros: seenChapterIntros ?? this.seenChapterIntros,
      campaignCompletionSeen:
          campaignCompletionSeen ?? this.campaignCompletionSeen,
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
      'lives': lives,
      'streak': streak,
      'maxStreak': maxStreak,
      'seenChapterIntros': seenChapterIntros,
      'campaignCompletionSeen': campaignCompletionSeen,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    // Save v1: il campo 'level' salvato viene ignorato, il livello è
    // sempre ricalcolato da experience (F6).
    final experience = (json['experience'] as num).toInt();
    return PlayerProgress(
      playerId: json['playerId'],
      playerName: json['playerName'],
      experience: experience,
      completedTopicIds: List<String>.from(json['completedTopicIds']),
      quizResults: (json['quizResults'] as List).map((r) => _quizResultFromJson(r)).toList(),
      inventory: PlayerInventory(
        rewards: (json['inventory']['rewards'] as List).map((r) => _rewardFromJson(r)).toList(),
        maxSlots: json['inventory']['maxSlots'],
      ),
      bossFights: (json['bossFights'] as Map).map((key, value) => MapEntry(key, _bossFightFromJson(value))),
      lastSaved: DateTime.parse(json['lastSaved']),
      // Campi aggiunti dopo il save v1: default per i save vecchi.
      lives: (json['lives'] as num?)?.toInt() ?? maxLives,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['maxStreak'] as num?)?.toInt() ?? 0,
      seenChapterIntros:
          (json['seenChapterIntros'] as List?)?.map((e) => e as String).toList() ??
              const [],
      campaignCompletionSeen: (json['campaignCompletionSeen'] as bool?) ?? false,
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

  static Reward _rewardFromJson(Map<String, dynamic> json) {
    // Normalizzazione numeri boss fight: i save vecchi (pre-campagna)
    // possono avere carte con damage/block/heal a doppia cifra
    // (es. fireball damage 15); con boss HP 10 / player HP 3 gli effetti
    // sono clampati a max 2 in lettura.
    final effects = Map<String, dynamic>.from(json['effects']);
    for (final key in ['damage', 'block', 'heal']) {
      final value = effects[key];
      if (value is num && value > 2) effects[key] = 2;
    }
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: RewardType.values[json['type']],
      rarity: RewardRarity.values[json['rarity']],
      icon: json['icon'],
      effects: effects,
      isSelected: json['isSelected'],
    );
  }

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
    'adaptiveQuizzes': boss.adaptiveQuizzes.map(_quizToJson).toList(),
    'currentTurn': boss.currentTurn,
    'lastAction': boss.lastAction,
    'maxEnergy': boss.maxEnergy,
    'currentEnergy': boss.currentEnergy,
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
    adaptiveQuizzes: ((json['adaptiveQuizzes'] as List?) ?? const [])
        .map((q) => _quizFromJson(Map<String, dynamic>.from(q as Map)))
        .toList(),
    currentTurn: json['currentTurn'],
    lastAction: json['lastAction'],
    maxEnergy: (json['maxEnergy'] as num?)?.toInt() ?? 3,
    currentEnergy: (json['currentEnergy'] as num?)?.toInt() ?? 3,
  );

  static Map<String, dynamic> _quizToJson(Quiz quiz) => {
    'id': quiz.id,
    'topicId': quiz.topicId,
    'passingThreshold': quiz.passingThreshold,
    'questions': quiz.questions.map(_questionToJson).toList(),
  };

  static Quiz _quizFromJson(Map<String, dynamic> json) => Quiz(
    id: json['id'],
    topicId: json['topicId'],
    passingThreshold: (json['passingThreshold'] as num?)?.toInt() ?? 80,
    questions: ((json['questions'] as List?) ?? const [])
        .map((q) => _questionFromJson(Map<String, dynamic>.from(q as Map)))
        .toList(),
  );

  static Map<String, dynamic> _questionToJson(Question q) => {
    'text': q.text,
    'options': q.options,
    'correctAnswerIndex': q.correctAnswerIndex,
    'explanation': q.explanation,
  };

  static Question _questionFromJson(Map<String, dynamic> json) => Question(
    text: json['text'],
    options: List<String>.from(json['options'] as List? ?? const []),
    correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt() ?? 0,
    explanation: json['explanation'] ?? '',
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
    lives,
    streak,
    maxStreak,
    seenChapterIntros,
    campaignCompletionSeen,
  ];
}
