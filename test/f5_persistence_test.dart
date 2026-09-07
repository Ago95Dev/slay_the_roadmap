import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/quiz.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/settings_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// F5 (US-05): autosave — roundtrip save/load, restore con unlock,
/// wipe, reset da settings, fix fromJson adaptiveQuizzes.

Reward _testReward(String id) => Reward(
      id: id,
      name: 'Card $id',
      description: 'desc',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: 'sword',
      effects: const {'damage': 2},
    );

Topic? _findTopic(List<Topic> topics, String id) {
  for (final topic in topics) {
    if (topic.id == id) return topic;
    final found = _findTopic(topic.subtopics, id);
    if (found != null) return found;
  }
  return null;
}

Future<SharedPreferencesPersistence> _persistence() async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesPersistence(prefs);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesPersistence roundtrip', () {
    test('save/load preserva progress + claimed', () async {
      final persistence = await _persistence();
      final progress = PlayerProgress.initial().copyWith(
        playerName: 'Hero',
        experience: 200,
        completedTopicIds: const ['web_network', 'net_client_server'],
        inventory: PlayerInventory(rewards: [_testReward('r1')]),
      );

      await persistence.savePlayerProgress(progress);
      await persistence.saveClaimedRewardTopics({'web_network'});

      final restored = await persistence.loadPlayerProgress();
      expect(restored, isNotNull);
      expect(restored!.playerName, 'Hero');
      expect(restored.experience, 200);
      expect(restored.completedTopicIds, ['web_network', 'net_client_server']);
      expect(restored.inventory.rewards.single.id, 'r1');
      expect(
        await persistence.loadClaimedRewardTopics(),
        {'web_network'},
      );
      expect(await persistence.hasSave(), isTrue);
    });

    test('fromJson preserva adaptiveQuizzes del boss', () async {
      final persistence = await _persistence();
      const boss = BossFight(
        id: 'boss1',
        chapterId: 'ch1',
        name: 'Bug King',
        maxHp: 10,
        currentHp: 8,
        adaptiveQuizzes: [
          const Quiz(
            id: 'q1',
            topicId: 'web_network',
            questions: [
              Question(
                text: 'Q?',
                options: ['a', 'b'],
                correctAnswerIndex: 0,
                explanation: 'exp',
              ),
            ],
          ),
        ],
      );
      final progress = PlayerProgress.initial().copyWith(
        bossFights: {'boss1': boss},
      );

      await persistence.savePlayerProgress(progress);
      final restored = await persistence.loadPlayerProgress();

      expect(restored, isNotNull);
      final restoredBoss = restored!.bossFights['boss1'];
      expect(restoredBoss, isNotNull);
      expect(restoredBoss!.adaptiveQuizzes, hasLength(1));
      expect(restoredBoss.adaptiveQuizzes.single.id, 'q1');
      expect(
        restoredBoss.adaptiveQuizzes.single.questions.single.text,
        'Q?',
      );
    });

    test('fromJson clampa le vecchie carte a max 2', () async {
      final persistence = await _persistence();
      final progress = PlayerProgress.initial().copyWith(
        inventory: const PlayerInventory(rewards: [
          Reward(
            id: 'fireball',
            name: 'Fireball',
            description: 'vecchia carta pre-campagna',
            type: RewardType.attack,
            rarity: RewardRarity.common,
            icon: '🔥',
            effects: {'damage': 15, 'block': 10, 'heal': 25},
          ),
        ]),
      );

      await persistence.savePlayerProgress(progress);
      final restored = await persistence.loadPlayerProgress();

      expect(restored, isNotNull);
      final effects = restored!.inventory.rewards.single.effects;
      expect(effects['damage'], 2);
      expect(effects['block'], 2);
      expect(effects['heal'], 2);
    });
  });

  group('Restore applica completed + unlock', () {
    test('applyCompletedTopics completa e sblocca i dipendenti', () async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();

      vm.applyCompletedTopics(['web_network']);

      expect(
        _findTopic(vm.topics, 'web_network')?.status,
        TopicStatus.completed,
      );
      expect(
        _findTopic(vm.topics, 'net_client_server')?.status,
        TopicStatus.inProgress,
      );
      // Id sconosciuti ignorati, senza eccezioni.
      vm.applyCompletedTopics(['topic_inesistente']);
    });

    test('resetToInitial torna allo stato seed', () async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();
      vm.applyCompletedTopics(['web_network']);
      expect(
        _findTopic(vm.topics, 'web_network')?.status,
        TopicStatus.completed,
      );

      await vm.resetToInitial();

      expect(
        _findTopic(vm.topics, 'web_network')?.status,
        TopicStatus.inProgress,
      );
      expect(
        _findTopic(vm.topics, 'net_client_server')?.status,
        TopicStatus.locked,
      );
    });
  });

  group('PlayerViewModel autosave + wipe', () {
    test('mutazioni salvano, load() ripristina', () async {
      final persistence = await _persistence();
      final vm = PlayerViewModel(persistence: persistence);
      vm.addCompletedTopic('web_network');
      vm.claimReward('web_network', _testReward('r1'));
      // Autosave fire-and-forget: attende il flush.
      await Future.delayed(const Duration(milliseconds: 100));

      final vm2 = PlayerViewModel(persistence: persistence);
      expect(await vm2.load(), isTrue);
      expect(vm2.progress.completedTopicIds, ['web_network']);
      expect(vm2.isTopicClaimed('web_network'), isTrue);
      expect(vm2.inventory.rewards.single.id, 'r1');
    });

    test('wipe pulisce memoria e save', () async {
      final persistence = await _persistence();
      final vm = PlayerViewModel(persistence: persistence);
      vm.addCompletedTopic('web_network');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(await persistence.hasSave(), isTrue);

      await vm.wipe();

      expect(vm.hasProgress, isFalse);
      expect(vm.progress.completedTopicIds, isEmpty);
      expect(vm.claimedRewardTopics, isEmpty);
      expect(await persistence.hasSave(), isFalse);
      expect(await persistence.loadPlayerProgress(), isNull);
    });

    test('load senza save ritorna false', () async {
      final persistence = await _persistence();
      final vm = PlayerViewModel(persistence: persistence);
      expect(await vm.load(), isFalse);
    });
  });

  group('Home + Settings', () {
    testWidgets('CONTINUA visibile solo con progressi', (tester) async {
      Future<void> pump(PlayerViewModel vm) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: vm),
              ChangeNotifierProvider(
                create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump(PlayerViewModel());
      expect(find.textContaining('CONTINUA'), findsNothing);
      expect(find.textContaining('INIZIA IL PERCORSO'), findsOneWidget);

      final withProgress = PlayerViewModel();
      withProgress.addCompletedTopic('web_network');
      await pump(withProgress);
      expect(find.textContaining('CONTINUA'), findsOneWidget);
      expect(find.textContaining('NUOVO PERCORSO'), findsOneWidget);
      // Card §2 OUT rimosse.
      expect(find.textContaining('PROFILE'), findsNothing);
      expect(find.textContaining('ACHIEVEMENTS'), findsNothing);
    });

    testWidgets('Reset da Settings cancella i progressi', (tester) async {
      final vm = PlayerViewModel(persistence: await _persistence());
      vm.addCompletedTopic('web_network');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: vm),
            ChangeNotifierProvider(
              create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset progressi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RESET'));
      await tester.pump();
      // Flush del delay di loadRoadmap (resetToInitial) in fake-async.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(vm.hasProgress, isFalse);
    });
  });
}
