import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/class_selection_screen.dart';
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

  /// ClassSelection cards overflow at the default 800px test width
  /// (pre-existing layout, no restyle per U5 constraints): pump it wide.
  void useWideSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
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

  // ---------------------------------------------------------------- U5
  group('U5 NEW RUN riparte pulita', () {
    GameProvider populatedProvider() {
      final provider = GameProvider();
      provider.selectClass('warrior');
      provider.completeTopic('variables-types');
      provider.addGold(100);
      return provider;
    }

    test('startNewRun azzera il save e applica la nuova classe', () async {
      final provider = populatedProvider();
      expect(provider.completedTopics, isNotEmpty);
      expect(provider.playerStats.experience, greaterThan(0));
      expect(provider.gold, 100);

      await provider.startNewRun('mage');

      expect(provider.playerStats.playerClass, 'Mage');
      expect(provider.playerStats.experience, 0);
      expect(provider.completedTopics, isEmpty);
      expect(provider.gold, 0);
      expect(provider.activeDeck, isNotEmpty);
      expect(provider.hasStartedJourney, isTrue);
      final start =
          provider.roadmapNodes.where((n) => n.id == 'start').firstOrNull;
      expect(start, isNotNull);
      expect(start!.completed, isTrue);
      expect(
        provider.roadmapNodes.where((n) => n.completed && n.id != 'start'),
        isEmpty,
      );
      expect(
        provider.roadmapNodes.where((n) =>
            n.unlocked && n.id != 'start' && !start.connections.contains(n.id)),
        isEmpty,
      );
    });

    testWidgets('save popolato + CONFIRM -> run pulita con nuova classe',
        (tester) async {
      final provider = populatedProvider();
      suppressMissingAssets();
      useWideSurface(tester);
      await tester.pumpWidget(
          withProvider(provider, const ClassSelectionScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MAGE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BEGIN ADVENTURE'));
      await tester.pumpAndSettle();

      expect(find.text('CONFIRM'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(provider.playerStats.playerClass, 'Mage');
      expect(provider.playerStats.experience, 0);
      expect(provider.completedTopics, isEmpty);
      expect(provider.gold, 0);
      expect(provider.hasStartedJourney, isTrue);
    });

    testWidgets('ANNULLA -> save intatto, nessuna navigazione',
        (tester) async {
      final provider = populatedProvider();
      final topicsBefore = List.of(provider.completedTopics);
      final xpBefore = provider.playerStats.experience;
      suppressMissingAssets();
      useWideSurface(tester);
      await tester.pumpWidget(
          withProvider(provider, const ClassSelectionScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MAGE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BEGIN ADVENTURE'));
      await tester.pumpAndSettle();

      expect(find.text('CANCEL'), findsOneWidget);
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.byType(ClassSelectionScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(provider.playerStats.playerClass, 'Warrior');
      expect(provider.completedTopics, topicsBefore);
      expect(provider.playerStats.experience, xpBefore);
      expect(provider.gold, 100);
      expect(provider.hasStartedJourney, isTrue);
    });
  });
}
