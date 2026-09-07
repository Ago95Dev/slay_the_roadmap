import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/config/hub.dart';
import 'package:slay_the_roadmap/data/services/engine_client.dart';
import 'package:slay_the_roadmap/ui/screens/leaderboard_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';

/// Fase 1B-D (classifica XP Hub): parsing board, errore→vuota, Fake seed,
/// widget stati (carica/vuota/offline), highlight proprio player.

const _user = 'tester';
const _pass = 'secret';

Map<String, dynamic> _boardJson(List<Map<String, dynamic>> rows) => {
      'board': {'content': rows},
      'classificationName': 'overall_xp',
      'pointConceptName': 'xp',
    };

MockClient _boardClient({
  Map<String, dynamic>? board,
  int status = 200,
  String token = 'tok123',
  void Function(http.BaseRequest request)? onBoard,
}) {
  return MockClient((request) async {
    if (request.url.path.endsWith('/auth')) {
      return http.Response(jsonEncode({'token': token}), 200);
    }
    if (request.url.path.contains('/classifications/')) {
      onBoard?.call(request);
      if (board == null) return http.Response('errore', status);
      return http.Response(jsonEncode(board), status);
    }
    return http.Response('not found', 404);
  });
}

HttpEngineClient _engineWithBoard({
  Map<String, dynamic>? board,
  int status = 200,
}) =>
    HttpEngineClient(
      client: _boardClient(board: board, status: status),
      baseUrl: 'https://example.test/api/v1',
      username: _user,
      password: _pass,
    );

class _NeverEngine implements EngineClient {
  @override
  Future<bool> execute({
    required String actionId,
    required String playerId,
    Map<String, dynamic> data = const {},
  }) async =>
      false;

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() =>
      Completer<List<LeaderboardEntry>>().future;
}

void main() {
  group('LeaderboardEntry.parseBoard', () {
    test('parsing forma reale {board:{content:[...]}}', () {
      final entries = LeaderboardEntry.parseBoard(_boardJson([
        {'position': 1, 'playerId': 'slay_a', 'score': 300},
        {'position': 2, 'playerId': 'slay_b', 'score': 100},
      ]));
      expect(entries, hasLength(2));
      expect(entries[0].position, 1);
      expect(entries[0].playerId, 'slay_a');
      expect(entries[0].score, 300);
    });

    test('forma piatta {content:[...]} e valori stringa tollerati', () {
      final entries = LeaderboardEntry.parseBoard({
        'content': [
          {'position': '1', 'playerId': 'slay_a', 'score': '250'},
        ],
      });
      expect(entries, hasLength(1));
      expect(entries.single.position, 1);
      expect(entries.single.score, 250);
    });

    test('shape inatteso → lista vuota, mai throw', () {
      expect(LeaderboardEntry.parseBoard(null), isEmpty);
      expect(LeaderboardEntry.parseBoard({'board': {}}), isEmpty);
      expect(LeaderboardEntry.parseBoard('non-json'), isEmpty);
      expect(LeaderboardEntry.parseBoard([1, 2, 3]), isEmpty);
    });
  });

  group('HttpEngineClient.getLeaderboard', () {
    test('GET board con Bearer e parsing righe', () async {
      String? auth;
      String? path;
      final engine = HttpEngineClient(
        client: _boardClient(
          board: _boardJson([
            {'position': 1, 'playerId': 'slay_a', 'score': 300},
          ]),
          onBoard: (request) {
            auth = request.headers['Authorization'];
            path = request.url.path;
          },
        ),
        baseUrl: 'https://example.test/api/v1',
        username: _user,
        password: _pass,
      );
      final entries = await engine.getLeaderboard();
      expect(auth, 'Bearer tok123');
      expect(
        path,
        contains(
          '/games/${HubConfig.gameId}/classifications/${HubConfig.overallXpClassification}/board',
        ),
      );
      expect(entries, hasLength(1));
      expect(entries.single.playerId, 'slay_a');
    });

    test('errore HTTP → lista vuota, mai throw', () async {
      final engine = _engineWithBoard(board: null, status: 500);
      expect(await engine.getLeaderboard(), isEmpty);
    });

    test('eccezione di rete → lista vuota, mai throw', () async {
      final engine = HttpEngineClient(
        client: MockClient((_) async => throw Exception('rete giù')),
        baseUrl: 'https://example.test/api/v1',
        username: _user,
        password: _pass,
      );
      expect(await engine.getLeaderboard(), isEmpty);
    });

    test('offline senza credenziali → vuota senza rete', () async {
      final engine = HttpEngineClient(
        client: MockClient((_) async {
          throw StateError('non deve chiamare la rete');
        }),
        username: '',
        password: '',
      );
      expect(await engine.getLeaderboard(), isEmpty);
    });
  });

  group('FakeEngineClient.getLeaderboard', () {
    test('default vuota', () async {
      expect(await FakeEngineClient().getLeaderboard(), isEmpty);
    });

    test('seed iniettabile per i test', () async {
      final fake = FakeEngineClient(leaderboardSeed: const [
        LeaderboardEntry(position: 1, playerId: 'slay_a', score: 300),
        LeaderboardEntry(position: 2, playerId: 'slay_b', score: 100),
      ]);
      final entries = await fake.getLeaderboard();
      expect(entries.map((e) => e.playerId), ['slay_a', 'slay_b']);
    });
  });

  group('PlayerViewModel.fetchLeaderboard', () {
    test('delega al seed del fake', () async {
      final vm = PlayerViewModel(
        engine: FakeEngineClient(leaderboardSeed: const [
          LeaderboardEntry(position: 1, playerId: 'slay_7', score: 100),
        ]),
        hubPlayerId: 'slay_7',
      );
      expect(vm.hubPlayerId, 'slay_7');
      expect(vm.isLeaderboardOffline, isFalse);
      final entries = await vm.fetchLeaderboard();
      expect(entries, hasLength(1));
    });

    test('senza engine → offline + vuota', () async {
      final vm = PlayerViewModel();
      expect(vm.isLeaderboardOffline, isTrue);
      expect(await vm.fetchLeaderboard(), isEmpty);
    });
  });

  group('LeaderboardScreen widget', () {
    Widget wrap(Widget child, {PlayerViewModel? vm}) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: vm ?? PlayerViewModel(),
            ),
          ],
          child: MaterialApp(home: child),
        );

    testWidgets('stato caricamento: spinner', (tester) async {
      await tester.pumpWidget(
        wrap(LeaderboardScreen(engine: _NeverEngine(), playerId: 'x')),
      );
      expect(find.byKey(const Key('leaderboard_loading')), findsOneWidget);
    });

    testWidgets('stato vuoto: invito a giocare un quiz', (tester) async {
      await tester.pumpWidget(
        wrap(LeaderboardScreen(engine: FakeEngineClient(), playerId: 'slay_1')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leaderboard_empty')), findsOneWidget);
      expect(find.textContaining('gioca un quiz'), findsOneWidget);
    });

    testWidgets('stato offline: messaggio dedicato', (tester) async {
      await tester.pumpWidget(wrap(const LeaderboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leaderboard_offline')), findsOneWidget);
      expect(
        find.text('Classifica non disponibile offline'),
        findsOneWidget,
      );
    });

    testWidgets('podio con medaglie + highlight "Tu"', (tester) async {
      final fake = FakeEngineClient(leaderboardSeed: const [
        LeaderboardEntry(position: 1, playerId: 'slay_a', score: 300),
        LeaderboardEntry(position: 2, playerId: 'slay_me', score: 200),
        LeaderboardEntry(position: 3, playerId: 'slay_c', score: 100),
        LeaderboardEntry(position: 4, playerId: 'slay_d', score: 50),
      ]);
      await tester.pumpWidget(
        wrap(LeaderboardScreen(engine: fake, playerId: 'slay_me')),
      );
      await tester.pumpAndSettle();
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('🥉'), findsOneWidget);
      expect(find.text('#4'), findsOneWidget);
      expect(find.text('slay_me • Tu'), findsOneWidget);
      expect(find.text('300 XP'), findsOneWidget);
    });

    testWidgets('pull-to-refresh ricarica senza errori', (tester) async {
      final fake = FakeEngineClient(leaderboardSeed: const [
        LeaderboardEntry(position: 1, playerId: 'slay_a', score: 10),
      ]);
      await tester.pumpWidget(
        wrap(LeaderboardScreen(engine: fake, playerId: 'slay_a')),
      );
      await tester.pumpAndSettle();
      await tester.fling(
        find.byKey(const Key('leaderboard_row_1')),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('slay_a • Tu'), findsOneWidget);
    });
  });
}
