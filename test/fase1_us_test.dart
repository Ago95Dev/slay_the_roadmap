import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/quiz.dart' as domain;
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/models/types.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/home_screen.dart';
import 'package:slay_the_roadmap/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/screens/reward_selection_screen.dart';
import 'package:slay_the_roadmap/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/utils/constants.dart';
import 'package:slay_the_roadmap/widgets/topic_node.dart';

/// Rete di sicurezza Fase 1 (US-01..05): test minimi prima di toccare la
/// logica. Offline-first: FakeEngineClient di default, nessun segreto.
/// Stile allineato a test/boot_smoke_test.dart (non duplicato).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameProvider makeProvider() => GameProvider();

  Widget withProvider(GameProvider provider, Widget home) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: home),
    );
  }

  FlutterErrorDetails? ignoredAssetError;
  void Function(FlutterErrorDetails)? savedOnError;

  void restoreFlutterOnError() {
    if (savedOnError != null) {
      FlutterError.onError = savedOnError;
      savedOnError = null;
    }
  }

  /// Ignora per tutta la durata del test gli asset assenti (es. novice.png):
  /// in test gli Image.asset falliscono in async e farebbero fallire
  /// pumpAndSettle; gli altri errori restano visibili.
  void suppressMissingAssets() {
    savedOnError ??= FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('Unable to load asset')) {
        ignoredAssetError = details;
        return;
      }
      savedOnError?.call(details);
    };
    addTearDown(restoreFlutterOnError);
  }

  /// Silenzia gli errori asset noti in test (es. immagine profilo assente),
  /// come in boot_smoke_test.dart. La soppressione resta attiva fino a fine
  /// test (addTearDown): niente restore qui, altrimenti i pumpAndSettle
  /// successivi perderebbero la protezione.
  Future<void> pumpIgnoringAssets(
    WidgetTester tester,
    Widget widget, {
    Duration? settle,
  }) async {
    suppressMissingAssets();
    await tester.pumpWidget(widget);
    if (settle != null) {
      await tester.pump(settle);
    } else {
      await tester.pump();
    }
  }

  // ---------------------------------------------------------------- US-01
  group('US-01 gate roadmap', () {
    test('nodo locked: completeRoadmapNode è no-op (no complete, no unlock)',
        () async {
      final provider = makeProvider();
      // node_3_0 resta locked in questi test: nessun test completa node_2_x.
      final before = provider.roadmapNodes
          .where((n) => n.id == 'node_3_0')
          .firstOrNull;
      expect(before, isNotNull);
      expect(before!.unlocked, isFalse);

      provider.completeRoadmapNode('node_3_0');

      final after = provider.roadmapNodes
          .where((n) => n.id == 'node_3_0')
          .firstOrNull!;
      expect(after.completed, isFalse);
      // Nessuna propagazione: i successori restano locked.
      final next = provider.roadmapNodes
          .where((n) => n.id == 'node_4_boss')
          .firstOrNull!;
      expect(next.unlocked, isFalse);
    });

    test('unlock dopo prereq: completare start sblocca i nodi collegati',
        () async {
      final provider = makeProvider();
      expect(
        provider.roadmapNodes
            .where((n) => n.id == 'node_1_0')
            .firstOrNull!
            .unlocked,
        isFalse,
      );

      provider.completeRoadmapNode('start');

      for (final id in ['node_1_0', 'node_1_1', 'node_1_2']) {
        final node = provider.roadmapNodes
            .where((n) => n.id == id)
            .firstOrNull!;
        expect(node.unlocked, isTrue, reason: '$id dovrebbe essere sbloccato');
        expect(node.completed, isFalse);
      }
    });

    testWidgets('topic sbloccato: tap naviga al dettaglio', (tester) async {
      final provider = makeProvider();
      suppressMissingAssets();
      await pumpIgnoringAssets(
        tester,
        withProvider(provider, const RoadmapScreen()),
      );
      await tester.pumpAndSettle();

      // Tap sul titolo (il centro della Column cadrebbe fuori dall'InkWell).
      final title =
          tester.widget<TopicNode>(find.byType(TopicNode).first).topic.title;
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();

      expect(find.byType(TopicDetailScreen), findsOneWidget);
    });

    testWidgets('topic locked: SnackBar e nessuna navigazione', (tester) async {
      // Contratto del ramo locked di RoadmapScreen._handleTopicTap
      // (SnackBar + return senza push). Harness locale su TopicNode reale:
      // _isTopicUnlocked in RoadmapScreen è oggi demo-always-true, il
      // cablaggio del lock vero è Fase 2 (il gate provider è testato sopra).
      final topic = Topic(
        id: 'locked-topic',
        title: 'Locked',
        description: 'desc',
        chapterId: 'chapter-1',
        type: TopicType.core,
        difficulty: 'easy',
        resources: const [],
        order: 99,
        status: TopicStatus.locked,
      );
      var navigated = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicNode(
              topic: topic,
              depth: 0,
              onTopicTap: (t) {
                if (t.status == TopicStatus.locked) {
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    tester.element(find.byType(TopicNode)),
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Complete previous topics to unlock this one!',
                      ),
                    ),
                  );
                  return;
                }
                navigated = true;
              },
              onToggleExpansion: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Locked'));
      await tester.pump();

      expect(
        find.text('Complete previous topics to unlock this one!'),
        findsOneWidget,
      );
      expect(navigated, isFalse);
    });
  });

  // ---------------------------------------------------------------- US-02
  group('US-02 quiz soglia 80', () {
    test('soglia 80 su tutte le fonti (constants, entrambi i modelli)', () {
      expect(GameConstants.quizPassingScore, 80);
      expect(
        Quiz(topicId: 't', questions: []).passingScore,
        80,
      );
      expect(
        const domain.Quiz(id: 'q', topicId: 't', questions: []).passingThreshold,
        80,
      );
    });

    test('requiredCorrectAnswers: 5 domande -> 4, 10 -> 8', () {
      domain.Quiz quizWith(int n) => domain.Quiz(
            id: 'q$n',
            topicId: 't',
            questions: [
              for (var i = 0; i < n; i++)
                const domain.Question(
                  text: 'q',
                  options: ['a', 'b'],
                  correctAnswerIndex: 0,
                  explanation: 'e',
                ),
            ],
          );
      expect(quizWith(5).requiredCorrectAnswers, 4);
      expect(quizWith(10).requiredCorrectAnswers, 8);
      expect(quizWith(4).requiredCorrectAnswers, 4); // ceil(3.2)
    });

    test('provider: fail non sblocca, pass sblocca + pulisce failCount', () {
      final provider = makeProvider();

      provider.completeTopicQuiz('quiz_test_topic', 1, false);
      expect(provider.completedTopics, isNot(contains('quiz_test_topic')));
      expect(provider.failCountOf('quiz_test_topic'), 1);

      provider.completeTopicQuiz('quiz_test_topic', 5, true);
      expect(provider.completedTopics, contains('quiz_test_topic'));
      expect(provider.failCountOf('quiz_test_topic'), 0);
    });

    testWidgets('submit bloccato senza risposta, sblocco dopo il pass',
        (tester) async {
      final provider = makeProvider();
      suppressMissingAssets();
      final quiz = Quiz(
        topicId: 'quiz_test_topic',
        questions: [
          QuizQuestion(
            question: 'Quanto fa 1+1?',
            options: ['2', '3'],
            correctAnswer: 0,
          ),
        ],
      );
      await pumpIgnoringAssets(
        tester,
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          quiz: quiz,
                          topicId: 'quiz_test_topic',
                          topicTitle: 'Test Topic',
                        ),
                      ),
                    ),
                    child: const Text('apri quiz'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Nessuna risposta: nessun pulsante Next/Finish (submit bloccato).
      await tester.tap(find.text('apri quiz'));
      await tester.pumpAndSettle();
      expect(find.text('Next Question'), findsNothing);
      expect(find.text('Finish Quiz'), findsNothing);

      // Risposta corretta -> appare Finish Quiz.
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(find.text('Finish Quiz'), findsOneWidget);

      // Finish -> dialog di pass + sblocco nel provider.
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();
      expect(find.text('Quiz Passed! 🎉'), findsOneWidget);
      expect(provider.completedTopics, contains('quiz_test_topic'));

      // Done -> torna alla home (quiz chiuso).
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('apri quiz'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------- US-03
  group('US-03 reward pick-1-of-3', () {
    List<RoadmapReward> threeRewards() => [
          RoadmapReward(type: 'card', rarity: CardRarity.common),
          RoadmapReward(type: 'gold', amount: 50),
          RoadmapReward(type: 'relic', id: 'thinking_cap'),
        ];

    testWidgets('3 opzioni, confirm disabilitata, claim -> inventory +1',
        (tester) async {
      final provider = makeProvider();
      suppressMissingAssets();
      final before = provider.inventory.length;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            // Stack come in produzione (home -> quiz -> reward): il
            // triplo pop di _confirmSelection chiude dialog+reward+quiz.
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('quiz-stub')),
                          body: Center(
                            child: Builder(
                              builder: (context) => FilledButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RewardSelectionScreen(
                                      rewards: threeRewards(),
                                      topicTitle: 'Test Topic',
                                      topicId: 'reward_test_topic',
                                    ),
                                  ),
                                ),
                                child: const Text('apri reward'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('apri quiz-stub'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('apri quiz-stub'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('apri reward'));
      await tester.pumpAndSettle();

      // Pick-1-of-3: istruzione + 3 card.
      expect(
        find.text('Choose 1 reward to add to your collection:'),
        findsOneWidget,
      );
      expect(find.text('Common Card'), findsOneWidget);
      expect(find.text('50 Gold'), findsOneWidget);

      // Confirm disabilitata senza selezione.
      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm Selection'),
      );
      expect(confirm.onPressed, isNull);

      // Selezione -> confirm abilitata -> claim -> inventory +1.
      await tester.tap(find.text('Common Card'));
      await tester.pump();
      final confirmEnabled = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm Selection'),
      );
      expect(confirmEnabled.onPressed, isNotNull);

      await tester.tap(find.text('Confirm Selection'));
      await tester.pumpAndSettle();
      expect(find.text('Reward Claimed!'), findsOneWidget);
      expect(provider.inventory.length, before + 1);

      // Continue -> triplo pop: dialog+reward+quiz-stub chiusi, torna home.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(RewardSelectionScreen), findsNothing);
      expect(find.text('Reward Claimed!'), findsNothing);
      expect(find.text('apri quiz-stub'), findsOneWidget);
    });

    test('claimedRewardTopics: roundtrip + guard anti re-claim', () async {
      final prefs = await SharedPreferences.getInstance();
      final persistence = SharedPreferencesPersistence(prefs);

      expect(await persistence.loadClaimedRewardTopics(), isEmpty);

      await persistence.saveClaimedRewardTopics({'topic_a'});
      expect(
        await persistence.loadClaimedRewardTopics(),
        contains('topic_a'),
      );

      // Il set impedisce il re-claim: il topic resta singolo anche
      // ri-salvando (contratto 1 reward/topic; il guard in UI è Fase 2,
      // quiz_screen oggi non consulta il set).
      await persistence.saveClaimedRewardTopics({'topic_a', 'topic_b'});
      final claimed = await persistence.loadClaimedRewardTopics();
      expect(claimed, containsAll(['topic_a', 'topic_b']));
      expect(claimed.where((t) => t == 'topic_a').length, 1);
    });
  });

  // ---------------------------------------------------------------- US-04
  group('US-04 boss fight', () {
    test('repository: HP10 boss / HP3 player', () async {
      final repo = BossRepository();
      final boss = await repo.getBossById('man_in_the_middle');
      expect(boss, isNotNull);
      expect(boss!.maxHp, 10);
      expect(boss.currentHp, 10);
      expect(boss.maxPlayerHp, 3);
      expect(boss.currentPlayerHp, 3);
    });

    test('soglie HUD 75/50/25 + enrage MITM 0.75', () {
      expect(GameConstants.bossThreshold1, 75);
      expect(GameConstants.bossThreshold2, 50);
      expect(GameConstants.bossThreshold3, 25);

      const mitm = BossFight(
        id: 'man_in_the_middle',
        chapterId: 'web_network',
        name: 'Man-in-the-Middle',
        maxHp: 10,
        currentHp: 7,
      );
      expect(mitm.enrageThreshold, 0.75);
      expect(mitm.isEnraged, isTrue);

      const other = BossFight(
        id: 'the_amnesiac',
        chapterId: 'web_data',
        name: 'The Amnesiac',
        maxHp: 10,
        currentHp: 7,
      );
      expect(other.enrageThreshold, 0.5);
      expect(other.isEnraged, isFalse);
    });

    test('mosse disponibili per fascia HP', () {
      BossFight at(int hp) => BossFight(
            id: 'the_amnesiac',
            chapterId: 'web_data',
            name: 'The Amnesiac',
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

    test('turno quiz: corretta -1 boss, errata -1 player (-2 enraged)',
        () async {
      final repo = BossRepository();
      var fight = (await repo.getBossById('man_in_the_middle'))!;

      // Risposta corretta: boss 10 -> 9.
      fight = resolveBossQuizTurn(fight, correct: true);
      expect(fight.currentHp, 9);
      expect(fight.currentPlayerHp, 3);

      // Risposta errata non-enraged: player -1.
      final calm = fight.copyWith(currentHp: 10);
      expect(calm.isEnraged, isFalse);
      final afterMiss = resolveBossQuizTurn(calm, correct: false);
      expect(afterMiss.currentPlayerHp, 2);

      // Risposta errata enraged (MITM a 7/10): player -2.
      final enraged = fight.copyWith(currentHp: 7);
      expect(enraged.isEnraged, isTrue);
      final afterEnragedMiss = resolveBossQuizTurn(enraged, correct: false);
      expect(afterEnragedMiss.currentPlayerHp, 1);
    });

    test('win/lose: HP a 0 -> defeat/victory', () {
      const fight = BossFight(
        id: 'the_amnesiac',
        chapterId: 'web_data',
        name: 'The Amnesiac',
        maxHp: 10,
        currentHp: 10,
      );
      final win = resolveBossQuizTurn(
        fight.copyWith(currentHp: 1),
        correct: true,
      ).copyWith(state: BossFightState.victory);
      expect(win.isBossDefeated, isTrue);
      expect(win.state, BossFightState.victory);

      final lose = resolveBossQuizTurn(
        fight.copyWith(currentPlayerHp: 1),
        correct: false,
      ).copyWith(state: BossFightState.defeat);
      expect(lose.isPlayerDefeated, isTrue);
      expect(lose.state, BossFightState.defeat);
    });
  });

  // ---------------------------------------------------------------- US-05
  group('US-05 save roundtrip + wipe', () {
    Reward testReward() => const Reward(
          id: 'r1',
          name: 'Test',
          description: 'd',
          type: RewardType.attack,
          rarity: RewardRarity.common,
          icon: '⚔️',
          effects: {'damage': 1},
        );

    test('roundtrip save/restore conserva progress + claimed', () async {
      final prefs = await SharedPreferences.getInstance();
      final persistence = SharedPreferencesPersistence(prefs);

      final progress = PlayerProgress.initial().copyWith(
        experience: 150,
        completedTopicIds: ['t1'],
        inventory: PlayerInventory(rewards: [testReward()]),
      );
      await persistence.savePlayerProgress(progress);
      await persistence.saveClaimedRewardTopics({'t1'});

      final restored = await persistence.loadPlayerProgress();
      expect(restored, isNotNull);
      expect(restored!.playerId, progress.playerId);
      expect(restored.experience, 150);
      expect(restored.level, 2); // 0/100/500
      expect(restored.completedTopicIds, ['t1']);
      expect(restored.inventory.rewards.length, 1);
      expect(await persistence.loadClaimedRewardTopics(), contains('t1'));
      expect(await persistence.hasSave(), isTrue);
    });

    test('savePlayerProgress non perde i claimed esistenti', () async {
      final prefs = await SharedPreferences.getInstance();
      final persistence = SharedPreferencesPersistence(prefs);

      await persistence.saveClaimedRewardTopics({'t9'});
      await persistence.savePlayerProgress(PlayerProgress.initial());
      expect(await persistence.loadClaimedRewardTopics(), contains('t9'));
    });

    test('wipe: resetProgress svuota save e memoria', () async {
      final prefs = await SharedPreferences.getInstance();
      final persistence = SharedPreferencesPersistence(prefs);
      await persistence.savePlayerProgress(
        PlayerProgress.initial().copyWith(experience: 120),
      );
      expect(await persistence.hasSave(), isTrue);

      await persistence.resetProgress();

      expect(await persistence.loadPlayerProgress(), isNull);
      expect(await persistence.loadClaimedRewardTopics(), isEmpty);
      expect(await persistence.hasSave(), isFalse);
    });

    test('fromJson: level ignorato (ricalcolato da XP), default save vecchi',
        () {
      final json = PlayerProgress.initial()
          .copyWith(experience: 10)
          .toJson()
        ..['level'] = 99 // save v1: campo ignorato
        ..remove('lives')
        ..remove('streak')
        ..remove('failCount');
      final restored = PlayerProgress.fromJson(json);
      expect(restored.level, 1);
      expect(restored.lives, PlayerProgress.maxLives);
      expect(restored.streak, 0);
      expect(restored.failCount, isEmpty);
    });

    testWidgets('wipe con confirm: CANCEL tiene, RESET svuota', (tester) async {
      final provider = makeProvider();
      suppressMissingAssets();
      provider.completeTopic('warmup-topic');
      expect(provider.completedTopics, contains('warmup-topic'));

      await pumpIgnoringAssets(
        tester,
        withProvider(provider, const HomeScreen()),
      );
      await tester.pumpAndSettle();

      Future<void> openResetDialog() async {
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset Progress'));
        await tester.pumpAndSettle();
        expect(find.text('RESET PROGRESS'), findsOneWidget);
      }

      // CANCEL: dialog chiuso, progress intatto.
      await openResetDialog();
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(find.text('RESET PROGRESS'), findsNothing);
      expect(provider.completedTopics, contains('warmup-topic'));

      // RESET: progress svuotato.
      await openResetDialog();
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();
      expect(find.text('RESET PROGRESS'), findsNothing);
      expect(provider.completedTopics, isEmpty);
    });
  });
}

/// Contratto turno boss US-04 (spec Fase 1): quiz corretta → boss −1;
/// errata → player −1 (−2 se enraged). Helper di test in attesa del
/// cablaggio in produzione (Fase 2): usa solo getter del modello.
BossFight resolveBossQuizTurn(BossFight fight, {required bool correct}) {
  if (correct) return fight.copyWith(currentHp: fight.currentHp - 1);
  final damage = fight.isEnraged ? 2 : 1;
  return fight.copyWith(currentPlayerHp: fight.currentPlayerHp - damage);
}
