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
/// Numeri nuovi: boss HP 10, player HP 3, energia 3/3, costo carta 1,
/// carte clampate a max 2 (damage 1-2 / block 1 / heal 1), turno boss =
/// 1 domanda dal capitolo (giusta: boss -1, errata: SEMPRE danno al
/// player, -1 normale o -2 special se boss enraged a HP ≤50%; heal +2
/// solo a inizio turno boss se HP ≤25%), quiz player 1 danno per giusta,
/// +100 XP solo alla prima vittoria per boss.
Reward _card(
  String id, {
  RewardType type = RewardType.attack,
  int damage = 0,
  int block = 0,
  int heal = 0,
}) =>
    Reward(
      id: id,
      name: 'Card $id',
      description: 'desc $id',
      type: type,
      rarity: RewardRarity.common,
      icon: '⚔️',
      effects: {'damage': damage, 'block': block, 'heal': heal},
    );

Future<BossFightViewModel> _loadedVm() async {
  final vm = BossFightViewModel(
    BossRepository(),
    bossTurnDelay: Duration.zero,
  );
  await vm.loadBoss('man_in_the_middle');
  expect(vm.currentBoss, isNotNull);
  return vm;
}

/// Risponde a tutte le domande del quiz attivo e lo invia.
void _answerQuiz(BossFightViewModel vm, {required bool correct}) {
  final quiz = vm.currentQuiz!;
  for (var i = 0; i < quiz.questions.length; i++) {
    final q = quiz.questions[vm.currentQuestionIndex];
    vm.selectQuizAnswer(
      correct ? q.correctAnswerIndex : (q.correctAnswerIndex + 1) % q.options.length,
    );
    if (vm.currentQuestionIndex < quiz.questions.length - 1) {
      vm.nextQuestion();
    }
  }
  vm.submitQuiz();
}

void main() {
  group('Nuovi numeri', () {
    test('boss HP 10, player HP 3 al load', () async {
      final vm = await _loadedVm();
      expect(vm.currentBoss!.maxHp, 10);
      expect(vm.currentBoss!.currentHp, 10);
      expect(vm.currentBoss!.maxPlayerHp, 3);
      expect(vm.currentBoss!.currentPlayerHp, 3);
    });

    test('tutti e 3 i boss hanno HP 10', () async {
      final bosses = await BossRepository().getAllBosses();
      expect(bosses, hasLength(3));
      for (final boss in bosses) {
        expect(boss.maxHp, 10, reason: boss.id);
        expect(boss.maxPlayerHp, 3, reason: boss.id);
      }
    });

    test('turno boss: domanda singola dal capitolo', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: const []);
      vm.startQuiz();
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Turno boss = 1 domanda pescata dai quiz del capitolo.
      expect(vm.currentBoss!.state, BossFightState.bossTurn);
      expect(vm.isQuizActive, isTrue);
      expect(vm.currentQuiz!.questions, hasLength(1));
    });

    test('turno boss: giusta -1 al boss, errata -1 al player', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: const []);
      vm.startQuiz();
      // Player quiz tutto errato: 0 danni, boss resta a 10 (solo normal).
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      final bossBefore = vm.currentBoss!.currentHp;
      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.currentHp, bossBefore - 1);
      expect(vm.currentBoss!.state, BossFightState.playerTurn);

      // Secondo giro: risposta errata -> mossa normal da 1.
      vm.startQuiz();
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));
      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 1);
    });

    test('carte clampate a max 2 (vecchia fireball damage 15 -> 2)', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [_card('old', damage: 15)]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentHp, 8);
    });

    test('errata con boss enraged (HP ≤50%) → player -2 esatti', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('a', damage: 2),
        _card('b', damage: 2),
        _card('c', damage: 2),
      ]);
      for (var i = 0; i < 3; i++) {
        vm.useCard(vm.currentBoss!.playerDeck.first);
      }
      expect(vm.currentBoss!.currentHp, 4); // 40% ≤ 50%, sopra il regen
      vm.startQuiz();
      _answerQuiz(vm, correct: false);
      expect(vm.currentBoss!.currentHp, 4);
      await Future.delayed(const Duration(milliseconds: 50));

      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 2);
      // Mai heal come risposta a un errore: boss fermo a 4.
      expect(vm.currentBoss!.currentHp, 4);
    });

    test('heal +2 a inizio turno boss con HP ≤25% (clamp maxHp)', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('a', damage: 2),
        _card('b', damage: 2),
        _card('c', damage: 2),
      ]);
      for (var i = 0; i < 3; i++) {
        vm.useCard(vm.currentBoss!.playerDeck.first);
      }
      // Quiz perfetto (3 giuste = 3 danni): boss a 1 (10% ≤ 25%).
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      expect(vm.currentBoss!.currentHp, 1);
      await Future.delayed(const Duration(milliseconds: 50));

      // Inizio turno boss: regen +2 PRIMA della domanda (clamp a maxHp).
      expect(vm.currentBoss!.state, BossFightState.bossTurn);
      expect(vm.currentBoss!.currentHp, 3);
      expect(
        vm.currentBoss!.currentHp,
        lessThanOrEqualTo(vm.currentBoss!.maxHp),
      );
      expect(vm.combatLog, contains('si rigenera'));
      expect(vm.isQuizActive, isTrue);
      expect(vm.currentQuiz!.questions, hasLength(1));
    });

    test('mai heal su errore, nemmeno a HP bassi', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('a', damage: 2),
        _card('b', damage: 2),
        _card('c', damage: 2),
      ]);
      for (var i = 0; i < 3; i++) {
        vm.useCard(vm.currentBoss!.playerDeck.first);
      }
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));
      // Regen a inizio turno: 1 → 3.
      expect(vm.currentBoss!.currentHp, 3);

      // Errata a 3/10 (enraged): -2 al player, boss inchiodato a 3.
      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.currentHp, 3);
      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 2);
    });

    test('soglie con HP 10, niente veleno (+ MITM enraged a 75%)', () async {
      final vm = await _loadedVm();
      BossFight at(int hp) => vm.currentBoss!.copyWith(currentHp: hp);
      expect(at(10).availableBossActions, [BossActionType.normalAttack]);
      // Voce C: il MITM intercetta presto — già a 7/10 (70%) è enraged.
      expect(
        at(7).availableBossActions,
        [BossActionType.specialAttack, BossActionType.normalAttack],
      );
      expect(
        at(5).availableBossActions,
        [BossActionType.specialAttack, BossActionType.normalAttack],
      );
      expect(at(2).availableBossActions, [BossActionType.specialAttack]);
      // Gli altri boss restano a soglia 50%: 7/10 = normal+heal.
      const amnesiac = BossFight(
        id: 'the_amnesiac',
        chapterId: 'web_data',
        name: 'The Amnesiac',
        maxHp: 10,
        currentHp: 7,
      );
      expect(amnesiac.enrageThreshold, 0.5);
      expect(
        amnesiac.availableBossActions,
        [BossActionType.normalAttack, BossActionType.heal],
      );
    });

    test('block assorbe il prossimo attacco, heal recupera (max 3)', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('blk', type: RewardType.defense, damage: 0, block: 1),
        _card('tls', type: RewardType.utility, damage: 0, heal: 1),
      ]);
      expect(vm.currentBoss!.playerDeck, hasLength(2));

      // Scudo: turno boss errato -> danno assorbito, player resta a 3.
      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'blk'));
      vm.startQuiz();
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.currentPlayerHp, 3);

      // Heal a HP pieni: resta a 3 (no overheal), energia scalata.
      final energyBefore = vm.currentBoss!.currentEnergy;
      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'tls'));
      expect(vm.currentBoss!.currentPlayerHp, 3);
      expect(vm.currentBoss!.currentEnergy, energyBefore - 1);
    });
  });

  group('Fallback quiz capitolo', () {
    test('chapterTopicIds mappa ogni capitolo ai suoi topic', () {
      expect(
        BossRepository.chapterTopicIds('web_network'),
        containsAll([
          'web_network',
          'net_client_server',
          'net_dns_url',
          'net_http_https',
        ]),
      );
      expect(
        BossRepository.chapterTopicIds('web_data'),
        containsAll(['web_data', 'data_represent', 'data_where', 'data_state']),
      );
      expect(
        BossRepository.chapterTopicIds('web_building'),
        containsAll([
          'web_building',
          'build_browser',
          'build_framework',
          'build_ship',
        ]),
      );
      expect(BossRepository.chapterTopicIds('sconosciuto'), isEmpty);
    });

    test('boss senza adaptiveQuizzes -> popolati dal capitolo', () async {
      const bare = BossFight(
        id: 'bare',
        chapterId: 'web_network',
        name: 'Bare',
        maxHp: 10,
        currentHp: 10,
      );
      final populated =
          await BossRepository().populateChapterQuizzes(bare);
      expect(populated.adaptiveQuizzes, isNotEmpty);
      final ids = populated.adaptiveQuizzes.map((q) => q.id).toSet();
      expect(ids, contains('quiz_web_network'));
    });

    test('capitolo sconosciuto -> boss invariato', () async {
      const bare = BossFight(
        id: 'bare',
        chapterId: 'capitolo_fantasma',
        name: 'Bare',
        maxHp: 10,
        currentHp: 10,
      );
      final same = await BossRepository().populateChapterQuizzes(bare);
      expect(same.adaptiveQuizzes, isEmpty);
    });
  });

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

      // 3 carte in un turno -> energia 0 (boss da 10 HP sopravvive a 0 danni).
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

      // Il quiz chiude il turno -> domanda boss -> energia piena.
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.state, BossFightState.bossTurn);

      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.state, BossFightState.playerTurn);
      expect(vm.currentBoss!.currentEnergy, 3);
    });
  });

  group('Deck da inventory', () {
    test('attack/defense + utility heal, copie isSelected=false', () async {
      final vm = await _loadedVm();
      vm.startBattle(inventory: [
        _card('atk', type: RewardType.attack),
        _card('def', type: RewardType.defense),
        _card('tls', type: RewardType.utility, heal: 1),
        _card('uti', type: RewardType.utility),
        _card('spe', type: RewardType.special),
      ]);

      final deck = vm.currentBoss!.playerDeck;
      expect(deck.map((c) => c.id), containsAll(['atk', 'def', 'tls']));
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
    test('battaglia completa -> victory, reward + 100 XP solo la prima', () async {
      final vm = await _loadedVm();
      final playerVm = PlayerViewModel();
      vm.startBattle(inventory: [
        _card('a', damage: 2),
        _card('b', damage: 2),
        _card('c', damage: 2),
      ]);

      // Turno 1: 3 carte (6 danni, boss a 4) + quiz perfetto (3 domande
      // giuste = 3 danni, boss a 1).
      for (var i = 0; i < 3; i++) {
        vm.useCard(vm.currentBoss!.playerDeck.first);
      }
      expect(vm.currentBoss!.currentHp, 4);
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      expect(vm.currentBoss!.currentHp, 1);
      await Future.delayed(const Duration(milliseconds: 50));

      // Turno boss a HP ≤25%: regen +2 (boss a 3), poi la giusta (-1).
      expect(vm.currentBoss!.currentHp, 3);
      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.currentHp, 2);
      expect(vm.currentBoss!.state, BossFightState.playerTurn);

      // Turno 2: quiz perfetto con deck vuoto (3 danni) -> vittoria.
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.state, BossFightState.victory);
      expect(vm.isBossDefeated, isTrue);

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

      // Turni a danno 0 (risposte errate): il boss vince con mosse normali
      // da 1 (player HP 3 -> 3 turni errati).
      var guard = 0;
      while (vm.currentBoss!.state != BossFightState.defeat && guard < 25) {
        guard++;
        if (vm.currentBoss!.state == BossFightState.playerTurn &&
            !vm.isQuizActive) {
          vm.startQuiz();
        }
        if (vm.isQuizActive) {
          _answerQuiz(vm, correct: false);
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
      vm.startBattle(inventory: [_card('a', damage: 2), _card('b')]);
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
            home: BossFightActiveScreen(bossId: 'man_in_the_middle'),
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
