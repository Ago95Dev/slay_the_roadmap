import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/services/engine_client.dart';
import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/main.dart';
import 'package:slay_the_roadmap/ui/screens/campaign_selection_screen.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/hub_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// Regressione per 2 bug visti su Linux reale (build hub 38f3546).
///
/// BUG 1 — Voce CAMPAGNE senza navigazione: la card 'CAMPAGNE' della
/// Home di gioco (stessa etichetta/icona della voce Hub) chiamava solo
/// `backToCampaignSelection()` (flag silenzioso, nessuna push): dal
/// device, dopo Gioca→Home, il tap sembrava non fare nulla. Causa
/// trovata con test full-root (falliva prima del fix, passa dopo).
/// BUG 2 — Classifica offline muta: il messaggio ora spiega come andare
/// online; il percorso online è verificato in app con HttpEngineClient
/// reale + MockClient.

Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

/// Sessione reale loggata, con lo stesso wiring di main() (engine
/// iniettabile come in produzione).
Future<SessionController> _loggedIn(
  WidgetTester tester, {
  EngineClient? engine,
  bool withCampaign = false,
}) async {
  final session = SessionController(await _store(), engine: engine);
  await tester.runAsync(() async {
    await session.restore();
    await session.register(username: 'Ada', password: 'x');
    if (withCampaign) await session.selectCampaign('web_foundations');
  });
  return session;
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

  group('BUG 1 — CAMPAGNE naviga davvero (full-root)', () {
    testWidgets('Hub: tap CAMPAGNE → schermata scelta', (tester) async {
      final session = await _loggedIn(tester);
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hub_screen')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_campaigns')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_campaigns')));
      await tester.pumpAndSettle();

      expect(find.byType(CampaignSelectionScreen), findsOneWidget);
    });

    testWidgets('Gioca → Home di gioco', (tester) async {
      final session = await _loggedIn(tester);
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_campaigns')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_campaigns')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('campaign_play_web_foundations')),
        300,
      );
      await tester.tap(find.byKey(const Key('campaign_play_web_foundations')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Home: tap CAMPAGNE → schermata scelta (era no-op)',
        (tester) async {
      final session = await _loggedIn(tester);
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      // Hub → CAMPAGNE → Gioca → Home.
      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_campaigns')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_campaigns')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('campaign_play_web_foundations')),
        300,
      );
      await tester.tap(find.byKey(const Key('campaign_play_web_foundations')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Dalla Home la voce CAMPAGNE deve aprire la selezione (prima del
      // fix restava ferma sulla Home: nessuna navigazione, nessun errore).
      await tester.scrollUntilVisible(find.text('🗺️ CAMPAGNE'), 300);
      await tester.tap(find.text('🗺️ CAMPAGNE'));
      await tester.pumpAndSettle();

      expect(find.byType(CampaignSelectionScreen), findsOneWidget);
      // Il flag è azzerato: tornando all'Hub, CONTINUA è nascosto.
      expect(session.hasSelectedCampaign, isFalse);
    });

    testWidgets('back: selezione → Hub con invito (niente CONTINUA)',
        (tester) async {
      final session = await _loggedIn(tester);
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_campaigns')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_campaigns')));
      await tester.pumpAndSettle();
      expect(find.byType(CampaignSelectionScreen), findsOneWidget);

      Navigator.of(tester.element(find.byType(CampaignSelectionScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(HubScreen), findsOneWidget);
      expect(find.byKey(const Key('hub_invite')), findsOneWidget);
      expect(find.byKey(const Key('hub_continue')), findsNothing);
    });
  });

  group('BUG 2 — Classifica offline/online (full-root)', () {
    testWidgets('offline: messaggio esplicativo su come andare online',
        (tester) async {
      // Senza --dart-define: HttpEngineClient resta offline (corretto).
      final session = await _loggedIn(tester, engine: HttpEngineClient());
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_leaderboard')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_leaderboard')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leaderboard_offline')), findsOneWidget);
      expect(find.byKey(const Key('leaderboard_offline_hint')), findsOneWidget);
      expect(
        find.textContaining('--dart-define=HUB_USER'),
        findsOneWidget,
      );
    });

    testWidgets('online: HttpEngineClient reale + board vera → righe',
        (tester) async {
      final engine = HttpEngineClient(
        client: _boardClient(),
        baseUrl: 'https://example.test/api/v1',
        username: 'tester',
        password: 'secret',
      );
      final session = await _loggedIn(tester, engine: engine);
      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_leaderboard')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_leaderboard')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leaderboard_offline')), findsNothing);
      expect(find.byKey(const Key('leaderboard_row_1')), findsOneWidget);
      expect(find.byKey(const Key('leaderboard_row_2')), findsOneWidget);
      expect(find.text('300 XP'), findsOneWidget);
    });
  });
}
