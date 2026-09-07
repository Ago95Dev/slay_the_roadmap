import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/boss_fight_active_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/boss_fight_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Fase 1B-A (narrativa CD1 + fix endgame).
///
/// Root cause bug endgame: la vittoria era registrata solo dentro
/// `_claimVictoryReward` (dopo RewardChoice). Chiudere la schermata senza
/// claimare perdeva la vittoria: boss restava sfidabile, nessuna fine.

Reward _card(String id, {int damage = 0}) => Reward(
      id: id,
      name: 'Card $id',
      description: 'desc $id',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '⚔️',
      effects: {'damage': damage, 'block': 0, 'heal': 0},
    );

/// Risponde a tutte le domande del quiz attivo e lo invia.
void _answerAll(BossFightViewModel vm, {required bool correct}) {
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

const _allTopicIds = [
  'web_network',
  'net_client_server',
  'net_dns_url',
  'net_http_https',
  'web_data',
  'data_represent',
  'data_where',
  'data_state',
  'web_building',
  'build_browser',
  'build_framework',
  'build_ship',
];

const _allBossIds = [
  'man_in_the_middle',
  'the_amnesiac',
  'spaghetti_colossus',
];

Future<RoadmapViewModel> _pumpRoadmap(
  WidgetTester tester,
  PlayerViewModel playerVm, {
  RoadmapViewModel? roadmapVm,
}) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  final vm = roadmapVm ??
      RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: playerVm),
        ChangeNotifierProvider.value(value: vm),
      ],
      child: const MaterialApp(home: RoadmapScreen()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
  return vm;
}

void _completeTopics(RoadmapViewModel vm, Iterable<String> ids) {
  for (final id in ids) {
    vm.updateTopicStatus(id, TopicStatus.completed);
  }
}

Future<void> _recordBosses(PlayerViewModel playerVm, Iterable<String> ids) async {
  for (final id in ids) {
    final boss = await BossRepository().getBossById(id);
    expect(boss, isNotNull, reason: id);
    playerVm.recordBossVictory(boss!);
  }
}

/// Variante sincrona per i widget test (fake clock: niente Future.delayed
/// reali — costruisce i BossFight direttamente, a recordBossVictory basta
/// id/chapterId per la registrazione).
void _recordBossesSync(PlayerViewModel playerVm, Iterable<String> ids) {
  const chapters = {
    'man_in_the_middle': 'web_network',
    'the_amnesiac': 'web_data',
    'spaghetti_colossus': 'web_building',
  };
  for (final id in ids) {
    playerVm.recordBossVictory(
      BossFight(
        id: id,
        chapterId: chapters[id]!,
        name: id,
        maxHp: 10,
        currentHp: 10,
      ),
    );
  }
}

void main() {
  group('Fix endgame: vittoria persiste senza claim', () {
    testWidgets('vittoria registrata all\u2019arrivo, claim separato',
        (tester) async {
      final playerVm = PlayerViewModel();
      for (var i = 0; i < 3; i++) {
        expect(playerVm.claimReward('seed_$i', _card('s$i', damage: 2)), isTrue);
      }
      final bossVm = BossFightViewModel(
        BossRepository(),
        bossTurnDelay: Duration.zero,
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider.value(value: bossVm),
          ],
          child: const MaterialApp(
            home: BossFightActiveScreen(bossId: 'man_in_the_middle'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('START BATTLE'));
      await tester.pumpAndSettle();

      // Turno 1: 3 carte (boss 10 -> 4) + quiz perfetto (boss -> 1).
      for (var i = 0; i < 3; i++) {
        bossVm.useCard(bossVm.currentBoss!.playerDeck.first);
      }
      bossVm.startQuiz();
      _answerAll(bossVm, correct: true);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Turno boss (regen 1 -> 3): risposta giusta (boss -> 2).
      expect(bossVm.isQuizActive, isTrue);
      _answerAll(bossVm, correct: true);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Turno 2: quiz perfetto a deck vuoto (boss 2 -> vittoria).
      bossVm.startQuiz();
      _answerAll(bossVm, correct: true);
      await tester.pumpAndSettle();

      expect(find.text('VICTORY!'), findsOneWidget);
      // Chiudi l'eventuale level-up SENZA claimare.
      if (find.byKey(const Key('level_up_dialog')).evaluate().isNotEmpty) {
        await tester.tap(find.text('Fantastico!'));
        await tester.pumpAndSettle();
      }

      // MAI toccato CLAIM REWARDS, ma la vittoria persiste (+100 XP).
      expect(playerVm.isBossDefeated('man_in_the_middle'), isTrue);
      expect(playerVm.progress.experience, 100);
      // ...e il claim resta disponibile come passo separato.
      expect(find.text('CLAIM REWARDS'), findsOneWidget);
    });

    test('save v1 senza i nuovi campi: default tolleranti', () {
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
      // Envelope v1 (senza lives/streak/intro/finale/maxStreak).
      final restored = PlayerProgress.fromJson(json);
      expect(restored.seenChapterIntros, isEmpty);
      expect(restored.campaignCompletionSeen, isFalse);
      expect(restored.maxStreak, 0);
      expect(restored.lives, PlayerProgress.maxLives);
      expect(restored.streak, 0);
      // Round-trip: i nuovi campi vengono persistiti.
      final roundTrip =
          PlayerProgress.fromJson(restored.toJson());
      expect(roundTrip.seenChapterIntros, isEmpty);
      expect(roundTrip.campaignCompletionSeen, isFalse);
      expect(roundTrip.maxStreak, 0);
    });
  });

  group('Finale campagna', () {
    test('isCampaignComplete solo a capitoli completi + boss sconfitti',
        () async {
      final playerVm = PlayerViewModel();
      final roadmapVm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
      await roadmapVm.loadRoadmap();
      expect(roadmapVm.isCampaignComplete(), isFalse);

      _completeTopics(roadmapVm, _allTopicIds);
      expect(roadmapVm.isCampaignComplete(), isFalse,
          reason: 'mancano i boss');

      await _recordBosses(playerVm, _allBossIds.sublist(0, 2));
      expect(roadmapVm.isCampaignComplete(), isFalse,
          reason: 'manca il Colossus');

      await _recordBosses(playerVm, _allBossIds.sublist(2));
      expect(roadmapVm.isCampaignComplete(), isTrue);
    });

    testWidgets('niente finale a campagna incompleta', (tester) async {
      final playerVm = PlayerViewModel();
      final roadmapVm = await _pumpRoadmap(tester, playerVm);
      _completeTopics(roadmapVm, _allTopicIds.sublist(0, 4));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsNothing,
      );
    });

    testWidgets('finale con stats alla vittoria sul Colossus, una tantum',
        (tester) async {
      final playerVm = PlayerViewModel();
      for (var i = 0; i < 3; i++) {
        expect(playerVm.claimReward('seed_$i', _card('s$i', damage: 2)), isTrue);
      }
      final roadmapVm = await _pumpRoadmap(tester, playerVm);
      _completeTopics(
        roadmapVm,
        _allTopicIds.where((id) => id != 'build_ship'),
      );
      // build_ship completa il capitolo 3 (il boss richiede il capitolo).
      _completeTopics(roadmapVm, ['build_ship']);
      _recordBossesSync(playerVm, _allBossIds.sublist(0, 2));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsNothing,
      );

      // Boss finale: lore -> Combatti -> vittoria -> indietro.
      await tester.ensureVisible(
        find.byKey(const Key('boss_tile_spaghetti_colossus')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('boss_tile_spaghetti_colossus')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('boss_lore_dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('boss_lore_fight')));
      await tester.pumpAndSettle();
      expect(find.byType(BossFightActiveScreen), findsOneWidget);

      await tester.tap(find.text('START BATTLE'));
      await tester.pumpAndSettle();
      final bossCtx = tester.element(find.byType(BossFightActiveScreen));
      final bossVm = Provider.of<BossFightViewModel>(bossCtx, listen: false);
      // Guida la vittoria rispondendo sempre giusto (il vm dello schermo
      // usa il delay reale 1500ms: avanza il clock a ogni giro).
      var guard = 0;
      while (bossVm.currentBoss!.state != BossFightState.victory &&
          guard < 15) {
        guard++;
        if (bossVm.currentBoss!.state == BossFightState.playerTurn &&
            !bossVm.isQuizActive) {
          if (bossVm.currentBoss!.playerDeck.isNotEmpty &&
              bossVm.currentBoss!.currentEnergy > 0) {
            bossVm.useCard(bossVm.currentBoss!.playerDeck.first);
            continue;
          }
          bossVm.startQuiz();
        }
        if (bossVm.isQuizActive) {
          _answerAll(bossVm, correct: true);
        }
        await tester.pump(const Duration(milliseconds: 1600));
        await tester.pumpAndSettle();
      }
      expect(bossVm.currentBoss!.state, BossFightState.victory);
      await tester.pumpAndSettle();
      expect(find.text('VICTORY!'), findsOneWidget);

      // Torna alla roadmap senza claimare: il finale appare comunque.
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsOneWidget,
      );
      expect(find.textContaining('Campagna completata!'), findsOneWidget);
      final stats =
          tester.widget<Text>(find.byKey(const Key('campaign_complete_stats')));
      expect(stats.data, contains('Boss sconfitti: 3/3'));
      expect(stats.data, contains('XP:'));
      expect(stats.data, contains('Livello'));
      expect(stats.data, contains('Serie migliore:'));
      expect(playerVm.hasSeenCampaignCompletion, isTrue);

      // Rigioca chiede conferma: ANNULLA resta al finale.
      await tester.tap(find.byKey(const Key('campaign_replay')));
      await tester.pumpAndSettle();
      expect(find.text('Ricominciare la campagna?'), findsOneWidget);
      await tester.tap(find.text('ANNULLA'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsOneWidget,
      );

      // Torna alla roadmap: il finale non riappare (una tantum).
      await tester.tap(find.byKey(const Key('campaign_back')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('campaign_complete_dialog')),
        findsNothing,
      );
    });
  });

  group('Intro capitoli una-tantum', () {
    testWidgets('prima apertura mostra intro, poi mai più', (tester) async {
      final playerVm = PlayerViewModel();
      await _pumpRoadmap(tester, playerVm);

      await tester.tap(find.text('La Rete'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('chapter_intro_web_network')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('chapter_intro_ok')));
      await tester.pumpAndSettle();

      expect(playerVm.hasSeenChapterIntro('web_network'), isTrue);
      expect(find.byType(TopicDetailScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('La Rete'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('chapter_intro_web_network')),
        findsNothing,
      );
      expect(find.byType(TopicDetailScreen), findsOneWidget);
    });
  });

  group('Lore boss pre-fight', () {
    testWidgets('dialog con Combatti/Indietro prima di ogni fight',
        (tester) async {
      final playerVm = PlayerViewModel();
      final roadmapVm = await _pumpRoadmap(tester, playerVm);
      _completeTopics(roadmapVm, _allTopicIds.sublist(0, 4));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('boss_tile_man_in_the_middle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('boss_lore_dialog')), findsOneWidget);
      expect(find.textContaining('Chiudigli la porta in faccia'),
          findsOneWidget);

      // Indietro: resta sulla roadmap.
      await tester.tap(find.byKey(const Key('boss_lore_back')));
      await tester.pumpAndSettle();
      expect(find.byType(BossFightActiveScreen), findsNothing);

      // Combatti: apre il fight.
      await tester.tap(find.byKey(const Key('boss_tile_man_in_the_middle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('boss_lore_fight')));
      await tester.pumpAndSettle();
      expect(find.byType(BossFightActiveScreen), findsOneWidget);
    });
  });
}
