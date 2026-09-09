import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/config/hub_config.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/services/engine_client.dart';
import 'package:slay_the_roadmap/utils/constants.dart';
import 'package:slay_the_roadmap/widgets/hub_profile_card.dart';

/// Fix Hub H1-H6 (piano 2026-09-08): guard allowlist, claim_reward dal
/// pick-1-of-3, numeri allineati 100/100, boss_defeated sempre, badge remoti
/// in card, osservabilità + isHubOnline reale. TDD: nasce rosso.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  /// Provider loggato (hubPlayerId `slay_...` impostato) con engine Fake.
  Future<GameProvider> makeLogged([String user = 'hubfix']) async {
    final provider = GameProvider();
    expect(await provider.registerLocal(user, 'pw'), isTrue);
    (provider.engine as FakeEngineClient).calls.clear();
    return provider;
  }

  /// Provider loggato con engine HTTP mockato (crediti finti solo in RAM,
  /// mai nel repo). [playerState] è la risposta di GET player.
  Future<GameProvider> makeLoggedHttp({
    String user = 'hubfixhttp',
    Map<String, dynamic>? playerState,
    int executionsStatus = 200,
  }) async {
    final mock = MockClient((request) async {
      if (request.url.path.endsWith('/auth')) {
        return http.Response(jsonEncode({'token': 'tok-test'}), 200);
      }
      if (request.url.path.endsWith('/executions')) {
        return http.Response('{}', executionsStatus);
      }
      if (request.url.path.contains('/players/')) {
        if (playerState == null) return http.Response('ko', 500);
        return http.Response(jsonEncode(playerState), 200);
      }
      if (request.url.path.endsWith('/board')) {
        return http.Response(jsonEncode({'board': {'content': []}}), 200);
      }
      return http.Response('not found', 404);
    });
    final provider = GameProvider(
      engine: HttpEngineClient(
        client: mock,
        baseUrl: 'https://hub.test/api/v1',
        username: 'u',
        password: 'p',
      ),
    );
    expect(await provider.registerLocal(user, 'pw'), isTrue);
    return provider;
  }

  // ------------------------------------------------- H1 allowlist (scelta B:
  // specchio totale — 7 action contrattuali, extra veri bloccati)
  group('H1: le 7 action contrattuali partono, le altre no', () {
    test('daily_login inviato con xp_amount 25, +25 XP locali', () async {
      final provider = await makeLogged('h1daily');
      final fake = provider.engine as FakeEngineClient;

      expect(provider.claimDailyReward(), isTrue);
      await settle();

      final dailies = fake.calls
          .where((c) => c['actionId'] == 'daily_login')
          .toList();
      expect(dailies, hasLength(1));
      expect(dailies.single['data']['xp_amount'], 25);
      expect(provider.playerStats.experience, 25);
    });

    test('resource_viewed inviato (una-tantum), reward locale invariata',
        () async {
      final provider = await makeLogged('h1res');
      final fake = provider.engine as FakeEngineClient;

      final out = provider.markResourceViewed('h1topic', 0);
      await settle();

      expect(out['alreadyViewed'], isFalse);
      final views = fake.calls
          .where((c) => c['actionId'] == 'resource_viewed')
          .toList();
      expect(views, hasLength(1));
      expect(views.single['data']['xp_amount'], 30);
      expect(
        fake.calls.where((c) => c['actionId'] == 'study_resource_viewed'),
        isEmpty,
      );
      expect(provider.playerStats.experience, 30);
      expect(provider.gold, 10);
    });

    test('skill_unlocked bloccato, effetto locale invariato', () async {
      final provider = await makeLogged('h1skill');
      final fake = provider.engine as FakeEngineClient;
      final before = provider.playerStats.maxEnergy;

      provider.unlockSkill('off-tier1-energy');
      await settle();

      expect(
        provider.skillTree
            .where((s) => s.id == 'off-tier1-energy')
            .firstOrNull!
            .unlocked,
        isTrue,
      );
      expect(provider.playerStats.maxEnergy, before + 1);
      expect(
        fake.calls.where((c) => c['actionId'] == 'skill_unlocked'),
        isEmpty,
      );
    });

    test('quiz_completed / claim_reward / boss_defeated passano', () async {
      final provider = await makeLogged('h1ok');
      final fake = provider.engine as FakeEngineClient;

      provider.completeTopicQuiz('h1quiz', 8, true);
      provider.claimRewardTopic('h1quiz');
      provider.defeatBoss('syntax_sentinel');
      await settle();

      final actions = fake.calls.map((c) => c['actionId']).toSet();
      expect(actions, contains(HubConfig.quizCompletedAction));
      expect(actions, contains(HubConfig.claimRewardAction));
      expect(actions, contains(HubConfig.bossDefeatedAction));
    });
  });

  // ------------------------------------------------------- H2 claim_reward
  group('H2: claim_reward dal pick-1-of-3', () {
    test('claim invia claim_reward {badge}, re-claim nessun reinvio',
        () async {
      final provider = await makeLogged('h2claim');
      final fake = provider.engine as FakeEngineClient;

      expect(provider.claimRewardTopic('topic_claim'), isTrue);
      await settle();

      final claims = fake.calls
          .where((c) => c['actionId'] == HubConfig.claimRewardAction)
          .toList();
      expect(claims, hasLength(1));
      expect(claims.single['data']['badge'], 'topic_claim');

      expect(provider.claimRewardTopic('topic_claim'), isFalse);
      await settle();
      expect(
        fake.calls.where((c) => c['actionId'] == HubConfig.claimRewardAction),
        hasLength(1),
      );
    });
  });

  // ------------------------------------------------------ H3 numeri 100/100
  group('H3: numeri allineati Hub=locale', () {
    test('quiz pass → +100 XP (quizXpAmount), payload xp_amount 100',
        () async {
      final provider = await makeLogged('h3quiz');
      final fake = provider.engine as FakeEngineClient;

      // score 4: col vecchio 50+score*10 sarebbero 90, ora 100.
      provider.completeTopicQuiz('h3topic', 4, true);
      await settle();

      expect(provider.playerStats.experience, HubConfig.quizXpAmount);
      expect(provider.playerStats.experience, 100);
      final quiz = fake.calls
          .where((c) => c['actionId'] == HubConfig.quizCompletedAction)
          .single;
      expect(quiz['data']['xp_amount'], 100);
    });

    test('vittoria boss → +100 XP (costante allineata)', () async {
      expect(GameConstants.xpPerBossDefeated, 100);
      final provider = await makeLogged('h3boss');

      // Boss senza nodo: solo gli XP vittoria, niente reward di nodo.
      provider.defeatBoss('h3_boss_solo');

      expect(provider.playerStats.experience, 100);
      expect(provider.badges, contains('boss:h3_boss_solo'));
    });

    test('livelli 0/100/500 invariati', () {
      expect(PlayerProgress.levelForXp(0), 1);
      expect(PlayerProgress.levelForXp(99), 1);
      expect(PlayerProgress.levelForXp(100), 2);
      expect(PlayerProgress.levelForXp(499), 2);
      expect(PlayerProgress.levelForXp(500), 3);
    });
  });

  // ------------------------------------------------- H4 boss sempre inviato
  group('H4: boss_defeated anche senza nodo', () {
    test('boss senza nodo → evento inviato, nessun unlock fantasma',
        () async {
      final provider = await makeLogged('h4ghost');
      final fake = provider.engine as FakeEngineClient;
      final unlockedBefore = provider.roadmapNodes
          .where((n) => n.unlocked)
          .map((n) => n.id)
          .toSet();

      provider.defeatBoss('fantasma_inesistente');
      await settle();

      final events = fake.calls
          .where((c) => c['actionId'] == HubConfig.bossDefeatedAction)
          .toList();
      expect(events, hasLength(1));
      expect(events.single['data']['badge'], 'fantasma_inesistente');
      expect(provider.badges, contains('boss:fantasma_inesistente'));
      // Nessun unlock fantasma: i nodi sbloccati sono gli stessi di prima
      // (i nodi roadmap sono shallow-copy dei dati statici: confronto
      // differenziale, non assoluto, per isolamento tra test).
      final unlockedAfter = provider.roadmapNodes
          .where((n) => n.unlocked)
          .map((n) => n.id)
          .toSet();
      expect(unlockedAfter, unlockedBefore);
    });
  });

  // ---------------------------------------------------- H5 badge in card
  group('H5: HubProfileCard mostra i badge remoti', () {
    Map<String, dynamic> stateWith(List<String> badges) => {
          'pointConcepts': [
            {'name': 'xp', 'score': 200}
          ],
          'levels': [
            {'levelValue': 'Level 2'}
          ],
          'badges': badges,
        };

    Future<void> pumpCard(WidgetTester tester, GameProvider provider) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: HubProfileCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('state con badge → chip visibili', (tester) async {
      final provider = await makeLoggedHttp(
        user: 'h5badges',
        playerState: stateWith(['dart_basics', 'syntax_guardian']),
      );
      await pumpCard(tester, provider);

      expect(find.text('dart_basics'), findsOneWidget);
      expect(find.text('syntax_guardian'), findsOneWidget);
    });

    testWidgets('state senza badge → empty-state', (tester) async {
      final provider = await makeLoggedHttp(
        user: 'h5empty',
        playerState: stateWith([]),
      );
      await pumpCard(tester, provider);

      expect(find.text('Nessun badge Hub.'), findsOneWidget);
    });
  });

  // ------------------------------------------------------ H6 osservabilità
  group('H6: isHubOnline reale + log successi', () {
    test('Fake/offline → sempre false', () async {
      final provider = await makeLogged('h6fake');
      expect(provider.isHubOnline, isFalse);
    });

    test('Http: falso prima del contatto, vero dopo execute ok', () async {
      final provider = await makeLoggedHttp(user: 'h6http');
      expect(provider.isHubOnline, isFalse);

      provider.completeTopicQuiz('h6topic', 8, true);
      await settle();

      expect(provider.isHubOnline, isTrue);
    });

    test('HttpEngineClient: 401 → false, mai throw', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        return http.Response('unauthorized', 401);
      });
      final engine = HttpEngineClient(
        client: mock,
        baseUrl: 'https://hub.test/api/v1',
        username: 'u',
        password: 'p',
      );
      expect(engine.hasContactOk, isFalse);
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_x'),
        isFalse,
      );
      expect(engine.hasContactOk, isFalse);
    });
  });
}
