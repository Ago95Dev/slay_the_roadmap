import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/config/hub_config.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/services/engine_client.dart';

/// H7 — Test Hub completi con mock HTTP (piano 2026-09-08).
///
/// Copre il contratto `docs/assignment/hub_setup.md` senza rete reale:
/// login shape, payload execute, parse board/player, offline best-effort
/// (mai throw) e cablaggio quiz/claim/boss/extra. Solo mock in RAM,
/// nessuna credenziale reale, nessuna nuova dipendenza
/// (`package:http/testing.dart` è parte di `http`).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  HttpEngineClient engineWithMock(
    MockClient mock, {
    String user = 'tester',
    String pass = 'secret',
  }) {
    return HttpEngineClient(
      client: mock,
      baseUrl: 'https://hub.test/api/v1',
      username: user,
      password: pass,
    );
  }

  // ------------------------------------------------------------ login shape
  group('login shape', () {
    test('POST /auth con username/password/origin GAME, Bearer riusato',
        () async {
      var authCalls = 0;
      Map<String, dynamic>? authBody;
      String? authPath;
      final executionsAuth = <String?>[];
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          authCalls++;
          authPath = request.url.path;
          authBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({'token': 'tok123'}), 200);
        }
        if (request.url.path.endsWith('/executions')) {
          executionsAuth.add(request.headers['Authorization']);
          return http.Response('{}', 200);
        }
        return http.Response('not found', 404);
      });
      final engine = engineWithMock(mock);

      expect(await engine.login(), isTrue);
      expect(authCalls, 1);
      expect(authPath, endsWith('/auth'));
      expect(authBody!['username'], 'tester');
      expect(authBody!['password'], 'secret');
      expect(authBody!['origin'], 'GAME');

      // Token salvato: due execute riusano il Bearer senza nuovo login.
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isTrue,
      );
      expect(
        await engine.execute(actionId: 'boss_defeated', playerId: 'slay_1'),
        isTrue,
      );
      expect(authCalls, 1, reason: 'token salvato, nessun re-login');
      expect(executionsAuth, ['Bearer tok123', 'Bearer tok123']);
    });

    test('401 → false senza throw, token non salvato', () async {
      var authCalls = 0;
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          authCalls++;
          return http.Response('unauthorized', 401);
        }
        return http.Response('unauthorized', 401);
      });
      final engine = engineWithMock(mock);

      expect(await engine.login(), isFalse);
      expect(authCalls, 1);
      // execute prova il login (fallito) e ritorna false senza lanciare.
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isFalse,
      );
      expect(engine.hasContactOk, isFalse);
    });
  });

  // ---------------------------------------------------------- execute shape
  group('execute shape', () {
    test('payload gameId/actionId/playerId/data in snake_case', () async {
      Map<String, dynamic>? sent;
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      });
      final engine = engineWithMock(mock);

      final ok = await engine.execute(
        actionId: HubConfig.quizCompletedAction,
        playerId: 'slay_42',
        data: {'xp_amount': HubConfig.quizXpAmount, 'badge': 'web_network'},
      );

      expect(ok, isTrue);
      expect(sent!['gameId'], HubConfig.gameId);
      expect(sent!['actionId'], 'quiz_completed');
      expect(sent!['playerId'], 'slay_42');
      expect(
        sent!['data'],
        {'xp_amount': HubConfig.quizXpAmount, 'badge': 'web_network'},
      );
      expect(sent, isNot(contains('game_id')));
      expect(sent, isNot(contains('action_id')));
      expect(sent, isNot(contains('player_id')));
    });

    test('data:{} di default quando assente', () async {
      String? raw;
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        raw = request.body;
        return http.Response('{}', 200);
      });
      final engine = engineWithMock(mock);

      expect(
        await engine.execute(
          actionId: HubConfig.claimRewardAction,
          playerId: 'slay_1',
        ),
        isTrue,
      );
      expect((jsonDecode(raw!) as Map<String, dynamic>)['data'], {});
    });

    test('quiz_completed porta xp_amount 100', () async {
      Map<String, dynamic>? sent;
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      });
      final engine = engineWithMock(mock);

      expect(
        await engine.execute(
          actionId: HubConfig.quizCompletedAction,
          playerId: 'slay_7',
          data: {'xp_amount': HubConfig.quizXpAmount, 'badge': 'dart_basics'},
        ),
        isTrue,
      );
      expect(sent!['data']['xp_amount'], 100);
    });

    test('errore HTTP → false senza throw', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        return http.Response('ko', 500);
      });
      final engine = engineWithMock(mock);

      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------- leaderboard
  group('getLeaderboard', () {
    MockClient boardMock(Object Function() body, [int status = 200]) {
      return MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        if (request.url.path.endsWith('/board')) {
          if (status != 200) return http.Response('ko', status);
          return http.Response(jsonEncode(body()), 200);
        }
        return http.Response('not found', 404);
      });
    }

    test('parse entries playerId/score/position', () async {
      final engine = engineWithMock(
        boardMock(
          () => {
            'board': {
              'content': [
                {'position': 1, 'playerId': 'slay_1', 'score': 500},
                {'position': 2, 'playerId': 'slay_2', 'score': 100},
              ],
            },
          },
        ),
      );

      final entries = await engine.getLeaderboard();
      expect(entries, hasLength(2));
      expect(entries[0].position, 1);
      expect(entries[0].playerId, 'slay_1');
      expect(entries[0].score, 500);
      expect(entries[1].position, 2);
      expect(entries[1].playerId, 'slay_2');
      expect(entries[1].score, 100);
    });

    test('board vuota → lista vuota', () async {
      final engine = engineWithMock(
        boardMock(() => {'board': {'content': []}}),
      );

      expect(await engine.getLeaderboard(), isEmpty);
    });

    test('errore HTTP → lista vuota senza throw', () async {
      final engine = engineWithMock(boardMock(() => {}, 500));

      expect(await engine.getLeaderboard(), isEmpty);
      expect(engine.hasContactOk, isFalse);
    });
  });

  // ---------------------------------------------------------- player state
  group('getPlayerState', () {
    test('parse livelli/punteggio/badges', () async {
      final state = {
        'playerId': 'slay_1',
        'pointConcepts': [
          {'name': 'xp', 'score': 200},
        ],
        'levels': [
          {'levelValue': 'Level 2'},
        ],
        'badges': ['dart_basics', 'syntax_guardian'],
      };
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        if (request.url.path.contains('/players/')) {
          return http.Response(jsonEncode(state), 200);
        }
        return http.Response('not found', 404);
      });
      final engine = engineWithMock(mock);

      final got = await engine.getPlayerState('slay_1');
      expect(got, isNotNull);
      expect(got!['badges'], ['dart_basics', 'syntax_guardian']);
      expect(got['levels'], [
        {'levelValue': 'Level 2'},
      ]);
      expect(got['pointConcepts'], [
        {'name': 'xp', 'score': 200},
      ]);
    });

    test('404 → null senza throw', () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'token': 'tok'}), 200);
        }
        return http.Response('not found', 404);
      });
      final engine = engineWithMock(mock);

      expect(await engine.getPlayerState('slay_missing'), isNull);
    });
  });

  // -------------------------------------------------------------- offline
  group('offline senza rete (SocketException)', () {
    MockClient throwingMock() {
      return MockClient((_) async {
        throw const SocketException('rete assente');
      });
    }

    test('login/execute/board/player → false/vuoto/null, mai throw',
        () async {
      final engine = engineWithMock(throwingMock());

      expect(await engine.login(), isFalse);
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isFalse,
      );
      expect(await engine.getLeaderboard(), isEmpty);
      expect(await engine.getPlayerState('slay_1'), isNull);
      expect(engine.hasContactOk, isFalse);
    });
  });

  // --------------------------------------------------------------- wiring
  group('wiring GameProvider → Hub (Fake offline)', () {
    Future<GameProvider> makeLogged(String user) async {
      final provider = GameProvider();
      expect(await provider.registerLocal(user, 'pw'), isTrue);
      (provider.engine as FakeEngineClient).calls.clear();
      return provider;
    }

    test('quiz pass → quiz_completed chiamato 1 volta', () async {
      final provider = await makeLogged('h7quiz');
      final fake = provider.engine as FakeEngineClient;

      provider.completeTopicQuiz('h7topic', 8, true);
      await settle();

      final quiz = fake.calls
          .where((c) => c['actionId'] == HubConfig.quizCompletedAction)
          .toList();
      expect(quiz, hasLength(1));
      expect(quiz.single['data']['xp_amount'], 100);
      expect(quiz.single['data']['badge'], 'h7topic');
    });

    test('re-claim → claim_reward 1 sola volta', () async {
      final provider = await makeLogged('h7claim');
      final fake = provider.engine as FakeEngineClient;

      expect(provider.claimRewardTopic('h7reward'), isTrue);
      await settle();
      expect(provider.claimRewardTopic('h7reward'), isFalse);
      await settle();

      final claims = fake.calls
          .where((c) => c['actionId'] == HubConfig.claimRewardAction)
          .toList();
      expect(claims, hasLength(1));
      expect(claims.single['data']['badge'], 'h7reward');
    });

    test('boss senza nodo → boss_defeated chiamato', () async {
      final provider = await makeLogged('h7boss');
      final fake = provider.engine as FakeEngineClient;

      provider.defeatBoss('boss_fantasma_h7');
      await settle();

      final events = fake.calls
          .where((c) => c['actionId'] == HubConfig.bossDefeatedAction)
          .toList();
      expect(events, hasLength(1));
      expect(events.single['data']['badge'], 'boss_fantasma_h7');
      expect(provider.badges, contains('boss:boss_fantasma_h7'));
    });

    test('extra daily_login → MAI chiamato', () async {
      final provider = await makeLogged('h7extra');
      final fake = provider.engine as FakeEngineClient;

      expect(provider.claimDailyReward(), isTrue);
      await settle();

      expect(
        fake.calls.where((c) => c['actionId'] == 'daily_login'),
        isEmpty,
      );
    });
  });
}
