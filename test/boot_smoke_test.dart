import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/models/types.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/main_menu_screen.dart';
import 'package:slay_the_roadmap/screens/path_selection_screen.dart';
import 'package:slay_the_roadmap/widgets/compact_stats_bar.dart';
import 'package:slay_the_roadmap/widgets/topic_node.dart';

/// Smoke di boot (Fase 0): il menu deve montarsi senza eccezioni e
/// nessun InkWell deve restare senza antenato Material.
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameProvider makeProvider() => GameProvider();

  Widget withProvider(Widget home) {
    return ChangeNotifierProvider(
      create: (_) => makeProvider(),
      child: MaterialApp(home: home),
    );
  }

  bool hasMaterialAncestor(WidgetTester tester, InkWell w) {
    var found = false;
    tester.element(find.byWidget(w)).visitAncestorElements((a) {
      if (a.widget is Material) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  void expectAllInkWellsUnderMaterial(WidgetTester tester) {
    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell)).toList();
    expect(inkWells, isNotEmpty, reason: 'nessun InkWell trovato');
    for (final w in inkWells) {
      expect(
        hasMaterialAncestor(tester, w),
        isTrue,
        reason: 'InkWell senza antenato Material (splash/crash risk)',
      );
    }
  }

  testWidgets('smoke: MainMenuScreen si monta senza eccezioni', (tester) async {
    await tester.pumpWidget(withProvider(const MainMenuScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('ROADMAP'), findsOneWidget);
  });

  testWidgets('CompactStatsBar: ogni InkWell ha un antenato Material',
      (tester) async {
    // Senza Scaffold: conta solo il Material esplicito attorno agli InkWell.
    // L'asset immagine profilo non esiste in test: ignora quell'errore noto.
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {};
    try {
      await tester.pumpWidget(withProvider(const CompactStatsBar()));
      await tester.pump();
    } finally {
      FlutterError.onError = oldOnError;
    }
    expectAllInkWellsUnderMaterial(tester);
  });

  testWidgets('PathSelectionScreen: ogni InkWell ha un antenato Material',
      (tester) async {
    await tester.pumpWidget(withProvider(const PathSelectionScreen()));
    await tester.pumpAndSettle();
    expectAllInkWellsUnderMaterial(tester);
  });

  testWidgets('TopicNode: InkWell ha un antenato Material', (tester) async {
    final topic = Topic(
      id: 't1',
      title: 'Topic',
      description: 'desc',
      chapterId: 'chapter-1',
      type: TopicType.core,
      difficulty: 'easy',
      resources: const [],
      order: 0,
    );
    await tester.pumpWidget(MaterialApp(
      home: TopicNode(
        topic: topic,
        depth: 0,
        onTopicTap: (_) {},
        onToggleExpansion: (_) {},
      ),
    ));
    await tester.pump();
    expectAllInkWellsUnderMaterial(tester);
  });

  test('GameProvider: id roadmap sconosciuto non lancia StateError', () async {
    final provider = makeProvider();
    // NOTA: nessun await sul load async: _roadmapNodes è init sincrono nel ctor.
    expect(() => provider.completeRoadmapNode('id-inesistente'), returnsNormally);
    expect(() => provider.unlockSkill('skill-inesistente'), returnsNormally);
  });
}
