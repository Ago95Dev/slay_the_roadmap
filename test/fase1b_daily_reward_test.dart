import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Fase 1B-E (daily reward): bonus XP +25 una-tantum giornaliero, locale
/// (niente Hub). Data `yyyy-MM-dd` persistita in [PlayerProgress].

String _today() => PlayerViewModel.dailyDateString(DateTime.now());

String _yesterday() => PlayerViewModel.dailyDateString(
      DateTime.now().subtract(const Duration(days: 1)),
    );

Future<void> _pumpHome(
  WidgetTester tester,
  PlayerViewModel playerVm,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: playerVm),
        ChangeNotifierProvider(
          create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PlayerProgress.lastDailyClaim', () {
    test('default vuoto e claim disponibile', () {
      final p = PlayerProgress.initial();
      expect(p.lastDailyClaim, isEmpty);
    });

    test('save v1 senza campo: default tollerante', () {
      final json = {
        'playerId': 'p1',
        'playerName': 'A',
        'experience': 100,
        'completedTopicIds': <String>[],
        'quizResults': [],
        'inventory': {
          'rewards': [],
          'maxSlots': 20,
        },
        'bossFights': {},
        'lastSaved': DateTime.now().toIso8601String(),
      };
      final restored = PlayerProgress.fromJson(json);
      expect(restored.lastDailyClaim, isEmpty);
    });

    test('roundtrip preserva la data', () {
      final p = PlayerProgress.initial().copyWith(lastDailyClaim: '2026-09-06');
      final restored = PlayerProgress.fromJson(p.toJson());
      expect(restored.lastDailyClaim, '2026-09-06');
    });
  });

  group('PlayerViewModel.claimDailyReward', () {
    test('primo claim ok: +25 XP e data odierna', () {
      final vm = PlayerViewModel();
      expect(vm.isDailyRewardAvailable, isTrue);
      expect(vm.claimDailyReward(), isTrue);
      expect(vm.progress.experience, PlayerViewModel.dailyRewardXp);
      expect(vm.progress.lastDailyClaim, _today());
      expect(vm.isDailyRewardAvailable, isFalse);
    });

    test('secondo claim stesso giorno: false senza XP', () {
      final vm = PlayerViewModel();
      expect(vm.claimDailyReward(), isTrue);
      final xp = vm.progress.experience;
      expect(vm.claimDailyReward(), isFalse);
      expect(vm.progress.experience, xp);
    });

    test('giorno diverso: claim di nuovo disponibile', () {
      final vm = PlayerViewModel(
        initialProgress:
            PlayerProgress.initial().copyWith(lastDailyClaim: _yesterday()),
      );
      expect(vm.isDailyRewardAvailable, isTrue);
      expect(vm.claimDailyReward(), isTrue);
      expect(vm.progress.experience, PlayerViewModel.dailyRewardXp);
      expect(vm.progress.lastDailyClaim, _today());
    });

    test('persistenza data: load() ripristina il claim di oggi', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final persistence = SharedPreferencesPersistence(prefs);
      final vm = PlayerViewModel(persistence: persistence);
      expect(vm.claimDailyReward(), isTrue);
      await Future.delayed(const Duration(milliseconds: 100));

      final vm2 = PlayerViewModel(persistence: persistence);
      expect(await vm2.load(), isTrue);
      expect(vm2.progress.lastDailyClaim, _today());
      expect(vm2.isDailyRewardAvailable, isFalse);
      expect(vm2.claimDailyReward(), isFalse);
      expect(vm2.progress.experience, PlayerViewModel.dailyRewardXp);
    });
  });

  group('Home banner ricompensa giornaliera', () {
    testWidgets('visibile se disponibile, tap = claim + SnackBar',
        (tester) async {
      final playerVm = PlayerViewModel();
      await _pumpHome(tester, playerVm);

      expect(find.byKey(const Key('home_daily_reward')), findsOneWidget);
      expect(
        find.text('🎁 Ricompensa giornaliera +25 XP'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('home_daily_reward_tap')));
      await tester.pumpAndSettle();

      expect(playerVm.progress.experience, PlayerViewModel.dailyRewardXp);
      expect(find.textContaining('Ricompensa riscattata'), findsOneWidget);
      // Dopo il claim il banner sparisce.
      expect(find.byKey(const Key('home_daily_reward')), findsNothing);
    });

    testWidgets('nascosto se già riscattata oggi', (tester) async {
      final playerVm = PlayerViewModel(
        initialProgress:
            PlayerProgress.initial().copyWith(lastDailyClaim: _today()),
      );
      await _pumpHome(tester, playerVm);

      expect(find.byKey(const Key('home_daily_reward')), findsNothing);
      expect(
        find.text('🎁 Ricompensa giornaliera +25 XP'),
        findsNothing,
      );
    });
  });
}
