import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/domain/models/analytics_log.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/screens/settings_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';
import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';

/// F12: "Da ripassare" (failCount) + analytics locali per l'Evaluation.

Future<SharedPreferencesPersistence> _persistence() async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesPersistence(prefs);
}

BossFight _boss(String id) => BossFight(
      id: id,
      chapterId: 'ch1',
      name: 'Boss $id',
      maxHp: 10,
      currentHp: 10,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('failCount: incr/reset/persistenza', () {
    test('recordQuizFail(topic) incrementa, addCompletedTopic azzera', () {
      final vm = PlayerViewModel();
      expect(vm.failCountOf('t1'), 0);

      vm.recordQuizFail('t1');
      expect(vm.failCountOf('t1'), 1);
      // Sotto soglia: niente "da ripassare".
      expect(vm.reviewTopics, isEmpty);

      vm.recordQuizFail('t1');
      expect(vm.failCountOf('t1'), 2);
      expect(vm.reviewTopics, ['t1']);

      // Il passaggio azzera i fail del topic.
      vm.addCompletedTopic('t1');
      expect(vm.failCountOf('t1'), 0);
      expect(vm.reviewTopics, isEmpty);
    });

    test('reviewTopics ordinati per fail desc', () {
      final vm = PlayerViewModel(
        initialProgress: PlayerProgress.initial().copyWith(
          failCount: const {'t1': 2, 't2': 5, 't3': 1, 't4': 3},
        ),
      );
      // t3 (1 fail) resta fuori: soglia 2.
      expect(vm.reviewTopics, ['t2', 't4', 't1']);
    });

    test('recordQuizFail senza topic: solo reset serie (compat)', () {
      final vm = PlayerViewModel();
      vm.recordQuizFail();
      expect(vm.failCountOf('t1'), 0);
      expect(vm.reviewTopics, isEmpty);
    });

    test('failCount + analytics sopravvivono a save/load', () async {
      final persistence = await _persistence();
      final vm = PlayerViewModel(persistence: persistence);
      vm.recordQuizFail('t1');
      vm.recordQuizFail('t1');
      vm.recordQuizFail('t2');
      // Autosave fire-and-forget: attende la scrittura.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final vm2 = PlayerViewModel(persistence: persistence);
      expect(await vm2.load(), isTrue);
      expect(vm2.failCountOf('t1'), 2);
      expect(vm2.failCountOf('t2'), 1);
      expect(vm2.reviewTopics, ['t1']);
      expect(vm2.progress.analytics.quizFailed, 3);
    });

    test('save vecchi senza failCount/analytics: default vuoti', () {
      final restored = PlayerProgress.fromJson(
        PlayerProgress.initial().toJson()..removeWhere(
          (k, _) => k == 'failCount' || k == 'analytics',
        ),
      );
      expect(restored.failCount, isEmpty);
      expect(restored.analytics.events, isEmpty);
      expect(restored.topicsToReview, isEmpty);
    });
  });

  group('AnalyticsLog: cap 200 + conteggi', () {
    test('oltre 200 eventi tiene gli ultimi', () {
      var log = const AnalyticsLog();
      for (var i = 0; i < 250; i++) {
        log = log.record(
          AnalyticsEvent.quizPass,
          at: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        );
      }
      expect(log.events, hasLength(AnalyticsLog.maxEvents));
      // Il più vecchio tenuto è il n. 50 (i primi 50 scartati).
      expect(
        log.events.first.ts,
        DateTime(2026, 1, 1).add(const Duration(minutes: 50)),
      );
    });

    test('conteggi per tipo + session_start', () {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1'); // quiz_pass
      vm.recordQuizFail('t2'); // quiz_fail
      vm.recordQuizFail('t2'); // quiz_fail
      vm.recordBossVictory(_boss('b1')); // boss_win
      vm.recordBossDefeat(); // boss_lose
      vm.recordSessionStart(); // session_start

      final a = vm.progress.analytics;
      expect(a.quizPassed, 1);
      expect(a.quizFailed, 2);
      expect(a.bossWon, 1);
      expect(a.bossLost, 1);
      expect(a.sessions, 1);
    });
  });

  group('Sezione "Da ripassare" in roadmap', () {
    Future<void> pumpRoadmap(
      WidgetTester tester,
      PlayerViewModel playerVm,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final roadmapVm = RoadmapViewModel(LocalRoadmapRepository());
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider.value(value: roadmapVm),
          ],
          child: const MaterialApp(home: RoadmapScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    }

    testWidgets('nascosta se vuota', (tester) async {
      await pumpRoadmap(tester, PlayerViewModel());
      expect(find.byKey(const Key('review_section')), findsNothing);
    });

    testWidgets('visibile con fail>=2, ordinata per fail desc', (
      tester,
    ) async {
      final playerVm = PlayerViewModel(
        initialProgress: PlayerProgress.initial().copyWith(
          failCount: const {'t1': 2, 't2': 4},
        ),
      );
      await pumpRoadmap(tester, playerVm);

      expect(find.byKey(const Key('review_section')), findsOneWidget);
      expect(find.byKey(const Key('review_topic_t1')), findsOneWidget);
      expect(find.byKey(const Key('review_topic_t2')), findsOneWidget);

      // Ordine: t2 (4 fail) prima di t1 (2 fail).
      final tiles = tester
          .widgetList<ListTile>(
            find.descendant(
              of: find.byKey(const Key('review_section')),
              matching: find.byType(ListTile),
            ),
          )
          .toList();
      expect(tiles, hasLength(2));
      expect(find.text('❌×4'), findsOneWidget);
      expect(find.text('❌×2'), findsOneWidget);
      // Id fittizi non nell'albero: titolo = fallback all'id, l'ordine
      // riflette comunque i fail desc (t2 prima di t1).
      expect((tiles[0].title as Text).data, 't2');
      expect((tiles[1].title as Text).data, 't1');
    });
  });

  group('Settings "I miei numeri"', () {
    testWidgets('mostra i conteggi', (tester) async {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1');
      vm.recordQuizFail('t2');
      vm.recordBossVictory(_boss('b1'));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_stats')), findsOneWidget);
      expect(find.textContaining('Quiz superati: 1'), findsOneWidget);
      expect(find.textContaining('Quiz falliti: 1'), findsOneWidget);
      expect(find.textContaining('Boss vinti: 1'), findsOneWidget);
      expect(find.textContaining('Serie migliore:'), findsOneWidget);
    });

    testWidgets('nascosta senza PlayerViewModel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings_stats')), findsNothing);
    });
  });
}
