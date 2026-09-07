import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Rigiocabilità quiz dei topic completati: icona sempre visibile con
/// quizId, replay senza doppi premi (niente XP, niente reward bis),
/// streak che continua a contare.
void main() {
  Widget wrap(Topic topic) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
          ),
          ChangeNotifierProvider(create: (_) => PlayerViewModel()),
        ],
        child: MaterialApp(home: TopicDetailScreen(topic: topic)),
      );

  Topic topicWith({required TopicStatus status, String? quizId = 'quiz_t1'}) =>
      Topic(
        id: 't1',
        title: 'Topic 1',
        description: 'desc',
        quizId: quizId,
        status: status,
      );

  group('TopicDetailScreen icona quiz replay', () {
    testWidgets('topic completato: icona replay con tooltip Rigioca Quiz',
        (tester) async {
      await tester.pumpWidget(
        wrap(topicWith(status: TopicStatus.completed)),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Rigioca Quiz'), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      // La vecchia icona/restrizione non deve più nasconderla.
      expect(find.byTooltip('Avvia Quiz'), findsNothing);
    });

    testWidgets('topic in corso: icona quiz con tooltip Avvia Quiz',
        (tester) async {
      await tester.pumpWidget(
        wrap(topicWith(status: TopicStatus.inProgress)),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Avvia Quiz'), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      expect(find.byTooltip('Rigioca Quiz'), findsNothing);
    });

    testWidgets('topic senza quiz: nessuna icona', (tester) async {
      await tester.pumpWidget(
        wrap(
          topicWith(status: TopicStatus.completed, quizId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Rigioca Quiz'), findsNothing);
      expect(find.byTooltip('Avvia Quiz'), findsNothing);
    });
  });

  group('PlayerViewModel.recordQuizReplay', () {
    test('replay passato: niente XP, streak +1', () {
      final vm = PlayerViewModel();
      // Primo passaggio reale: +100 XP, streak 1.
      vm.addCompletedTopic('t1');
      expect(vm.progress.experience, 100);
      expect(vm.progress.streak, 1);

      // Replay: XP invariati, streak che continua.
      final leveledUp = vm.recordQuizReplay('t1');

      expect(leveledUp, isFalse);
      expect(vm.progress.experience, 100);
      expect(vm.progress.streak, 2);
      expect(vm.progress.maxStreak, 2);
      expect(vm.progress.completedTopicIds, ['t1']);
    });

    test('replay al 3° di fila: niente bonus +25 XP, streak 3', () {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1'); // 100, streak 1
      vm.addCompletedTopic('t2'); // 200, streak 2
      final xpBefore = vm.progress.experience;

      vm.recordQuizReplay('t1'); // streak 3, ma 0 XP extra

      expect(vm.progress.streak, 3);
      expect(vm.progress.experience, xpBefore);
    });

    test('replay non dà reward bis: topic già claimed resta claimed', () {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1');
      expect(vm.isTopicClaimed('t1'), isFalse);

      // Primo claim (flusso RewardChoiceScreen -> claimReward).
      // Il guard isTopicClaimed blocca il secondo claim.
      vm.claimReward(
        't1',
        const Reward(
          id: 'r1',
          name: 'R1',
          description: 'desc',
          type: RewardType.attack,
          rarity: RewardRarity.common,
          icon: '🔥',
          effects: {'damage': 2},
        ),
      );
      expect(vm.isTopicClaimed('t1'), isTrue);
      final rewardsBefore = vm.inventory.rewards.length;

      // Replay: niente seconda reward possibile.
      vm.recordQuizReplay('t1');

      expect(vm.isTopicClaimed('t1'), isTrue);
      expect(vm.inventory.rewards.length, rewardsBefore);
    });

    test('replay pulisce i fail del topic e fail successivo resetta streak',
        () {
      final vm = PlayerViewModel();
      vm.recordQuizFail('t1');
      vm.recordQuizFail('t1');
      expect(vm.failCountOf('t1'), 2);

      vm.addCompletedTopic('t1');
      expect(vm.failCountOf('t1'), 0);

      vm.recordQuizReplay('t1');
      expect(vm.progress.streak, 2);

      vm.recordQuizFail('t1');
      expect(vm.progress.streak, 0);
    });
  });
}
