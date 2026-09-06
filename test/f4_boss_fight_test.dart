import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/ui/screens/boss_fight_active_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/boss_fight_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';

/// F4 (US-04): boss fight — energia, deck da inventory, vittoria/sconfitta.
///
/// Numeri semplici: energia 3/3, costo carta 1, danni boss invariati
/// (normal 10 / special 20 / heal 15 / poison 5), quiz round(%/10),
/// +100 XP solo alla prima vittoria per boss.
Reward _card(
  String id, {
  RewardType type = RewardType.attack,
  int damage = 0,
}) =>
    Reward(
      id: id,
      name: 'Card $id',
      description: 'desc $id',
      type: type,
      rarity: RewardRarity.common,
      icon: '⚔️',
      effects: {'damage': damage},
    );

Future<BossFightViewModel> _loadedVm() async {
  final vm = BossFightViewModel(
    BossRepository(),
    bossTurnDelay: Duration.zero,
  );
  await vm.loadBoss('boss_dart_basics');
  expect(vm.currentBoss, isNotNull);
  return vm;
}

void main() {
  group('Energia', () {
    test('startBattle ripristina energia piena', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('a')]);

      expect(vm.currentBoss!.currentEnergy, 3);
      expect(vm.currentBoss!.maxEnergy, 3);
    });

    test('ogni carta costa 1 energia', () async {
      final vm = await _loadedVm();
      vm.startBattle(
        inventory: [_card('a'), _card('b'), _card('c'), _card('d')],
      );

      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentEnergy, 2);
      expect(vm.currentBoss!.state, BossFightState.playerTurn);

      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentEnergy, 1);
    });

    test('a energia 0 le carte sono bloccate', () async {
      final vm = await _loadedVm();
      vm.startBattle(
        inventory: [_card('a'), _card('b'), _card('c'), _card('d')],
      );

      // 3 carte in un turno -> energia 0 (boss da 150 HP sopravvive).
      for (var i = 0; i < 3; i++) {
        vm.useCard(vm.currentBoss!.playerDeck.first);
      }
      expect(vm.currentBoss!.currentEnergy, 0);
      expect(vm.canUseCard, isFalse);
      expect(vm.currentBoss!.canUseCard, isFalse);

      // La 4ª carta è bloccata: HP boss ed energia invariati.
      final hpBefore = vm.currentBoss!.currentHp;
      final remaining = vm.currentBoss!.playerDeck.single;
      vm.useCard(remaining);
      expect(vm.currentBoss!.currentEnergy, 0);
      expect(vm.currentBoss!.currentHp, hpBefore);
      expect(vm.currentBoss!.playerDeck, hasLength(1));
    });

    test('energia ripristinata a inizio turno player', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('a')]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentEnergy, 2);

      // Il quiz chiude il turno -> turno boss -> energia piena.
      vm.startQuiz();
      final quiz = vm.currentQuiz!;
      for (var i = 0; i < quiz.questions.length; i++) {
        vm.selectQuizAnswer(
          quiz.questions[vm.currentQuestionIndex].correctAnswerIndex,
        );
        if (vm.currentQuestionIndex < quiz.questions.length - 1) {
          vm.nextQuestion();
        }
      }
      vm.submitQuiz();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.state, BossFightState.playerTurn);
      expect(vm.currentBoss!.currentEnergy, 3);
    });
  });

  group('Deck da inventory', () {
    test('solo attack/defense, copie isSelected=false', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('atk', type: RewardType.attack),
        _card('def', type: RewardType.defense),
        _card('uti', type: RewardType.utility),
        _card('spe', type: RewardType.special),
      ]);

      final deck = vm.currentBoss!.playerDeck;
      expect(deck.map((c) => c.id), containsAll(['atk', 'def']));
      expect(deck.map((c) => c.id), isNot(contains('uti')));
      expect(deck.map((c) => c.id), isNot(contains('spe')));
      expect(deck.every((c) => !c.isSelected), isTrue);
    });

    test('carte giocate single-use per fight', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('a'), _card('b')]);
      expect(vm.currentBoss!.playerDeck, hasLength(2));

      final used = vm.currentBoss!.playerDeck.first;
      vm.useCard(used);
      expect(
        vm.currentBoss!.playerDeck.any((c) => c.id == used.id),
        isFalse,
      );
      expect(vm.currentBoss!.playerDeck, hasLength(1));

      // Rigocare la stessa carta è ignorato.
      final hpBefore = vm.currentBoss!.currentHp;
      vm.useCard(used);
      expect(vm.currentBoss!.currentHp, hpBefore);
    });
  });

  group('Vittoria', () {
    test('carta letale -> victory immediata', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('kill', damage: 200)]);

      vm.useCard(vm.currentBoss!.playerDeck.first);

      expect(vm.currentBoss!.state, BossFightState.victory);
      expect(vm.isBossDefeated, isTrue);
    });

    test('prima vittoria: reward + 100 XP; seconda: no XP', () async {
      final vm = await _loadedVm();
      final playerVm = PlayerViewModel();
      vm.startBattle(inventory: [_card('kill', damage: 200)]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      final boss = vm.currentBoss!;
      final reward = boss.availableRewards.first;

      final claimed = playerVm.claimReward(boss.id, reward);
      final first = playerVm.recordBossVictory(boss);

      expect(claimed, isTrue);
      expect(first, isTrue);
      expect(playerVm.inventory.rewards, hasLength(1));
      expect(playerVm.progress.experience, 100);
      expect(playerVm.isBossDefeated(boss.id), isTrue);

      // Seconda vittoria stesso boss: niente doppia reward, niente XP.
      final claimedAgain = playerVm.claimReward(boss.id, reward);
      final second = playerVm.recordBossVictory(boss);

      expect(claimedAgain, isFalse);
      expect(second, isFalse);
      expect(playerVm.inventory.rewards, hasLength(1));
      expect(playerVm.progress.experience, 100);
    });
  });

  group('Sconfitta', () {
    test('sconfitta senza reward né XP', () async {
      final vm = await _loadedVm();
      final playerVm = PlayerViewModel();
      vm.startBattle(inventory: const []);

      // Turni a danno 0 (risposte errate): il boss vince a colpi da 10.
      var guard = 0;
      while (vm.currentBoss!.state != BossFightState.defeat && guard < 25) {
        guard++;
        if (vm.currentBoss!.state == BossFightState.playerTurn &&
            !vm.isQuizActive) {
          vm.startQuiz();
        }
        if (vm.isQuizActive) {
          final quiz = vm.currentQuiz!;
          for (var i = 0; i < quiz.questions.length; i++) {
            final q = quiz.questions[vm.currentQuestionIndex];
            vm.selectQuizAnswer(
              (q.correctAnswerIndex + 1) % q.options.length,
            );
            if (vm.currentQuestionIndex < quiz.questions.length - 1) {
              vm.nextQuestion();
            }
          }
          vm.submitQuiz();
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }

      expect(vm.currentBoss!.state, BossFightState.defeat);
      expect(playerVm.progress.experience, 0);
      expect(playerVm.inventory.rewards, isEmpty);
      expect(playerVm.progress.bossFights, isEmpty);
    });

    test('retry ripristina HP ed energia', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('a'), _card('b')]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentEnergy, 2);
      expect(vm.currentBoss!.currentHp, lessThan(vm.currentBoss!.maxHp));

      vm.retryBattle();

      expect(vm.currentBoss!.currentHp, vm.currentBoss!.maxHp);
      expect(
        vm.currentBoss!.currentPlayerHp,
        vm.currentBoss!.maxPlayerHp,
      );
      expect(vm.currentBoss!.currentEnergy, vm.currentBoss!.maxEnergy);
      expect(vm.currentBoss!.state, BossFightState.notStarted);
      // Deck ripristinato per il nuovo tentativo.
      expect(vm.currentBoss!.playerDeck, hasLength(2));
    });
  });

  group('BossFightActiveScreen', () {
    testWidgets('mostra energia e quiz sempre disponibile', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PlayerViewModel()),
            ChangeNotifierProvider(
              create: (_) => BossFightViewModel(
                BossRepository(),
                bossTurnDelay: Duration.zero,
              ),
            ),
          ],
          child: const MaterialApp(
            home: BossFightActiveScreen(bossId: 'boss_dart_basics'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('START BATTLE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Energia: 3/3'), findsOneWidget);
      // Quiz sempre disponibile anche con deck vuoto.
      expect(find.text('Answer Quiz'), findsOneWidget);
    });
  });
}
