import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/data/services/engine_client.dart';
import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/main.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/leaderboard_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// Regression test per 3 bug visti su Linux reale.
///
/// Si eseguono PRIMA del fix (devono fallire) e DOPO (devono passare).

Reward _testReward(String id) => Reward(
      id: id,
      name: 'Card $id',
      description: 'desc',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: 'sword',
      effects: const {'damage': 2},
    );

Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

/// Rispecchia la struttura reale di [MyAppRoot]: i ViewModel sono forniti
/// SOPRA il MaterialApp, quindi TUTTE le route pushate (Classifica,
/// Settings, Roadmap) li ereditano.
Future<void> _pumpHome(
  WidgetTester tester,
  PlayerViewModel player,
  RoadmapViewModel roadmap,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: player),
        ChangeNotifierProvider.value(value: roadmap),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

MockClient _boardClient() {
  return MockClient((request) async {
    if (request.url.path.endsWith('/auth')) {
      return http.Response(jsonEncode({'token': 'tok123'}), 200);
    }
    if (request.url.path.contains('/classifications/')) {
      return http.Response(
        jsonEncode({
          'board': {
            'content': [
              {'position': 1, 'playerId': 'slay_me', 'score': 300},
              {'position': 2, 'playerId': 'slay_other', 'score': 100},
            ],
          },
        }),
        200,
      );
    }
    return http.Response('not found', 404);
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BUG 1 — avvio sempre su login/registrazione', () {
    test('restore NON riapre mai l\'ultimo utente', () async {
      final store = await _store();
      final first = SessionController(store);
      await first.register(username: 'Ada', password: 'x');
      first.player!.addCompletedTopic('web_network');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(store.activeUser(), isNotNull);

      final second = SessionController(store);
      await second.restore();

      expect(second.ready, isTrue);
      expect(second.isLoggedIn, isFalse);
      expect(second.activeProfile, isNull);
      expect(second.player, isNull);

      // Il profilo si carica SOLO dopo login esplicito ( coi progressi).
      final back =
          await second.login(username: 'Ada', password: 'x');
      expect(back, isNotNull);
      expect(second.isLoggedIn, isTrue);
      expect(
        second.player!.progress.completedTopicIds,
        ['web_network'],
      );
    });

    testWidgets('bootstrap con utente persistito mostra ProfileSwitchScreen',
        (tester) async {
      final store = await _store();
      await tester.runAsync(() async {
        final first = SessionController(store);
        await first.register(username: 'Ada', password: 'x');
      });
      expect(store.activeUser(), isNotNull);

      final boot = SessionController(store);
      await tester.runAsync(() async {
        await boot.restore();
      });

      await tester.pumpWidget(MyAppRoot(session: boot));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_new_button')), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(
        find.byKey(const Key('campaign_web_foundations')),
        findsNothing,
      );
    });
  });

  group('BUG 2 — Classifica senza crash', () {
    testWidgets(
        'push da Home reale con engine Http SENZA credenziali → offline, no crash',
        (tester) async {
      final player = PlayerViewModel(engine: HttpEngineClient());
      await _pumpHome(
        tester,
        player,
        RoadmapViewModel(LocalRoadmapRepository()),
      );

      await tester.tap(find.text('🏆 CLASSIFICA'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('leaderboard_offline')),
        findsOneWidget,
      );
    });

    testWidgets(
        'push da Home reale con engine Http CON credenziali → righe, no crash',
        (tester) async {
      final player = PlayerViewModel(
        engine: HttpEngineClient(
          client: _boardClient(),
          baseUrl: 'https://example.test/api/v1',
          username: 'tester',
          password: 'secret',
        ),
        hubPlayerId: 'slay_me',
      );
      await _pumpHome(
        tester,
        player,
        RoadmapViewModel(LocalRoadmapRepository()),
      );

      await tester.tap(find.text('🏆 CLASSIFICA'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leaderboard_row_1')), findsOneWidget);
      expect(find.text('slay_me • Tu'), findsOneWidget);
    });

    testWidgets(
        'LeaderboardScreen senza provider e senza override → offline, mai throw',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LeaderboardScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('leaderboard_offline')),
        findsOneWidget,
      );
    });
  });

  group('BUG 3 — reset totale da Settings', () {
    test('wipe: progress+claimed+fail/streak azzerati, vite a 3, storage pulito',
        () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      await session.selectCampaign('web_foundations');
      final player = session.player!;
      player.addCompletedTopic('web_network');
      player.claimReward('web_network', _testReward('r1'));
      player.recordQuizFail('net_client_server');
      player.recordQuizFail('net_client_server');
      player.recordBossDefeat();
      expect(player.progress.lives, 2);
      expect(player.failCountOf('net_client_server'), 2);
      await Future.delayed(const Duration(milliseconds: 100));

      await player.wipe();
      await session.roadmap!.resetToInitial();

      // Memoria: reset totale, vite a 3 (decisione documentata in wipe()).
      expect(player.hasProgress, isFalse);
      expect(player.progress.completedTopicIds, isEmpty);
      expect(player.claimedRewardTopics, isEmpty);
      expect(player.progress.lives, 3);
      expect(player.progress.streak, 0);
      expect(player.progress.maxStreak, 0);
      expect(player.failCountOf('net_client_server'), 0);
      expect(player.inventory.rewards, isEmpty);
      expect(player.progress.bossFights, isEmpty);
      // Identità profilo conservata.
      expect(player.progress.playerName, 'Ada');

      // Storage riletto: bucket campagna pulito, sessione intatta.
      final persistence = store.dataFor(
        session.activeProfile!.userId,
        campaignId: session.activeCampaignId,
      );
      expect(await persistence.loadPlayerProgress(), isNull);
      expect(await persistence.loadClaimedRewardTopics(), isEmpty);
      expect(await persistence.hasSave(), isFalse);
      expect(session.isLoggedIn, isTrue);
      expect(session.activeCampaignId, 'web_foundations');
    });

    testWidgets('reset da Settings (push da Home reale): no eccezioni + SnackBar',
        (tester) async {
      final store = await _store();
      final session = SessionController(store);
      await tester.runAsync(() async {
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });
      session.player!.addCompletedTopic('web_network');
      session.player!.claimReward('web_network', _testReward('r1'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      expect(session.player!.hasProgress, isTrue);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: session.player!),
            ChangeNotifierProvider.value(value: session.roadmap!),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('⚙️ SETTINGS'),
        300,
      );
      await tester.tap(find.text('⚙️ SETTINGS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset progressi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();

      expect(session.player!.hasProgress, isFalse);
      expect(
        find.text('Progressi cancellati. Buona avventura!'),
        findsOneWidget,
      );

      final persistence = store.dataFor(
        session.activeProfile!.userId,
        campaignId: session.activeCampaignId,
      );
      expect(await persistence.loadPlayerProgress(), isNull);
      expect(await persistence.loadClaimedRewardTopics(), isEmpty);
    });
  });
}
