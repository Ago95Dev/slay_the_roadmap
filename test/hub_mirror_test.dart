import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/config/hub_config.dart';
import 'package:slay_the_roadmap/models/types.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/services/engine_client.dart';

/// Scelta B — specchio Hub 1:1 delle fonti XP locali.
///
/// Ogni fonte XP locale invia la sua action Hub con shape snake_case
/// `data:{xp_amount,...}`; anti-farm invariati (una-tantum / solo vittoria).
/// Solo mock in RAM (FakeEngineClient), nessuna rete, nessun segreto.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  Future<GameProvider> makeLogged(String user) async {
    final provider = GameProvider();
    expect(await provider.registerLocal(user, 'pw'), isTrue);
    (provider.engine as FakeEngineClient).calls.clear();
    return provider;
  }

  List<Map<String, dynamic>> callsOf(GameProvider p, String action) =>
      (p.engine as FakeEngineClient)
          .calls
          .where((c) => c['actionId'] == action)
          .toList();

  group('hub mirror: ogni fonte invia la sua action', () {
    test('quiz pass → quiz_completed {xp_amount:100, badge}', () async {
      final p = await makeLogged('m_quiz');
      p.completeTopicQuiz('m_quiz_topic', 8, true);
      await settle();

      final quiz = callsOf(p, HubConfig.quizCompletedAction);
      expect(quiz, hasLength(1));
      expect(quiz.single['data']['xp_amount'], 100);
      expect(quiz.single['data']['badge'], 'm_quiz_topic');
      expect(p.playerStats.experience, 100);
    });

    test('boss → boss_defeated {badge}', () async {
      final p = await makeLogged('m_boss');
      p.defeatBoss('m_boss_1');
      await settle();

      final events = callsOf(p, HubConfig.bossDefeatedAction);
      expect(events, hasLength(1));
      expect(events.single['data']['badge'], 'm_boss_1');
    });

    test('completeTopic → topic_completed {xp_amount:50, badge}, una volta',
        () async {
      final p = await makeLogged('m_topic');
      p.completeTopic('m_topic_1');
      p.completeTopic('m_topic_1'); // re-complete: nessun reinvio
      await settle();

      final events = callsOf(p, HubConfig.topicCompletedAction);
      expect(events, hasLength(1));
      expect(events.single['data']['xp_amount'], 50);
      expect(events.single['data']['badge'], 'm_topic_1');
      expect(p.playerStats.experience, 50);
    });

    test('updateTopicStatus completed → topic_completed', () async {
      final p = await makeLogged('m_statustopic');
      p.updateTopicStatus('m_topic_2', TopicStatus.completed);
      await settle();

      final events = callsOf(p, HubConfig.topicCompletedAction);
      expect(events, hasLength(1));
      expect(events.single['data']['xp_amount'], 50);
      expect(events.single['data']['badge'], 'm_topic_2');
      expect(p.playerStats.experience, 50);
    });

    test('quiz pass NON invia anche topic_completed (niente doppio conteggio)',
        () async {
      final p = await makeLogged('m_noquizdouble');
      p.completeTopicQuiz('m_qztopic', 8, true);
      await settle();

      expect(callsOf(p, HubConfig.quizCompletedAction), hasLength(1));
      expect(callsOf(p, HubConfig.topicCompletedAction), isEmpty);
      expect(p.playerStats.experience, 100);
    });

    test('risorsa vista → resource_viewed {xp_amount:30, topic}; re-view mai',
        () async {
      final p = await makeLogged('m_res');
      final out = p.markResourceViewed('m_restopic', 0);
      expect(out['alreadyViewed'], isFalse);
      final out2 = p.markResourceViewed('m_restopic', 0);
      expect(out2['alreadyViewed'], isTrue);
      await settle();

      final events = callsOf(p, HubConfig.resourceViewedAction);
      expect(events, hasLength(1));
      expect(events.single['data']['xp_amount'], 30);
      expect(events.single['data']['topic'], 'm_restopic');
      expect(p.playerStats.experience, 30);
      expect(p.gold, 10);
    });

    test('dungeon vinto → dungeon_cleared {xp_amount:200, dungeon}', () async {
      final p = await makeLogged('m_dungeonwin');
      p.startDungeonRun(<Topic>[], 'chapter-1');
      p.completeDungeonRun(true);
      await settle();

      final events = callsOf(p, HubConfig.dungeonClearedAction);
      expect(events, hasLength(1));
      expect(events.single['data']['xp_amount'], 200);
      expect(events.single['data']['dungeon'], isNotEmpty);
      expect(p.playerStats.experience, 200);
    });

    test('dungeon perso → nessun invio, nessun XP', () async {
      final p = await makeLogged('m_dungeonloss');
      p.startDungeonRun(<Topic>[], 'chapter-1');
      p.completeDungeonRun(false);
      await settle();

      expect(callsOf(p, HubConfig.dungeonClearedAction), isEmpty);
      expect(p.playerStats.experience, 0);
    });

    test('daily claim → daily_login {xp_amount:25}, una volta al giorno',
        () async {
      final p = await makeLogged('m_daily');
      expect(p.claimDailyReward(), isTrue);
      expect(p.claimDailyReward(), isFalse);
      await settle();

      final events = callsOf(p, HubConfig.dailyLoginAction);
      expect(events, hasLength(1));
      expect(events.single['data']['xp_amount'], 25);
      expect(p.playerStats.experience, 25);
    });

    test('claim badge senza XP → claim_reward {badge, xp_amount:0}',
        () async {
      final p = await makeLogged('m_claim0');
      expect(p.claimRewardTopic('m_claim_topic'), isTrue);
      await settle();

      final claims = callsOf(p, HubConfig.claimRewardAction);
      expect(claims, hasLength(1));
      expect(claims.single['data']['badge'], 'm_claim_topic');
      expect(claims.single['data']['xp_amount'], 0);
    });

    test('nodo con reward experience → claim_reward con xp_amount=50',
        () async {
      final p = await makeLogged('m_claimexp');
      // node_1_0 (sbloccato dallo start): reward card (xp 0) + experience 50.
      p.completeRoadmapNode('node_1_0');
      await settle();

      final claims = callsOf(p, HubConfig.claimRewardAction);
      final amounts = claims.map((c) => c['data']['xp_amount']).toSet();
      expect(amounts, contains(50));
      expect(amounts, contains(0));
      // Nodo topic → anche topic_completed per il +50 del completamento.
      final topics = callsOf(p, HubConfig.topicCompletedAction);
      expect(topics, hasLength(1));
      expect(topics.single['data']['badge'], 'variables-types');
    });
  });
}
