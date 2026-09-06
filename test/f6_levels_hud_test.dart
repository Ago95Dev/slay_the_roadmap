import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';
import 'package:slay_the_roadmap/ui/widgets/player_hud.dart';

/// F6 (HUD + livelli): soglie L1 0 / L2 100 / L3 500, xpProgress,
/// level-up rilevato una sola volta, save/load con ricalcolo, HUD in
/// home/roadmap, dialog di level-up.

PlayerProgress _progressWithXp(int xp) =>
    PlayerProgress.initial().copyWith(experience: xp);

void main() {
  group('Soglie di livello', () {
    test('0/99 -> 1, 100/499 -> 2, 500+ -> 3', () {
      expect(PlayerProgress.levelForXp(0), 1);
      expect(PlayerProgress.levelForXp(99), 1);
      expect(PlayerProgress.levelForXp(100), 2);
      expect(PlayerProgress.levelForXp(499), 2);
      expect(PlayerProgress.levelForXp(500), 3);
      expect(PlayerProgress.levelForXp(10000), 3);
    });

    test('getter level derivato da experience', () {
      expect(_progressWithXp(0).level, 1);
      expect(_progressWithXp(99).level, 1);
      expect(_progressWithXp(100).level, 2);
      expect(_progressWithXp(499).level, 2);
      expect(_progressWithXp(500).level, 3);
    });

    test('addCompletedTopic (+100xp) fa salire di livello', () {
      final p = _progressWithXp(0).addCompletedTopic('t1');
      expect(p.experience, 100);
      expect(p.level, 2);
    });
  });

  group('xpForNextLevel / xpToNextLevel / xpProgress', () {
    test('L1: next 100, progress xp/100', () {
      final p = _progressWithXp(0);
      expect(p.xpForNextLevel, 100);
      expect(p.xpToNextLevel, 100);
      expect(p.xpProgress, 0.0);

      expect(_progressWithXp(50).xpProgress, 0.5);
      expect(_progressWithXp(99).xpToNextLevel, 1);
    });

    test('L2: next 500, progress (xp-100)/400', () {
      final p = _progressWithXp(100);
      expect(p.xpForNextLevel, 500);
      expect(p.xpToNextLevel, 400);
      expect(p.xpProgress, 0.0);

      expect(_progressWithXp(300).xpProgress, 0.5);
      expect(_progressWithXp(499).xpToNextLevel, 1);
    });

    test('L3: next null, progress 1.0 (livello massimo)', () {
      final p = _progressWithXp(500);
      expect(p.xpForNextLevel, isNull);
      expect(p.xpToNextLevel, isNull);
      expect(p.xpProgress, 1.0);
      expect(_progressWithXp(900).xpProgress, 1.0);
    });
  });

  group('Level-up rilevato una sola volta (PlayerViewModel)', () {
    test('quiz: true al crossing 1->2, poi false', () {
      final vm = PlayerViewModel();
      expect(vm.addCompletedTopic('t1'), isTrue); // 0 -> 100
      expect(vm.progress.level, 2);
      expect(vm.addCompletedTopic('t2'), isFalse); // 100 -> 200
      expect(vm.progress.level, 2);
    });

    test('crossing 2->3 una sola volta', () {
      final vm = PlayerViewModel(
        initialProgress: _progressWithXp(400),
      );
      expect(vm.progress.level, 2);
      expect(vm.addCompletedTopic('t1'), isTrue); // 400 -> 500
      expect(vm.progress.level, 3);
      expect(vm.addCompletedTopic('t2'), isFalse); // 500 -> 600
    });

    test('seconda vittoria boss: niente XP, niente level-up', () {
      final vm = PlayerViewModel(
        initialProgress: _progressWithXp(0),
      );
      expect(vm.addCompletedTopic('t1'), isTrue); // 100, L2
      // Simula XP boss senza passare dal BossFight: +100 finti via topic.
      expect(vm.addCompletedTopic('t2'), isFalse); // 200, resta L2
      expect(vm.progress.level, 2);
    });
  });

  group('Save/load con nuovo calcolo', () {
    test('fromJson ignora il level salvato (save v1) e ricalcola', () {
      final json = _progressWithXp(100).toJson();
      // Vecchio save con level incoerente: viene ignorato.
      json['level'] = 1;
      final restored = PlayerProgress.fromJson(json);
      expect(restored.experience, 100);
      expect(restored.level, 2);

      final json3 = _progressWithXp(0).toJson();
      json3['level'] = 3; // level gonfiato nel save: ignorato.
      expect(PlayerProgress.fromJson(json3).level, 1);
    });

    test('roundtrip preserva xp e livello derivato', () {
      final restored =
          PlayerProgress.fromJson(_progressWithXp(500).toJson());
      expect(restored.experience, 500);
      expect(restored.level, 3);
      expect(restored.toJson()['level'], 3);
    });
  });

  group('PlayerHud widget', () {
    testWidgets('mostra Livello N, XP e barra', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(progress: _progressWithXp(100)),
          ),
        ),
      );

      expect(find.text('Livello 2'), findsOneWidget);
      expect(find.textContaining('Mancano 400 XP'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('player_hud_bar')),
      );
      expect(bar.value, 0.0);
    });

    testWidgets('al livello massimo mostra testo dedicato', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(progress: _progressWithXp(500)),
          ),
        ),
      );

      expect(find.text('Livello 3'), findsOneWidget);
      expect(find.textContaining('Livello massimo'), findsOneWidget);
    });

    testWidgets('showLevelUpDialog celebra e si chiude', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showLevelUpDialog(ctx, 2),
                child: const Text('UP'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('UP'));
      await tester.pumpAndSettle();
      expect(find.text('Livello 2 raggiunto! 🎉'), findsOneWidget);

      await tester.tap(find.text('Fantastico!'));
      await tester.pumpAndSettle();
      expect(find.text('Livello 2 raggiunto! 🎉'), findsNothing);
    });
  });

  group('HUD in home e roadmap', () {
    testWidgets('home mostra PlayerHud sotto il titolo', (tester) async {
      final playerVm = PlayerViewModel();
      playerVm.addCompletedTopic('t1'); // 100 XP -> Livello 2
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider(
              create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayerHud), findsOneWidget);
      expect(find.text('Livello 2'), findsOneWidget);
    });

    testWidgets('roadmap mostra PlayerHud sopra le stats', (tester) async {
      // Viewport alto: la roadmap_tree riempie lo spazio residuo e il
      // test di default (800x600) andrebbe in overflow verticale.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final roadmapVm = RoadmapViewModel(LocalRoadmapRepository());
      roadmapVm.loadRoadmap();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: PlayerViewModel()),
            ChangeNotifierProvider.value(value: roadmapVm),
          ],
          child: const MaterialApp(home: RoadmapScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerHud), findsOneWidget);
      expect(find.text('Livello 1'), findsOneWidget);
    });
  });
}
