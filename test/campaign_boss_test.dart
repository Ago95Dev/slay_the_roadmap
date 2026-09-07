import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/boss_fight_active_screen.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Campagna US-04: i boss sono finali di capitolo nella roadmap
/// (nodo boss a fine capitolo, gate `requiredBossId`), via la voce
/// separata in home.

Topic? _find(List<Topic> topics, String id) {
  for (final t in topics) {
    if (t.id == id) return t;
    final sub = _find(t.subtopics, id);
    if (sub != null) return sub;
  }
  return null;
}

/// Completa l'intero capitolo web_network (root + sotto-topic richiesti).
void _completeChapterOne(RoadmapViewModel vm) {
  vm.updateTopicStatus('web_network', TopicStatus.completed);
  vm.updateTopicStatus('net_client_server', TopicStatus.completed);
  vm.updateTopicStatus('net_dns_url', TopicStatus.completed);
  vm.updateTopicStatus('net_http_https', TopicStatus.completed);
}

void main() {
  group('Modello campagna: boss sui capitoli root', () {
    test('ogni capitolo root ha bossId+bossName, i dopo hanno requiredBossId',
        () async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();
      expect(vm.topics, hasLength(3));

      final basics = _find(vm.topics, 'web_network')!;
      expect(basics.bossId, 'man_in_the_middle');
      expect(basics.bossName, 'Man-in-the-Middle');
      expect(basics.requiredBossId, isNull);

      final oop = _find(vm.topics, 'web_data')!;
      expect(oop.bossId, 'the_amnesiac');
      expect(oop.bossName, 'The Amnesiac');
      expect(oop.requiredBossId, 'man_in_the_middle');

      final advanced = _find(vm.topics, 'web_building')!;
      expect(advanced.bossId, 'spaghetti_colossus');
      expect(advanced.bossName, 'Spaghetti Colossus');
      expect(advanced.requiredBossId, 'the_amnesiac');
    });

    test('chapterId dei boss coerenti coi capitoli, nomi allineati ai Topic',
        () async {
      final bosses = await BossRepository().getAllBosses();
      expect(bosses.map((b) => b.id),
          containsAll(['man_in_the_middle', 'the_amnesiac', 'spaghetti_colossus']));

      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();
      final rootIds = vm.topics.map((t) => t.id).toSet();
      for (final boss in bosses) {
        // Niente più chapterId orfani (es. vecchi id Dart).
        expect(rootIds, contains(boss.chapterId),
            reason: 'boss ${boss.id} -> ${boss.chapterId}');
        final chapter = _find(vm.topics, boss.chapterId)!;
        expect(chapter.bossId, boss.id);
        expect(chapter.bossName, boss.name);
      }
      expect(rootIds, isNot(contains('flutter_widgets')));
    });
  });

  group('Gate capitoli via requiredBossId', () {
    test('default isBossDefeated=false: web_data resta locked dopo web_network',
        () async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();
      _completeChapterOne(vm);

      // I sotto-topic si sbloccano a catena (nessun gate boss lì)...
      expect(
          _find(vm.topics, 'net_http_https')?.status, TopicStatus.completed);
      // ...ma il capitolo dopo resta locked senza vittoria sul boss.
      expect(_find(vm.topics, 'web_data')?.status, TopicStatus.locked);
      // Il nodo boss invece è sbloccato: capitolo interamente completato
      // (data_state è opzionale e non blocca).
      expect(
          _find(vm.topics, 'web_network')?.isChapterComplete, isTrue);
    });

    test('nodo boss locked prima del capitolo completato', () async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());
      await vm.loadRoadmap();
      expect(
          _find(vm.topics, 'web_network')?.isChapterComplete, isFalse);
    });

    test('reevaluateUnlocks apre web_data quando il boss è sconfitto',
        () async {
      var defeated = false;
      final vm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: (bossId) =>
            defeated && bossId == 'man_in_the_middle',
      );
      await vm.loadRoadmap();
      _completeChapterOne(vm);
      expect(_find(vm.topics, 'web_data')?.status, TopicStatus.locked);

      defeated = true;
      vm.reevaluateUnlocks();
      expect(
          _find(vm.topics, 'web_data')?.status, TopicStatus.inProgress);
      // web_building resta locked: manca the_amnesiac + oop incompleto.
      expect(
          _find(vm.topics, 'web_building')?.status, TopicStatus.locked);
    });

    test('vittoria reale (PlayerViewModel) sblocca il capitolo dopo',
        () async {
      final playerVm = PlayerViewModel();
      final roadmapVm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
      await roadmapVm.loadRoadmap();
      _completeChapterOne(roadmapVm);
      expect(_find(roadmapVm.topics, 'web_data')?.status, TopicStatus.locked);

      // Vittoria come la registra BossFightActiveScreen al claim.
      final bosses = await BossRepository().getAllBosses();
      final boss = bosses.firstWhere((b) => b.id == 'man_in_the_middle');
      expect(playerVm.recordBossVictory(boss), isTrue);
      expect(playerVm.isBossDefeated('man_in_the_middle'), isTrue);

      // Al rientro dalla vittoria la roadmap rivaluta i gate.
      roadmapVm.reevaluateUnlocks();
      expect(
          _find(roadmapVm.topics, 'web_data')?.status, TopicStatus.inProgress);
    });
  });

  group('Home senza voce boss', () {
    testWidgets('nessuna card BOSS FIGHT, solo percorso + settings',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PlayerViewModel()),
            ChangeNotifierProvider(
              create: (_) => RoadmapViewModel(LocalRoadmapRepository()),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('BOSS FIGHT'), findsNothing);
      expect(find.textContaining('INIZIA IL PERCORSO'), findsOneWidget);
      expect(find.textContaining('SETTINGS'), findsOneWidget);
    });
  });

  group('Nodo boss nella roadmap (widget)', () {
    // Nota: in testWidgets vige il fake clock, quindi NIENTE
    // `await loadRoadmap()` prima del pump (Future.delayed interno non
    // avanzerebbe mai): si pompa per far avanzare il clock finto.
    Future<RoadmapViewModel> pumpRoadmap(
      WidgetTester tester,
      PlayerViewModel playerVm,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      final roadmapVm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider.value(value: roadmapVm),
          ],
          child: const MaterialApp(home: RoadmapScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      return roadmapVm;
    }

    testWidgets('tap boss locked mostra SnackBar, non naviga', (tester) async {
      final playerVm = PlayerViewModel();
      await pumpRoadmap(tester, playerVm);

      expect(find.byKey(const Key('boss_tile_man_in_the_middle')),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('boss_tile_man_in_the_middle')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Completa tutti i topic del capitolo per sfidare il boss'),
          findsOneWidget);
      expect(find.byType(BossFightActiveScreen), findsNothing);
    });

    testWidgets('capitolo completato -> tap boss apre BossFightActiveScreen',
        (tester) async {
      final playerVm = PlayerViewModel();
      final roadmapVm = await pumpRoadmap(tester, playerVm);

      _completeChapterOne(roadmapVm);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('boss_tile_man_in_the_middle')));
      await tester.pumpAndSettle();

      // Lore pre-fight (Fase 1B-A): dialog con Combatti/Indietro.
      expect(find.byKey(const Key('boss_lore_dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('boss_lore_fight')));
      await tester.pumpAndSettle();

      expect(find.byType(BossFightActiveScreen), findsOneWidget);
      expect(find.text('Man-in-the-Middle'), findsWidgets);
    });
  });
}
