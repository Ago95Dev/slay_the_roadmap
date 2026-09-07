import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/boss_fight.dart';
import 'package:slay_the_roadmap/domain/models/campaign_lore.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/home_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';
import 'package:slay_the_roadmap/ui/widgets/player_hud.dart';

/// Fase 1B-B (titoli + avatar): titolo solo a capitolo intero + boss
/// sconfitto (ultimo vinto = attivo), HUD/Home lo mostrano, avatar
/// default/pick/persistenza con default tolleranti per i save vecchi.

PlayerProgress _progressWithTitle(String title) =>
    PlayerProgress.initial().copyWith(activeTitle: title);

void _recordBossSync(PlayerViewModel vm, String bossId, String chapterId) {
  vm.recordBossVictory(
    BossFight(
      id: bossId,
      chapterId: chapterId,
      name: bossId,
      maxHp: 10,
      currentHp: 10,
    ),
  );
}

void main() {
  group('Titoli capitolo', () {
    test('mappa con i 3 titoli attesi', () {
      expect(chapterTitles['web_network'], 'Sentinella della Rete');
      expect(chapterTitles['web_data'], 'Custode dei Dati');
      expect(chapterTitles['web_building'], 'Architetto del Web');
    });

    test('non assegnato prima del completamento', () {
      final vm = PlayerViewModel();
      // Capitolo incompleto, boss sconfitto: niente titolo.
      _recordBossSync(vm, 'man_in_the_middle', 'web_network');
      expect(
        vm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: false,
          bossDefeated: true,
        ),
        isFalse,
      );
      expect(vm.progress.activeTitle, isEmpty);
    });

    test('non assegnato senza vittoria boss', () {
      final vm = PlayerViewModel();
      expect(
        vm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: true,
          bossDefeated: false,
        ),
        isFalse,
      );
      expect(vm.progress.activeTitle, isEmpty);
    });

    test('assegnato a capitolo intero + boss sconfitto', () {
      final vm = PlayerViewModel();
      _recordBossSync(vm, 'man_in_the_middle', 'web_network');
      expect(
        vm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: true,
          bossDefeated: true,
        ),
        isTrue,
      );
      expect(vm.progress.activeTitle, 'Sentinella della Rete');
      // Idempotente: seconda chiamata non ri-assegna.
      expect(
        vm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: true,
          bossDefeated: true,
        ),
        isFalse,
      );
    });

    test('ultimo titolo vinto = attivo', () {
      final vm = PlayerViewModel();
      _recordBossSync(vm, 'man_in_the_middle', 'web_network');
      _recordBossSync(vm, 'the_amnesiac', 'web_data');
      expect(
        vm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: true,
          bossDefeated: true,
        ),
        isTrue,
      );
      expect(
        vm.checkAndAwardChapterTitle(
          'web_data',
          chapterComplete: true,
          bossDefeated: true,
        ),
        isTrue,
      );
      expect(vm.progress.activeTitle, 'Custode dei Dati');
    });

    test('scorciatoia per boss: prima della vittoria false, dopo true', () {
      final vm = PlayerViewModel();
      expect(
        vm.checkAndAwardTitleForBoss(
          'man_in_the_middle',
          chapterComplete: true,
        ),
        isFalse,
      );
      _recordBossSync(vm, 'man_in_the_middle', 'web_network');
      expect(
        vm.checkAndAwardTitleForBoss(
          'man_in_the_middle',
          chapterComplete: true,
        ),
        isTrue,
      );
      expect(vm.progress.activeTitle, 'Sentinella della Rete');
      // Boss sconosciuto: false.
      expect(
        vm.checkAndAwardTitleForBoss('inesistente', chapterComplete: true),
        isFalse,
      );
    });

    test('capitolo reale: tutti i topic + boss = titolo', () async {
      final playerVm = PlayerViewModel();
      final roadmapVm = RoadmapViewModel(
        LocalRoadmapRepository(),
        isBossDefeated: playerVm.isBossDefeated,
      );
      await roadmapVm.loadRoadmap();
      for (final id in [
        'web_network',
        'net_client_server',
        'net_dns_url',
        'net_http_https',
      ]) {
        roadmapVm.updateTopicStatus(id, TopicStatus.completed);
      }
      final chapter = roadmapVm.topics.firstWhere(
        (t) => t.id == 'web_network',
      );
      expect(chapter.isChapterComplete, isTrue);
      expect(
        playerVm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: chapter.isChapterComplete,
          bossDefeated: playerVm.isBossDefeated('man_in_the_middle'),
        ),
        isFalse,
        reason: 'boss non ancora sconfitto',
      );
      _recordBossSync(playerVm, 'man_in_the_middle', 'web_network');
      expect(
        playerVm.checkAndAwardChapterTitle(
          'web_network',
          chapterComplete: chapter.isChapterComplete,
          bossDefeated: playerVm.isBossDefeated('man_in_the_middle'),
        ),
        isTrue,
      );
      expect(playerVm.progress.activeTitle, 'Sentinella della Rete');
    });
  });

  group('Avatar: default, scelta, persistenza', () {
    test('default sensato: mago + prima cornice, nessun titolo', () {
      final p = PlayerProgress.initial();
      expect(p.avatarIconIndex, 0);
      expect(p.avatarFrameIndex, 0);
      expect(p.avatarIcon, '🧙');
      expect(p.activeTitle, isEmpty);
      expect(p.hasTitle, isFalse);
    });

    test('save v1 senza nuovi campi: default tolleranti', () {
      final json = {
        'playerId': 'p1',
        'playerName': 'A',
        'experience': 100,
        'completedTopicIds': <String>[],
        'quizResults': [],
        'inventory': {
          'rewards': [],
          'maxSlots': 20,
        },
        'bossFights': {},
        'lastSaved': DateTime.now().toIso8601String(),
      };
      final restored = PlayerProgress.fromJson(json);
      expect(restored.avatarIconIndex, 0);
      expect(restored.avatarFrameIndex, 0);
      expect(restored.avatarIcon, '🧙');
      expect(restored.activeTitle, isEmpty);
      final roundTrip = PlayerProgress.fromJson(restored.toJson());
      expect(roundTrip.avatarIconIndex, 0);
      expect(roundTrip.avatarFrameIndex, 0);
      expect(roundTrip.activeTitle, isEmpty);
    });

    test('roundtrip preserva avatar e titolo', () {
      final p = PlayerProgress.initial().copyWith(
        avatarIconIndex: 1,
        avatarFrameIndex: 2,
        activeTitle: 'Custode dei Dati',
      );
      final restored = PlayerProgress.fromJson(p.toJson());
      expect(restored.avatarIconIndex, 1);
      expect(restored.avatarFrameIndex, 2);
      expect(restored.avatarIcon, '🦊');
      expect(restored.activeTitle, 'Custode dei Dati');
      expect(restored.hasTitle, isTrue);
    });

    test('setAvatar aggiorna e clamp agli estremi', () {
      final vm = PlayerViewModel();
      vm.setAvatar(iconIndex: 2, frameIndex: 1);
      expect(vm.progress.avatarIconIndex, 2);
      expect(vm.progress.avatarFrameIndex, 1);
      expect(vm.progress.avatarIcon, '🤖');
      vm.setAvatar(iconIndex: 99, frameIndex: -5);
      expect(vm.progress.avatarIconIndex, 2);
      expect(vm.progress.avatarFrameIndex, 0);
    });
  });

  group('HUD mostra titolo e avatar', () {
    testWidgets('senza titolo: niente riga titolo, avatar visibile',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(progress: PlayerProgress.initial()),
          ),
        ),
      );
      expect(find.byKey(const Key('player_avatar')), findsOneWidget);
      expect(find.byKey(const Key('player_hud_title')), findsNothing);
      expect(find.text('Livello 1'), findsOneWidget);
    });

    testWidgets('con titolo: riga titolo sotto il livello', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerHud(
              progress: _progressWithTitle('Sentinella della Rete'),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('player_avatar')), findsOneWidget);
      expect(
        find.byKey(const Key('player_hud_title')),
        findsOneWidget,
      );
      expect(find.textContaining('Sentinella della Rete'), findsOneWidget);
    });
  });

  group('Home: avatar e picker', () {
    testWidgets('mostra avatar e apre il picker che cambia icona',
        (tester) async {
      final playerVm = PlayerViewModel();
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

      expect(find.byKey(const Key('player_avatar')), findsWidgets);
      await tester.tap(find.byKey(const Key('home_avatar_edit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('avatar_picker')), findsOneWidget);

      await tester.tap(find.byKey(const Key('avatar_icon_🦊')));
      await tester.pumpAndSettle();
      expect(playerVm.progress.avatarIconIndex, 1);
      expect(playerVm.progress.avatarIcon, '🦊');

      await tester.tap(find.byKey(const Key('avatar_picker_done')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('avatar_picker')), findsNothing);
    });

    testWidgets('mostra il titolo attivo in home', (tester) async {
      final playerVm = PlayerViewModel(
        initialProgress: _progressWithTitle('Architetto del Web'),
      );
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

      expect(find.byKey(const Key('home_player_title')), findsOneWidget);
      expect(find.textContaining('Architetto del Web'), findsWidgets);
      expect(find.byKey(const Key('player_hud_title')), findsOneWidget);
    });
  });
}
