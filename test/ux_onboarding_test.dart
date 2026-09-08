import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/deck_builder_screen.dart';
import 'package:slay_the_roadmap/screens/home_screen.dart';
import 'package:slay_the_roadmap/screens/main_menu_screen.dart';
import 'package:slay_the_roadmap/screens/path_selection_screen.dart';
import 'package:slay_the_roadmap/widgets/compact_stats_bar.dart';

/// UX onboarding U1-U3 (TDD rosso→fix→verde).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget withProvider(GameProvider provider, Widget home) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: home),
    );
  }

  void suppressMissingAssets() {
    final saved = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('Unable to load asset')) {
        return;
      }
      saved?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = saved;
    });
  }

  // ---------------------------------------------------------------- U1
  group('U1 CONTINUE solo a journey iniziata', () {
    testWidgets('flag false: CONTINUE assente, NEW RUN -> PathSelection',
        (tester) async {
      final provider = GameProvider();
      expect(provider.hasStartedJourney, isFalse);
      suppressMissingAssets();
      await tester.pumpWidget(withProvider(provider, const MainMenuScreen()));
      await tester.pumpAndSettle();

      expect(find.text('CONTINUE'), findsNothing);
      expect(find.text('NEW RUN'), findsOneWidget);

      await tester.tap(find.text('NEW RUN'));
      await tester.pumpAndSettle();
      expect(find.byType(PathSelectionScreen), findsOneWidget);
    });

    testWidgets('flag true: CONTINUE -> HomeScreen', (tester) async {
      final provider = GameProvider();
      provider.selectClass('mage');
      expect(provider.hasStartedJourney, isTrue);
      suppressMissingAssets();
      await tester.pumpWidget(withProvider(provider, const MainMenuScreen()));
      await tester.pumpAndSettle();

      expect(find.text('CONTINUE'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------- U2
  group('U2 chip classe mai vuota', () {
    testWidgets('Novice -> icona fallback senza errori asset',
        (tester) async {
      final provider = GameProvider();
      expect(provider.playerStats.playerClass, 'Novice');
      final errors = <FlutterErrorDetails>[];
      final saved = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
      };
      try {
        await tester.pumpWidget(
            withProvider(provider, const Scaffold(body: CompactStatsBar())));
        await tester.pump();
      } finally {
        FlutterError.onError = saved;
      }
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(
        errors.where((e) => e.exceptionAsString().contains('Unable to load asset')),
        isEmpty,
      );
    });

    testWidgets('Mage -> AssetImage reale', (tester) async {
      final provider = GameProvider();
      provider.selectClass('mage');
      suppressMissingAssets();
      await tester.pumpWidget(
          withProvider(provider, const Scaffold(body: CompactStatsBar())));
      await tester.pump();
      expect(find.text('MAGE'), findsOneWidget);
      // L'avatar è un DecorationImage nel Container circolare (non un
      // widget Image): ispeziona le decorazioni dei Container.
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasMageAsset = containers.any((c) {
        final d = c.decoration;
        if (d is! BoxDecoration) return false;
        final img = d.image?.image;
        return img is AssetImage && img.assetName.endsWith('mage.png');
      });
      expect(hasMageAsset, isTrue);
    });
  });

  // ---------------------------------------------------------------- U3
  group('U3 ritorno al menu dalla Home', () {
    testWidgets('tap menu -> MainMenuScreen; back -> Home con tab intatta',
        (tester) async {
      final provider = GameProvider();
      provider.selectClass('mage');
      suppressMissingAssets();
      await tester.pumpWidget(withProvider(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Seleziona tab Deck (indice 1) per verificare conservazione stato:
      // una Home ricreata da zero mostrerebbe Roadmap, non Deck.
      await tester.tap(find.text('Deck'));
      await tester.pumpAndSettle();
      expect(find.byType(DeckBuilderScreen), findsOneWidget);

      // Pulsante menu nell'AppBar della Home (push, non replacement).
      final menuFinder = find.byTooltip('Menu');
      expect(menuFinder, findsOneWidget);
      await tester.tap(menuFinder);
      await tester.pumpAndSettle();
      expect(find.byType(MainMenuScreen), findsOneWidget);

      // Back di sistema: Home con stesso stato (tab Deck ancora selezionata).
      Navigator.of(tester.element(find.byType(MainMenuScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(DeckBuilderScreen), findsOneWidget);
    });
  });
}
