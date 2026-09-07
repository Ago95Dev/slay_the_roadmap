import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/data/repositories/quiz_repository.dart';
import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/data/repositories/topic_detail_repository.dart';
import 'package:slay_the_roadmap/data/services/hub_identity.dart';
import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/domain/models/campaign.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/ui/screens/campaign_selection_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// F11: N campagne con selezione + coming soon + progress per campagna.

Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CampaignRepository.list', () {
    test('1 attiva (web_foundations) + 2 coming soon oneste', () {
      final campaigns = CampaignRepository.list();
      expect(campaigns, hasLength(3));

      final active =
          campaigns.where((c) => c.isActive).toList();
      expect(active, hasLength(1));
      expect(active.single.id, CampaignRepository.webFoundationsId);

      final soon =
          campaigns.where((c) => c.isComingSoon).toList();
      expect(soon, hasLength(2));
      for (final c in soon) {
        expect(c.subtitle, contains('Prossimamente'));
      }
    });

    test('isSelectable solo per la campagna attiva', () {
      expect(
          CampaignRepository.isSelectable(
              CampaignRepository.webFoundationsId),
          isTrue);
      expect(CampaignRepository.isSelectable('backend_arcana'), isFalse);
      expect(CampaignRepository.isSelectable('mobile_odyssey'), isFalse);
      expect(CampaignRepository.isSelectable('inesistente'), isFalse);
    });
  });

  group('Repository parametrizzati su campaignId', () {
    test('web_foundations (o null) = seed Web esistente', () async {
      final roadmap = LocalRoadmapRepository();
      expect(
          (await roadmap.getDartRoadmap()).map((t) => t.id),
          contains('web_network'));
      expect(
          (await roadmap.getDartRoadmap(
                  campaignId: CampaignRepository.webFoundationsId))
              .map((t) => t.id),
          contains('web_network'));

      final quiz = LocalQuizRepository();
      expect(
          (await quiz.getQuizForTopic('web_network')).questions,
          isNotEmpty);
      expect(
          (await quiz.getQuizForTopic('web_network',
                  campaignId: CampaignRepository.webFoundationsId))
              .questions,
          isNotEmpty);

      final detail = LocalTopicDetailRepository();
      expect(
          await detail.getTopicDetail('web_network'), isNotNull);

      final boss = BossRepository();
      expect(await boss.getBossById('man_in_the_middle'), isNotNull);
      expect(BossRepository.chapterTopicIds('web_network'), isNotEmpty);
    });

    test('coming soon e id ignoti lanciano StateError, mai contenuti',
        () async {
      const soon = 'backend_arcana';
      final roadmap = LocalRoadmapRepository();
      expect(() => roadmap.getDartRoadmap(campaignId: soon),
          throwsStateError);
      expect(() => roadmap.getTopicWithDetail('web_network', campaignId: soon),
          throwsStateError);

      final quiz = LocalQuizRepository();
      expect(() => quiz.getQuizForTopic('web_network', campaignId: soon),
          throwsStateError);

      final detail = LocalTopicDetailRepository();
      expect(() => detail.getTopicDetail('web_network', campaignId: soon),
          throwsStateError);
      expect(() => detail.getAllTopicDetails(campaignId: soon),
          throwsStateError);

      final boss = BossRepository();
      expect(() => boss.getAllBosses(campaignId: soon), throwsStateError);
      expect(() => boss.getBossById('man_in_the_middle', campaignId: soon),
          throwsStateError);
      expect(
          () => boss.getBossByChapterId('web_network', campaignId: soon),
          throwsStateError);
      expect(() => BossRepository.chapterTopicIds('web_network', soon),
          throwsStateError);
      expect(() => BossRepository.chapterTopicIds('web_network', 'xx'),
          throwsStateError);
    });
  });

  group('Progress isolati per campagna (bucket)', () {
    test('web e altra campagna non si vedono a vicenda', () async {
      final prefs = await SharedPreferences.getInstance();
      final web = SharedPreferencesPersistence.forUser(prefs, 'u1');
      final other = SharedPreferencesPersistence.forUser(prefs, 'u1',
          campaignId: 'future_campaign');

      await web.savePlayerProgress(PlayerProgress.initial().copyWith(
        playerName: 'Ada',
        completedTopicIds: const ['web_network'],
      ));
      await web.saveClaimedRewardTopics({'web_network'});

      expect(await other.loadPlayerProgress(), isNull);
      expect(await other.loadClaimedRewardTopics(), isEmpty);
      expect(await other.hasSave(), isFalse);

      await other.savePlayerProgress(PlayerProgress.initial().copyWith(
        playerName: 'Ada',
        experience: 500,
      ));
      expect(await web.hasSave(), isTrue);

      final webProgress = await web.loadPlayerProgress();
      expect(webProgress!.completedTopicIds, ['web_network']);
      expect(webProgress.experience, 0);
      final otherProgress = await other.loadPlayerProgress();
      expect(otherProgress!.experience, 500);
      expect(otherProgress.completedTopicIds, isEmpty);
    });

    test('resetProgress cancella solo il bucket corrente', () async {
      final prefs = await SharedPreferences.getInstance();
      final web = SharedPreferencesPersistence.forUser(prefs, 'u1');
      final other = SharedPreferencesPersistence.forUser(prefs, 'u1',
          campaignId: 'future_campaign');

      await web.savePlayerProgress(PlayerProgress.initial()
          .copyWith(completedTopicIds: const ['web_network']));
      await other.savePlayerProgress(
          PlayerProgress.initial().copyWith(experience: 500));

      await web.resetProgress();
      expect(await web.loadPlayerProgress(), isNull);
      expect(await web.hasSave(), isFalse);
      expect((await other.loadPlayerProgress())!.experience, 500);
    });
  });

  group('Migrazione progress esistente → web_foundations', () {
    test('envelope vecchio formato letto come web_foundations', () async {
      final prefs = await SharedPreferences.getInstance();
      // Save pre-F11: envelope piatto sotto slay_data_<id>.
      final progress = PlayerProgress.initial().copyWith(
        playerName: 'VecchioEroe',
        experience: 200,
        completedTopicIds: const ['web_network'],
      );
      await prefs.setString(
        SharedPreferencesPersistence.dataKey('u1'),
        jsonEncode({
          'progress': progress.toJson(),
          'completedTopicIds': progress.completedTopicIds,
          'claimedRewardTopics': ['web_network'],
        }),
      );

      final store = UserStore(prefs);
      final web = store.dataFor('u1');
      final restored = await web.loadPlayerProgress();
      expect(restored, isNotNull);
      expect(restored!.playerName, 'VecchioEroe');
      expect(restored.experience, 200);
      expect(restored.completedTopicIds, ['web_network']);
      expect(await web.loadClaimedRewardTopics(), {'web_network'});
      expect(await web.hasSave(), isTrue);

      // Dopo un salvataggio l'envelope è nel nuovo formato a mappe.
      await web.savePlayerProgress(restored);
      final raw = jsonDecode(
          prefs.getString(SharedPreferencesPersistence.dataKey('u1'))!);
      expect((raw as Map)['campaigns'], isA<Map>());
      expect(raw['campaigns']['web_foundations'], isA<Map>());
      expect(await web.loadCampaignIds(), {'web_foundations'});
    });

    test('legacy slay_save_v1 singolo migrato come web_foundations', () async {
      final prefs = await SharedPreferences.getInstance();
      await SharedPreferencesPersistence(prefs).savePlayerProgress(
        PlayerProgress.initial()
            .copyWith(completedTopicIds: const ['web_network']),
      );
      final loaded =
          await SharedPreferencesPersistence(prefs).loadPlayerProgress();
      expect(loaded!.completedTopicIds, ['web_network']);
    });
  });

  group('hubPlayerId per coppia utente×campagna', () {
    test('formato slay_<userId>_<campaignId>', () {
      expect(HubIdentity.playerIdFor('u1'), 'slay_u1_web_foundations');
      expect(HubIdentity.playerIdFor('u1', 'web_foundations'),
          'slay_u1_web_foundations');
      expect(SessionController.hubPlayerIdFor('u1'),
          'slay_u1_web_foundations');
      expect(
          SessionController.hubPlayerIdFor('u1', 'web_foundations'),
          'slay_u1_web_foundations');
    });

    test('sessione usa il suffisso campagna', () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      final id = session.activeProfile!.userId;
      expect(session.activeCampaignId, 'web_foundations');
      expect(session.player!.hubPlayerId, 'slay_${id}_web_foundations');

      await session.selectCampaign('web_foundations');
      expect(session.player!.hubPlayerId, 'slay_${id}_web_foundations');
    });
  });

  group('SessionController selezione campagna', () {
    test('register → da selezionare; select → ok; coming soon → ko',
        () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      expect(session.hasSelectedCampaign, isFalse);

      await session.selectCampaign('web_foundations');
      expect(session.hasSelectedCampaign, isTrue);
      expect(session.activeCampaignId, 'web_foundations');
      expect(session.player, isNotNull);
      expect(session.roadmap!.topics, isNotEmpty);

      expect(() => session.selectCampaign('backend_arcana'),
          throwsStateError);
      expect(() => session.selectCampaign('inesistente'), throwsStateError);
      // La sessione resta sulla campagna corrente, progress intatti.
      expect(session.activeCampaignId, 'web_foundations');
      expect(session.hasSelectedCampaign, isTrue);
    });

    test('select senza utente attivo → StateError', () async {
      final session = SessionController(await _store());
      expect(() => session.selectCampaign('web_foundations'),
          throwsStateError);
    });

    test('backToCampaignSelection + login persistono la scelta (BUG 1)',
        () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      await session.selectCampaign('web_foundations');
      session.player!.addCompletedTopic('web_network');
      await Future.delayed(const Duration(milliseconds: 100));

      await session.backToCampaignSelection();
      expect(session.hasSelectedCampaign, isFalse);
      // I progress salvati sono intatti dietro la selezione.
      expect(session.player!.progress.completedTopicIds, ['web_network']);

      // Il bootstrap non riapre nulla: serve login esplicito, che rilegge
      // scelta campagna + progressi persistiti.
      final second = SessionController(store);
      await second.login(username: 'Ada', password: 'x');
      expect(second.hasSelectedCampaign, isFalse);
      expect(second.player!.progress.completedTopicIds, ['web_network']);

      await second.selectCampaign('web_foundations');
      final third = SessionController(store);
      await third.login(username: 'Ada', password: 'x');
      expect(third.hasSelectedCampaign, isTrue);
      expect(third.activeCampaignId, 'web_foundations');
      expect(third.player!.progress.completedTopicIds, ['web_network']);
    });

    test('logout azzera anche la campagna', () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      await session.selectCampaign('web_foundations');
      await session.logout();
      expect(session.hasSelectedCampaign, isFalse);
      expect(session.activeCampaignId, 'web_foundations');
    });
  });

  group('CampaignSelectionScreen', () {
    testWidgets('lista 1 attiva + 2 coming soon disabilitate',
        (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.register(username: 'Ada', password: 'x');
      });

      await tester.pumpWidget(
        MaterialApp(home: CampaignSelectionScreen(session: session)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('campaign_web_foundations')),
          findsOneWidget);
      expect(find.byKey(const Key('campaign_backend_arcana')),
          findsOneWidget);
      expect(find.byKey(const Key('campaign_mobile_odyssey')),
          findsOneWidget);
      expect(find.byKey(const Key('campaign_play_web_foundations')),
          findsOneWidget);

      // Coming soon: bottoni disabilitati (onPressed null).
      for (final id in ['backend_arcana', 'mobile_odyssey']) {
        final button = tester.widget<OutlinedButton>(
          find.byKey(Key('campaign_soon_$id')),
        );
        expect(button.onPressed, isNull);
      }
      expect(find.text('Prossimamente'), findsNWidgets(2));
    });

    testWidgets('Gioca seleziona la campagna', (tester) async {
      final session = SessionController(await _store());
      await tester.runAsync(() async {
        await session.register(username: 'Ada', password: 'x');
      });
      expect(session.hasSelectedCampaign, isFalse);

      await tester.pumpWidget(
        MaterialApp(home: CampaignSelectionScreen(session: session)),
      );
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const Key('campaign_play_web_foundations')));
      await tester.pumpAndSettle();

      expect(session.hasSelectedCampaign, isTrue);
      expect(session.activeCampaignId, 'web_foundations');
    });
  });
}
