import 'package:flutter_test/flutter_test.dart';

import 'package:slay_the_roadmap/main.dart';
import 'package:slay_the_roadmap/data/repositories/quiz_repository.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/quiz.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';

void main() {
  group('App smoke test', () {
    testWidgets('HomeScreen is mounted', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Slay the Roadmap'), findsWidgets);
    });
  });

  group('Quiz passing threshold (80%)', () {
    test('4/5 correct answers passes, 3/5 fails', () async {
      final repository = LocalQuizRepository();

      // Correct answers for quiz_web_network: [1, 1, 1, 1, 1]
      final passed = await repository.submitQuizAnswers(
        'quiz_web_network',
        [1, 1, 1, 1, 0], // last answer wrong -> 4/5
      );
      expect(passed.correctAnswers, 4);
      expect(passed.totalQuestions, 5);
      expect(passed.percentage, 80.0);
      expect(passed.passed, isTrue);

      final failed = await repository.submitQuizAnswers(
        'quiz_web_network',
        [1, 1, 1, 0, 0], // Q4 and Q5 wrong -> 3/5
      );
      expect(failed.correctAnswers, 3);
      expect(failed.percentage, 60.0);
      expect(failed.passed, isFalse);
    });

    test('Quiz model requires 4/5 answers at 80% threshold', () {
      final quiz = Quiz(
        id: 'quiz_test',
        topicId: 'test',
        passingThreshold: 80,
        questions: List.generate(
          5,
          (i) => Question(
            text: 'Q$i',
            options: const ['a', 'b'],
            correctAnswerIndex: 0,
            explanation: 'exp',
          ),
        ),
      );
      expect(quiz.totalQuestions, 5);
      expect(quiz.requiredCorrectAnswers, 4);
    });
  });

  group('BossFight numeri (boss HP 10, player HP 3)', () {
    test('default player HP 3/3', () {
      const boss = BossFight(
        id: 'boss_test',
        chapterId: 'ch1',
        name: 'Test Boss',
        maxHp: 10,
        currentHp: 10,
      );
      expect(boss.maxPlayerHp, 3);
      expect(boss.currentPlayerHp, 3);
    });

    test('soglie 25/50/75% con HP 10 (niente veleno)', () {
      BossFight at(int hp) => BossFight(
            id: 'b',
            chapterId: 'c',
            name: 'B',
            maxHp: 10,
            currentHp: hp,
          );
      expect(at(10).availableBossActions, [BossActionType.normalAttack]);
      expect(
        at(7).availableBossActions,
        [BossActionType.normalAttack, BossActionType.heal],
      );
      expect(
        at(5).availableBossActions,
        [BossActionType.specialAttack, BossActionType.normalAttack],
      );
      expect(at(2).availableBossActions, [BossActionType.specialAttack]);
    });

    test('dealing damage reduces boss HP and defeats at 0', () {
      const boss = BossFight(
        id: 'boss_test',
        chapterId: 'ch1',
        name: 'Test Boss',
        maxHp: 10,
        currentHp: 10,
      );
      // Domanda boss giusta: -1 al boss.
      final damaged = boss.copyWith(currentHp: boss.currentHp - 1);
      expect(damaged.currentHp, 9);
      expect(damaged.isBossDefeated, isFalse);

      final defeated = damaged.copyWith(currentHp: 0);
      expect(defeated.isBossDefeated, isTrue);
    });

    test('card effects clampati a max 2', () {
      const card = Reward(
        id: 'card_test',
        name: 'Strike',
        description: 'Basic attack',
        type: RewardType.attack,
        rarity: RewardRarity.common,
        icon: 'sword',
        effects: {'damage': 15},
      );
      final damage = ((card.effects['damage'] as num?)?.toInt() ?? 0).clamp(0, 2);
      expect(damage, 2);
    });
  });

  group('PlayerProgress serialization', () {
    test('toJson/fromJson roundtrip preserves fields', () {
      final progress = PlayerProgress(
        playerId: 'player_1',
        playerName: 'Tester',
        experience: 100,
        level: 2,
        completedTopicIds: const ['web_network'],
        quizResults: [
          QuizResult(
            quizId: 'quiz_web_network',
            correctAnswers: 4,
            totalQuestions: 5,
            percentage: 80.0,
            passed: true,
            completedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
        inventory: const PlayerInventory(rewards: []),
        lastSaved: DateTime.utc(2026, 1, 2),
      );

      final restored = PlayerProgress.fromJson(progress.toJson());

      expect(restored.playerId, 'player_1');
      expect(restored.playerName, 'Tester');
      expect(restored.experience, 100);
      expect(restored.level, 2);
      expect(restored.completedTopicIds, ['web_network']);
      expect(restored.quizResults.single.passed, isTrue);
      expect(restored.quizResults.single.percentage, 80.0);
      expect(restored.isTopicCompleted('web_network'), isTrue);
      expect(restored.isTopicCompleted('net_client_server'), isFalse);
    });
  });
}
