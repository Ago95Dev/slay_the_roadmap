import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/config/hub.dart';
import 'package:slay_the_roadmap/data/services/engine_client.dart';
import 'package:slay_the_roadmap/data/services/hub_identity.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';

/// F7 (Hub minimo, offline-first): shape payload, login, fallback offline,
/// cablaggio quiz/boss best-effort, playerId stabile.

const _user = 'tester';
const _pass = 'secret';

http.Client _mockHub({
  required void Function(http.Request request) onExecution,
  String loginToken = 'tok123',
  int executionsStatus = 200,
}) {
  return MockClient((request) async {
    if (request.url.path.endsWith('/auth')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['origin'], 'GAME');
      expect(body['username'], _user);
      expect(body['password'], _pass);
      return http.Response(jsonEncode({'token': loginToken}), 200);
    }
    if (request.url.path.endsWith('/executions')) {
      expect(
        request.headers['Authorization'],
        'Bearer $loginToken',
        reason: 'Bearer del login',
      );
      onExecution(request);
      return http.Response('{}', executionsStatus);
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('HttpEngineClient', () {
    test('login: POST /auth con origin GAME e parsing token', () async {
      var authCalls = 0;
      Map<String, dynamic>? authBody;
      final client = MockClient((request) async {
        authCalls++;
        authBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'token': 'abc'}), 200);
      });
      final engine = HttpEngineClient(
        client: client,
        baseUrl: 'https://example.test/api/v1',
        username: _user,
        password: _pass,
      );
      expect(await engine.login(), isTrue);
      expect(authCalls, 1);
      expect(authBody!['origin'], 'GAME');
      expect(authBody!['username'], _user);
      expect(authBody!['password'], _pass);
    });

    test('login: tollera forma access_token e la riusa come Bearer', () async {
      String? auth;
      final combined = MockClient((request) async {
        if (request.url.path.endsWith('/auth')) {
          return http.Response(jsonEncode({'access_token': 'xyz'}), 200);
        }
        auth = request.headers['Authorization'];
        return http.Response('{}', 200);
      });
      final engine = HttpEngineClient(
        client: combined,
        username: _user,
        password: _pass,
      );
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isTrue,
      );
      expect(auth, 'Bearer xyz');
    });

    test('execute: shape payload gameId/actionId/playerId/data', () async {
      Map<String, dynamic>? sent;
      final engine = HttpEngineClient(
        client: _mockHub(
          onExecution: (request) {
            sent = jsonDecode(request.body) as Map<String, dynamic>;
          },
        ),
        username: _user,
        password: _pass,
      );
      final ok = await engine.execute(
        actionId: HubConfig.quizCompletedAction,
        playerId: 'slay_42',
        data: {'xp_amount': 100, 'badge': 'web_network'},
      );
      expect(ok, isTrue);
      expect(sent!['gameId'], HubConfig.gameId);
      expect(sent!['actionId'], 'quiz_completed');
      expect(sent!['playerId'], 'slay_42');
      expect(sent!['data'], {'xp_amount': 100, 'badge': 'web_network'});
    });

    test('execute: data sempre presente anche {}', () async {
      String? raw;
      final engine = HttpEngineClient(
        client: _mockHub(onExecution: (request) => raw = request.body),
        username: _user,
        password: _pass,
      );
      expect(
        await engine.execute(actionId: 'claim_reward', playerId: 'slay_1'),
        isTrue,
      );
      expect((jsonDecode(raw!) as Map)['data'], {});
    });

    test('execute: errore HTTP → false, mai throw', () async {
      final engine = HttpEngineClient(
        client: _mockHub(onExecution: (_) {}, executionsStatus: 500),
        username: _user,
        password: _pass,
      );
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isFalse,
      );
    });

    test('offline senza credenziali: false senza toccare la rete', () async {
      final throwing = MockClient((_) async {
        throw StateError('non deve chiamare la rete');
      });
      final engine = HttpEngineClient(
        client: throwing,
        username: '',
        password: '',
      );
      expect(engine.isOffline, isTrue);
      expect(await engine.login(), isFalse);
      expect(
        await engine.execute(actionId: 'quiz_completed', playerId: 'slay_1'),
        isFalse,
      );
    });
  });

  group('HubIdentity', () {
    test('slay_<...> stabile tra letture', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = await HubIdentity.loadOrCreate(prefs);
      expect(first.startsWith('slay_'), isTrue);
      final second = await HubIdentity.loadOrCreate(prefs);
      expect(second, first);
    });
  });

  group('Cablaggio PlayerViewModel (best-effort)', () {
    BossFight boss() => const BossFight(
          id: 'man_in_the_middle',
          chapterId: 'c1',
          name: 'Man-in-the-Middle',
          maxHp: 10,
          currentHp: 10,
        );

    test('quiz passato → quiz_completed {xp_amount:100, badge:topicId}',
        () async {
      final fake = FakeEngineClient();
      final vm = PlayerViewModel(engine: fake, hubPlayerId: 'slay_7');
      final leveledUp = vm.addCompletedTopic('web_network');
      expect(leveledUp, isTrue); // 0 → 100 XP = L2
      expect(vm.progress.experience, 100);
      // Fire-and-forget: un microtask per far completare l'invio.
      await Future<void>.delayed(Duration.zero);
      expect(fake.calls, hasLength(1));
      expect(fake.calls.single['actionId'], 'quiz_completed');
      expect(fake.calls.single['playerId'], 'slay_7');
      expect(
        fake.calls.single['data'],
        {'xp_amount': 100, 'badge': 'web_network'},
      );
    });

    test('prima vittoria boss → boss_defeated {badge:bossId}, poi basta',
        () async {
      final fake = FakeEngineClient();
      final vm = PlayerViewModel(engine: fake, hubPlayerId: 'slay_7');
      expect(vm.recordBossVictory(boss()), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(fake.calls, hasLength(1));
      expect(fake.calls.single['actionId'], 'boss_defeated');
      expect(fake.calls.single['data'], {'badge': 'man_in_the_middle'});
      // Seconda vittoria: flusso locale ok, nessun nuovo evento.
      expect(vm.recordBossVictory(boss()), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(fake.calls, hasLength(1));
    });

    test('Hub down (fake false): flussi locali invariati', () async {
      final fake = FakeEngineClient(result: false);
      final vm = PlayerViewModel(engine: fake);
      expect(vm.addCompletedTopic('t1'), isTrue);
      expect(vm.progress.completedTopicIds, contains('t1'));
      expect(vm.recordBossVictory(boss()), isTrue);
      expect(vm.isBossDefeated('man_in_the_middle'), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(fake.calls, hasLength(2));
    });

    test('senza engine: nessun evento, nessun errore', () {
      final vm = PlayerViewModel();
      expect(vm.addCompletedTopic('t1'), isTrue);
      expect(vm.recordBossVictory(boss()), isTrue);
    });
  });
}
