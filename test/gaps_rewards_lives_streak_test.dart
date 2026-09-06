import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slay_the_roadmap/data/repositories/reward_repository.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/widgets/player_hud.dart';

/// Gap US-03/GamiDOC/Toda: tipi reward distinti, vite x3, streak.
void main() {
  group('Reward: 3 carte di 3 tipi diversi', () {
    test('getRewardsForTopic propone tipi distinti', () async {
      final repo = LocalRewardRepository();
      // Ripetuto: la scelta dentro il tipo è random.
      for (var i = 0; i < 10; i++) {
        final rewards = await repo.getRewardsForTopic('topic$i');
        expect(rewards, hasLength(3));
        final types = rewards.map((r) => r.type).toSet();
        expect(types, hasLength(3));
      }
    });
  });

  group('Vite x3', () {
    test('default 3 vite', () {
      expect(PlayerViewModel().progress.lives, 3);
    });

    test('defeat scala di 1 fino a 0', () {
      final vm = PlayerViewModel();
      expect(vm.recordBossDefeat(), 2);
      expect(vm.recordBossDefeat(), 1);
      expect(vm.recordBossDefeat(), 0);
      // Min 0: non va sotto.
      expect(vm.recordBossDefeat(), 0);
      expect(vm.progress.lives, 0);
    });

    test('blocco ingresso a 0 vite', () {
      final vm = PlayerViewModel(
        initialProgress: PlayerProgress.initial().copyWith(lives: 0),
      );
      expect(vm.canEnterBoss, isFalse);
      expect(PlayerViewModel().canEnterBoss, isTrue);
    });

    test('quiz passato recupera +1 vita fino a max 3 (cap)', () {
      final vm = PlayerViewModel(
        initialProgress: PlayerProgress.initial().copyWith(lives: 1),
      );
      vm.addCompletedTopic('t1');
      expect(vm.progress.lives, 2);
      vm.addCompletedTopic('t2');
      expect(vm.progress.lives, 3);
      vm.addCompletedTopic('t3');
      expect(vm.progress.lives, 3);
    });
  });

  group('Streak', () {
    test('quiz passato incrementa, fallito resetta', () {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1');
      expect(vm.progress.streak, 1);
      vm.addCompletedTopic('t2');
      expect(vm.progress.streak, 2);
      vm.recordQuizFail();
      expect(vm.progress.streak, 0);
      // Fail a streak 0: nessun cambio, nessuna eccezione.
      vm.recordQuizFail();
      expect(vm.progress.streak, 0);
    });

    test('bonus +25 XP a ogni multiplo di 3', () {
      final vm = PlayerViewModel();
      vm.addCompletedTopic('t1'); // 100
      expect(vm.progress.experience, 100);
      vm.addCompletedTopic('t2'); // 200
      expect(vm.progress.experience, 200);
      vm.addCompletedTopic('t3'); // 300 + 25 bonus
      expect(vm.progress.experience, 325);
      expect(vm.progress.streak, 3);
    });
  });

  group('PlayerHud serie', () {
    testWidgets('nascosta se streak < 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(
              progress: PlayerProgress.initial().copyWith(streak: 1),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('player_hud_streak')), findsNothing);
    });

    testWidgets('mostra Serie xN se N >= 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(
              progress: PlayerProgress.initial().copyWith(streak: 3),
            ),
          ),
        ),
      );
      expect(find.text('Serie x3'), findsOneWidget);
    });
  });

  group('Save v1 compatibilità', () {
    test('save senza lives/streak carica con default 3/0', () {
      final json = PlayerProgress.initial().toJson()
        ..remove('lives')
        ..remove('streak');
      final restored = PlayerProgress.fromJson(json);
      expect(restored.lives, 3);
      expect(restored.streak, 0);
    });

    test('roundtrip preserva lives e streak', () {
      final p = PlayerProgress.initial().copyWith(lives: 1, streak: 2);
      final restored = PlayerProgress.fromJson(p.toJson());
      expect(restored.lives, 1);
      expect(restored.streak, 2);
    });
  });
}
