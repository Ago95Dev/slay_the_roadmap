import '../../domain/models/boss_fight.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/quiz.dart';

class BossRepository {
  // Mock boss fights for now
  Future<List<BossFight>> getAllBosses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockBosses;
  }

  Future<BossFight?> getBossById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockBosses.firstWhere((boss) => boss.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<BossFight?> getBossByChapterId(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockBosses.firstWhere((boss) => boss.chapterId == chapterId);
    } catch (e) {
      return null;
    }
  }

  // Mock data
  static final List<BossFight> _mockBosses = [
    BossFight(
      id: 'boss_dart_basics',
      chapterId: 'dart_basics',
      name: 'The Syntax Guardian',
      maxHp: 150,
      currentHp: 150,
      availableRewards: [
        const Reward(
          id: 'reward_1',
          name: 'Quick Learner',
          description: 'Gain +10% quiz score on Dart basics topics',
          type: RewardType.utility,
          rarity: RewardRarity.common,
          icon: '📚',
          effects: {'quizBonus': 0.1, 'topics': ['dart_basics']},
        ),
        const Reward(
          id: 'reward_2',
          name: 'Syntax Master',
          description: 'Deal +5 damage on correct syntax questions',
          type: RewardType.attack,
          rarity: RewardRarity.rare,
          icon: '⚔️',
          effects: {'damage': 5, 'questionType': 'syntax'},
        ),
        const Reward(
          id: 'reward_3',
          name: 'Defender Shield',
          description: 'Reduce damage from boss attacks by 3',
          type: RewardType.defense,
          rarity: RewardRarity.common,
          icon: '🛡️',
          effects: {'damageReduction': 3},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_dart_1',
          topicId: 'dart_basics',
          questions: [
            const Question(
              text: 'What keyword is used to declare a variable that cannot be reassigned?',
              options: ['var', 'let', 'final', 'const'],
              correctAnswerIndex: 2,
              explanation: 'The "final" keyword in Dart creates a variable that can only be assigned once.',
            ),
            const Question(
              text: 'Which of these is NOT a valid Dart data type?',
              options: ['int', 'String', 'boolean', 'double'],
              correctAnswerIndex: 2,
              explanation: 'Dart uses "bool" not "boolean" for boolean values.',
            ),
            const Question(
              text: 'What does the "late" keyword do in Dart?',
              options: [
                'Delays variable initialization',
                'Makes the variable lazy',
                'Allows non-nullable variable to be initialized later',
                'Creates a time-based variable'
              ],
              correctAnswerIndex: 2,
              explanation: 'The "late" keyword allows you to declare a non-nullable variable that will be initialized later, before its first use.',
            ),
          ],
          passingThreshold: 70,
        ),
      ],
    ),
    BossFight(
      id: 'boss_flutter_widgets',
      chapterId: 'flutter_widgets',
      name: 'Widget Overlord',
      maxHp: 200,
      currentHp: 200,
      availableRewards: [
        const Reward(
          id: 'reward_4',
          name: 'Widget Wisdom',
          description: 'Gain insight into Flutter widget tree',
          type: RewardType.utility,
          rarity: RewardRarity.epic,
          icon: '🧠',
          effects: {'hintChance': 0.25},
        ),
        const Reward(
          id: 'reward_5',
          name: 'Critical Strike',
          description: 'Deal double damage on perfect answers',
          type: RewardType.attack,
          rarity: RewardRarity.legendary,
          icon: '💥',
          effects: {'criticalMultiplier': 2.0},
        ),
        const Reward(
          id: 'reward_6',
          name: 'Health Potion',
          description: 'Restore 20 HP when quiz score > 80%',
          type: RewardType.defense,
          rarity: RewardRarity.rare,
          icon: '❤️',
          effects: {'healing': 20, 'threshold': 0.8},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_flutter_1',
          topicId: 'flutter_widgets',
          questions: [
            const Question(
              text: 'Which widget is stateful?',
              options: ['Container', 'Text', 'Checkbox', 'Icon'],
              correctAnswerIndex: 2,
              explanation: 'Checkbox is a StatefulWidget because it needs to track its checked state.',
            ),
            const Question(
              text: 'What does setState() do?',
              options: [
                'Creates a new state',
                'Notifies framework to rebuild widget',
                'Saves state to disk',
                'Resets widget to initial state'
              ],
              correctAnswerIndex: 1,
              explanation: 'setState() notifies the Flutter framework that the internal state has changed and the widget should rebuild.',
            ),
          ],
          passingThreshold: 75,
        ),
      ],
    ),
    BossFight(
      id: 'boss_async_dart',
      chapterId: 'async_programming',
      name: 'Async Demon',
      maxHp: 250,
      currentHp: 250,
      availableRewards: [
        const Reward(
          id: 'reward_7',
          name: 'Future Vision',
          description: 'See upcoming boss moves',
          type: RewardType.utility,
          rarity: RewardRarity.legendary,
          icon: '🔮',
          effects: {'foresight': 1},
        ),
        const Reward(
          id: 'reward_8',
          name: 'Async Blade',
          description: 'Deal massive damage on async questions',
          type: RewardType.attack,
          rarity: RewardRarity.epic,
          icon: '🗡️',
          effects: {'damage': 15, 'questionType': 'async'},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_async_1',
          topicId: 'async_programming',
          questions: [
            const Question(
              text: 'What keyword makes a function asynchronous in Dart?',
              options: ['await', 'async', 'future', 'promise'],
              correctAnswerIndex: 1,
              explanation: 'The "async" keyword marks a function as asynchronous, allowing it to use "await" and return a Future.',
            ),
            const Question(
              text: 'What does await do in Dart?',
              options: [
                'Pauses execution until Future completes',
                'Creates a new thread',
                'Makes code run faster',
                'Handles errors automatically'
              ],
              correctAnswerIndex: 0,
              explanation: 'The "await" keyword pauses execution until the Future completes and returns its result.',
            ),
          ],
          passingThreshold: 80,
        ),
      ],
    ),
  ];
}
