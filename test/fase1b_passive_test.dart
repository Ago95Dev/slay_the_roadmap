import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/campaign_lore.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/boss_fight_active_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/boss_fight_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Voce C — 1 passiva distintiva per boss (numeri semplici).
///
/// - Man-in-the-Middle: enrage anticipato (special -2 già sotto 75%).
/// - The Amnesiac: risposta errata -> oltre al danno, -1 ⚡ (min 0).
/// - Spaghetti Colossus: corazza — ignora il primo punto danno da carte
///   per fight (i quiz la aggirano).
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
      effects: {'damage': damage, 'block': 0, 'heal': 0},
    );

Future<BossFightViewModel> _loadedVm(String bossId) async {
  final vm = BossFightViewModel(
    BossRepository(),
    bossTurnDelay: Duration.zero,
  );
  await vm.loadBoss(bossId);
  expect(vm.currentBoss, isNotNull, reason: bossId);
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

/// Porta il fight al turno boss (quiz player tutto errato = 0 danni).
Future<void> _goToBossTurn(BossFightViewModel vm) async {
  vm.startQuiz();
  _answerQuiz(vm, correct: false);
  await Future.delayed(const Duration(milliseconds: 50));
  expect(vm.currentBoss!.state, BossFightState.bossTurn);
  expect(vm.isQuizActive, isTrue);
}

void main() {
  group('MITM: enrage anticipato sotto 75%', () {
    test('sotto 75% (7/10) l\u2019errata costa -2 (special)', () async {
      final vm = await _loadedVm('man_in_the_middle');
      vm.startBattle(inventory: [_card('a', damage: 2), _card('b', damage: 1)]);
      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'a'));
      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'b'));
      expect(vm.currentBoss!.currentHp, 7);
      expect(vm.currentBoss!.isEnraged, isTrue);

      await _goToBossTurn(vm);
      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 2);
      expect(vm.combatLog, contains('Special Attack'));
    });

    test('sopra 75% (8/10) l\u2019errata costa -1 (normal)', () async {
      final vm = await _loadedVm('man_in_the_middle');
      vm.startBattle(inventory: [_card('a', damage: 2)]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentHp, 8);
      expect(vm.currentBoss!.isEnraged, isFalse);

      await _goToBossTurn(vm);
      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 1);
      expect(vm.combatLog, contains('Normal Attack'));
    });
  });

  group('Amnesiac: oblio (-1 energia su errata)', () {
    test('errata -> danno + energia max-1 + riga nel log', () async {
      final vm = await _loadedVm('the_amnesiac');
      vm.startBattle(inventory: const []);
      await _goToBossTurn(vm);

      final playerBefore = vm.currentBoss!.currentPlayerHp;
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));

      // Danno normale a HP pieni + turno ripartito da max-1.
      expect(vm.currentBoss!.currentPlayerHp, playerBefore - 1);
      expect(vm.currentBoss!.currentEnergy, vm.currentBoss!.maxEnergy - 1);
      expect(vm.combatLog, contains('ti fa dimenticare'));
    });

    test('giusta -> nessuna perdita di energia', () async {
      final vm = await _loadedVm('the_amnesiac');
      vm.startBattle(inventory: const []);
      await _goToBossTurn(vm);

      _answerQuiz(vm, correct: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm.currentBoss!.currentEnergy, vm.currentBoss!.maxEnergy);
      expect(vm.combatLog, isNot(contains('ti fa dimenticare')));
    });

    test('energia mai sotto 0 su errate ripetute', () async {
      final vm = await _loadedVm('the_amnesiac');
      vm.startBattle(inventory: const []);
      for (var round = 0; round < 2; round++) {
        await _goToBossTurn(vm);
        _answerQuiz(vm, correct: false);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(vm.currentBoss!.currentEnergy, greaterThanOrEqualTo(0));
        if (vm.currentBoss!.state != BossFightState.playerTurn) break;
      }
      expect(vm.currentBoss!.currentEnergy, greaterThanOrEqualTo(0));
    });
  });

  group('Colossus: corazza anti-carte', () {
    test('prima carta da 1 ignorata, seconda passa + riga nel log', () async {
      final vm = await _loadedVm('spaghetti_colossus');
      vm.startBattle(inventory: [_card('a', damage: 1), _card('b', damage: 1)]);
      expect(vm.colossusArmorUsed, isFalse);

      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'a'));
      expect(vm.currentBoss!.currentHp, 10);
      expect(vm.colossusArmorUsed, isTrue);
      expect(vm.combatLog, contains('assorbe il colpo'));

      vm.useCard(vm.currentBoss!.playerDeck.firstWhere((c) => c.id == 'b'));
      expect(vm.currentBoss!.currentHp, 9);
    });

    test('carta da 2: primo punto parato, il resto passa', () async {
      final vm = await _loadedVm('spaghetti_colossus');
      vm.startBattle(inventory: [_card('a', damage: 2)]);
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentHp, 9);
      expect(vm.combatLog, contains('assorbe il colpo'));
    });

    test('quiz non consuma né subisce la corazza', () async {
      final vm = await _loadedVm('spaghetti_colossus');
      vm.startBattle(inventory: [_card('a', damage: 1)]);
      vm.startQuiz();
      _answerQuiz(vm, correct: true);
      // Quiz del Colossus: 2 domande giuste = 2 danni pieni.
      expect(vm.currentBoss!.currentHp, 8);
      expect(vm.colossusArmorUsed, isFalse);
      await Future.delayed(const Duration(milliseconds: 50));

      // Turno boss: errata (-1 player, Colossus a HP pieni: normal).
      _answerQuiz(vm, correct: false);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.currentBoss!.state, BossFightState.playerTurn);

      // La prima carta resta parata anche dopo il quiz.
      vm.useCard(vm.currentBoss!.playerDeck.first);
      expect(vm.currentBoss!.currentHp, 8);
      expect(vm.colossusArmorUsed, isTrue);
    });
  });

  group('Tratto pre-fight', () {
    test('ogni boss ha un tratto non vuoto', () {
      for (final id in [
        'man_in_the_middle',
        'the_amnesiac',
        'spaghetti_colossus',
      ]) {
        expect(bossTrait(id), startsWith('Tratto: '), reason: id);
      }
      expect(bossTrait('sconosciuto'), isEmpty);
    });

    testWidgets('schermata pre-fight mostra il tratto', (tester) async {
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
            home: BossFightActiveScreen(bossId: 'the_amnesiac'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('boss_trait')), findsOneWidget);
      expect(find.textContaining('Tratto:'), findsOneWidget);
    });

    testWidgets('dialog lore mostra il tratto prima di ogni fight',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      final playerVm = PlayerViewModel();
      final roadmapVm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider.value(value: roadmapVm),
          ],
          child: const MaterialApp(home: RoadmapScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      for (final id in [
        'web_network',
        'net_client_server',
        'net_dns_url',
        'net_http_https',
      ]) {
        roadmapVm.updateTopicStatus(id, TopicStatus.completed);
      }
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('boss_tile_man_in_the_middle')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('boss_lore_dialog')), findsOneWidget);
      expect(find.byKey(const Key('boss_lore_trait')), findsOneWidget);
      expect(find.textContaining('Tratto:'), findsOneWidget);
    });
  });
}
