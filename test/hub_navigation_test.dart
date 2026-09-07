import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/main.dart';
import 'package:slay_the_roadmap/ui/screens/campaign_selection_screen.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/hub_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// Hub personale (centro post-login): profilo/livello, CONTINUA che
/// riprende l'ultima campagna, voci che navigano, prima volta senza
/// CONTINUA + root che monta l'Hub (mai selezione forzata).

Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

/// Monta l'Hub con la stessa struttura della root (sessione sopra il
/// MaterialApp, ViewModel dentro come `home:`).
Future<void> _pumpHub(WidgetTester tester, SessionController session) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<SessionController>.value(
      value: session,
      child: MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: session.player!),
            ChangeNotifierProvider.value(value: session.roadmap!),
          ],
          child: const HubScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HubScreen profilo e livello', () {
    testWidgets('login → hub con nome, livello e voci', (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
      });

      await _pumpHub(tester, session);

      expect(find.byKey(const Key('hub_screen')), findsOneWidget);
      expect(find.byKey(const Key('hub_player_name')), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.byKey(const Key('player_hud')), findsOneWidget);
      expect(find.byKey(const Key('player_hud_level')), findsOneWidget);
      expect(find.text('Livello 1'), findsOneWidget);
      // Voci sempre visibili.
      expect(find.byKey(const Key('hub_campaigns')), findsOneWidget);
      expect(find.byKey(const Key('hub_leaderboard')), findsOneWidget);
      expect(find.byKey(const Key('hub_numbers')), findsOneWidget);
      expect(find.byKey(const Key('hub_settings')), findsOneWidget);
    });
  });

  group('Prima volta senza CONTINUA', () {
    testWidgets('CONTINUA nascosto + invito, CAMPAGNE naviga', (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
      });
      expect(session.hasSelectedCampaign, isFalse);

      await _pumpHub(tester, session);

      expect(find.byKey(const Key('hub_continue')), findsNothing);
      expect(find.byKey(const Key('hub_invite')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_campaigns')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_campaigns')));
      await tester.pumpAndSettle();

      expect(find.byType(CampaignSelectionScreen), findsOneWidget);
      expect(
        find.byKey(const Key('campaign_play_web_foundations')),
        findsOneWidget,
      );
    });
  });

  group('CONTINUA riprende ultima campagna', () {
    testWidgets('sottotitolo ultima campagna + tap apre la Home di gioco',
        (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });
      expect(session.hasSelectedCampaign, isTrue);

      await _pumpHub(tester, session);

      expect(find.byKey(const Key('hub_continue')), findsOneWidget);
      expect(find.byKey(const Key('hub_invite')), findsNothing);
      // Sottotitolo con l'ultima campagna giocata.
      expect(
        find.textContaining(session.activeCampaign!.title),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_continue')),
        -300,
      );
      await tester.tap(find.byKey(const Key('hub_continue')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Voci navigano', () {
    testWidgets('CLASSIFICA (offline), I MIEI NUMERI, IMPOSTAZIONI',
        (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });

      await _pumpHub(tester, session);

      // Classifica: engine nullo → stato offline, mai crash.
      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_leaderboard')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_leaderboard')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('leaderboard_offline')),
        findsOneWidget,
      );
      Navigator.of(tester.element(find.byKey(const Key('leaderboard_offline'))))
          .pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hub_screen')), findsOneWidget);

      // I miei numeri: stessi conteggi di Settings.
      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_numbers')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_numbers')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hub_numbers_screen')), findsOneWidget);
      expect(find.byKey(const Key('settings_stats')), findsOneWidget);
      expect(find.textContaining('Quiz superati:'), findsOneWidget);
      Navigator.of(tester.element(find.byKey(const Key('hub_numbers_screen'))))
          .pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hub_screen')), findsOneWidget);

      // Impostazioni: reset + cambio utente raggiungibili.
      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_settings')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_settings')));
      await tester.pumpAndSettle();
      expect(find.text('Reset progressi'), findsOneWidget);
      expect(find.byKey(const Key('settings_logout')), findsOneWidget);
    });
  });

  group('MyAppRoot monta l\u2019Hub', () {
    testWidgets('dopo login → hub, mai selezione forzata', (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
      });

      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      expect(find.byType(HubScreen), findsOneWidget);
      expect(find.byType(CampaignSelectionScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('dopo scelta campagna la root resta hub (CONTINUA visibile)',
        (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });

      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();

      expect(find.byType(HubScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byKey(const Key('hub_continue')), findsOneWidget);
    });
  });
}
