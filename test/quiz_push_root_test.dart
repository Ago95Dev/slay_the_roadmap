import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/main.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// Regressione sistemica provider (terza occorrenza della stessa classe:
/// leaderboard, reset, ora quiz): `TopicDetailScreen` leggeva
/// `RoadmapViewModel` dal tap quiz ma le route pushate erano sorelle
/// dell'`home:`, non discendenti del MultiProvider → ProviderNotFound sul
/// device reale (`topic_detail_screen.dart:53`).
///
/// La root ora fornisce i ViewModel SOPRA il MaterialApp ([MyAppRoot]):
/// TUTTE le route li ereditano senza inoltri per-push. Questo test percorre
/// l'intera catena dalla root reale (login → Hub → Home → Roadmap →
/// detail → quiz) e falliva prima del fix.
Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Quiz da root reale (provider sopra MaterialApp)', () {
    testWidgets(
        'login → roadmap → tap topic → tap quiz: nessun ProviderNotFound, '
        'QuizScreen visibile', (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });

      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Hub → CONTINUA (ultima campagna scelta in setup).
      expect(find.byKey(const Key('hub_screen')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('hub_continue')),
        300,
      );
      await tester.tap(find.byKey(const Key('hub_continue')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Home (nessun progresso) → INIZIA IL PERCORSO → Roadmap.
      await tester.scrollUntilVisible(
        find.textContaining('INIZIA IL PERCORSO'),
        300,
      );
      await tester.tap(find.textContaining('INIZIA IL PERCORSO'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RoadmapScreen), findsOneWidget);

      // Roadmap → tap sul primo topic sbloccato ("La Rete").
      await tester.scrollUntilVisible(find.text('La Rete'), 300);
      await tester.tap(find.text('La Rete'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Prima apertura del capitolo: dialog introduttivo da chiudere.
      if (find.byKey(const Key('chapter_intro_ok')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('chapter_intro_ok')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.byType(TopicDetailScreen), findsOneWidget);

      // Detail → tap quiz: prima del fix esplodeva qui
      // (ProviderNotFound RoadmapViewModel).
      await tester.tap(find.byTooltip('Avvia Quiz'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuizScreen), findsOneWidget);
    });

    testWidgets('logout da root ricostruisce tutto (torna al login)',
        (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.restore();
        await session.register(username: 'Ada', password: 'x');
        await session.selectCampaign('web_foundations');
      });

      await tester.pumpWidget(MyAppRoot(session: session));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hub_screen')), findsOneWidget);

      await tester.runAsync(() async {
        await session.logout();
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Stack azzerato: scelta profilo, niente Hub né ViewModel pendenti.
      expect(find.byKey(const Key('profile_new_button')), findsOneWidget);
      expect(find.byKey(const Key('hub_screen')), findsNothing);
    });
  });
}
