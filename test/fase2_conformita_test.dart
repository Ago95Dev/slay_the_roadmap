import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/models/types.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/widgets/compact_stats_bar.dart';
import 'package:slay_the_roadmap/widgets/topic_node.dart';

/// Conformità assignment Fase 2 (piano 2026-09-08, decisioni utente:
/// timer 25s RIMOSSO, skip-senza-XP RIMOSSO).
/// TDD: questi test nascono rossi, le fix li rendono verdi.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameProvider makeProvider() => GameProvider();

  // ---------------------------------------------------------- skip-senza-XP
  group('Fase 2: skip non sblocca, non dà XP', () {
    test('skip: tracciato come skipped, nessun unlock, nessun complete',
        () async {
      final provider = makeProvider();
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_2_0')
            .firstOrNull!
            .unlocked,
        isFalse,
      );

      provider.updateTopicStatus('variables-types', TopicStatus.skipped);

      expect(provider.skippedTopics, contains('variables-types'));
      expect(provider.completedTopics, isNot(contains('variables-types')));
      // Nessuna propagazione: i successori di node_1_0 restano locked.
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_2_0')
            .firstOrNull!
            .unlocked,
        isFalse,
      );
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_2_1')
            .firstOrNull!
            .unlocked,
        isFalse,
      );
    });

    test('skip: nessun XP assegnato', () {
      final provider = makeProvider();
      final before = provider.playerStats.experience;
      provider.updateTopicStatus('operators', TopicStatus.skipped);
      expect(provider.playerStats.experience, before);
    });
  });

  // ------------------------------------------------- leveling unico 0/100/500
  group('Fase 2: leveling unico PlayerProgress.levelForXp', () {
    test('provider: livello sempre derivato da XP (0/100/500)', () {
      final provider = makeProvider();
      // 50 + 5*10 = 100 XP -> soglia L2 con levelForXp, ma col legacy
      // (100+level*100 sottrattivo) resterebbe L1.
      provider.completeTopicQuiz('level_topic_a', 5, true);
      expect(provider.playerStats.experience, 100);
      expect(
        provider.playerStats.level,
        PlayerProgress.levelForXp(provider.playerStats.experience),
      );
      expect(provider.playerStats.level, 2);
    });

    testWidgets('HUD: LVL e XP/next coerenti con levelForXp', (tester) async {
      final provider = makeProvider();
      provider.completeTopicQuiz('level_topic_a', 5, true); // 100 XP -> L2
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('Unable to load asset')) {
          return;
        }
        FlutterError.presentError(details);
      };
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: CompactStatsBar()),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('LVL 2'), findsOneWidget);
      expect(find.text('XP 100/500'), findsOneWidget);
    });
  });

  // ------------------------------------------------------- reward 1/topic
  group('Fase 2: reward 1/topic (claimedRewardTopics)', () {
    test('claim: primo ok, secondo bloccato (no re-claim)', () {
      final provider = makeProvider();
      expect(provider.isRewardClaimed('reward_topic_x'), isFalse);
      expect(provider.claimRewardTopic('reward_topic_x'), isTrue);
      expect(provider.isRewardClaimed('reward_topic_x'), isTrue);
      expect(provider.claimRewardTopic('reward_topic_x'), isFalse);
    });

    test('claimed persistito nel save del provider', () async {
      final provider = makeProvider();
      provider.claimRewardTopic('reward_topic_y');
      // Ricarica da un nuovo provider: il claim sopravvive.
      final reloaded = makeProvider();
      await reloaded.loadProgress();
      expect(reloaded.isRewardClaimed('reward_topic_y'), isTrue);
    });
  });

  // ------------------------------------------------- boss victory / defeat
  group('Fase 2: boss victory aggiunge badge + XP + sblocco', () {
    test('defeatBoss: badge locale, XP, nodo boss completato, capitolo dopo',
        () {
      final provider = makeProvider();
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_5_0')
            .firstOrNull!
            .unlocked,
        isFalse,
      );

      provider.defeatBoss('syntax_sentinel');

      expect(provider.badges, contains('boss:syntax_sentinel'));
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_4_boss')
            .firstOrNull!
            .completed,
        isTrue,
      );
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_5_0')
            .firstOrNull!
            .unlocked,
        isTrue,
      );
      expect(provider.playerStats.experience, greaterThanOrEqualTo(150));
    });

    test('defeatBoss idempotente: doppio call, singolo XP e singolo badge',
        () {
      final provider = makeProvider();
      provider.defeatBoss('syntax_sentinel');
      final xpOnce = provider.playerStats.experience;
      provider.defeatBoss('syntax_sentinel');
      expect(provider.playerStats.experience, xpOnce);
      expect(
        provider.badges.where((b) => b == 'boss:syntax_sentinel').length,
        1,
      );
    });

    test('quiz passato: badge locale topic assegnato', () {
      final provider = makeProvider();
      provider.completeTopicQuiz('badge_topic_z', 5, true);
      expect(provider.badges, contains('topic:badge_topic_z'));
    });

    test('quiz fallito: nessun badge', () {
      final provider = makeProvider();
      provider.completeTopicQuiz('badge_topic_k', 1, false);
      expect(provider.badges, isNot(contains('topic:badge_topic_k')));
    });
  });

  // ------------------------------------------------------- roadmap gate
  group('Fase 2: roadmap gate reale (no demo-always-true)', () {
    testWidgets('topic avanzati locked finché il prereq non è completato',
        (tester) async {
      final provider = makeProvider();
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('Unable to load asset')) {
          return;
        }
        FlutterError.presentError(details);
      };
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: RoadmapScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Primo topic aperto, quelli dopo locked (gate reale, non always-true).
      final nodes = tester.widgetList<TopicNode>(find.byType(TopicNode));
      expect(nodes, isNotEmpty);
      expect(
        nodes.any((n) => n.topic.status == TopicStatus.locked),
        isTrue,
        reason: 'almeno un topic deve essere locked a progress zero',
      );
    });
  });
}
