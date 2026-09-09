import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/data/relics_data.dart';
import 'package:slay_the_roadmap/data/roadmap_data.dart';
import 'package:slay_the_roadmap/data/topics_and_quizzes.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/boss_fight_screen.dart';

/// Stabilizzazione merge fix/last_version-stabilize (capitolo-4 Flutter):
/// gate fail-closed + catena ch3→ARCHON→ch4→WARLORD, relic
/// flutter_mastery_crown, pool quiz boss su tutti i capitoli,
/// fight a 10 HP (numeri consegna US-04).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CH4 gate: catena ch3→ARCHON→ch4→WARLORD', () {
    test('node_11_boss (ARCHON) apre node_12_0 (primo topic ch4)', () {
      final archon = roadmapNodes.firstWhere((n) => n.id == 'node_11_boss');
      expect(
        archon.connections,
        contains('node_12_0'),
        reason: 'il boss ch3 deve aprire il capitolo 4',
      );
    });

    test('catena ch4 continua fino a WARLORD', () {
      String nextOf(String id) =>
          roadmapNodes.firstWhere((n) => n.id == id).connections.single;
      expect(nextOf('node_12_0'), 'node_13_0');
      expect(nextOf('node_13_0'), 'node_14_0');
      expect(nextOf('node_14_0'), 'node_15_boss');

      final warlord = roadmapNodes.firstWhere((n) => n.id == 'node_15_boss');
      expect(warlord.bossId, 'widget_warlord');
      expect(warlord.chapterId, 'chapter-4');
    });

    test('sconfiggere ARCHON sblocca il primo nodo ch4', () {
      final provider = GameProvider();
      expect(
        provider.roadmapNodes
            .firstWhere((n) => n.id == 'node_12_0')
            .unlocked,
        isFalse,
      );

      provider.defeatBoss('abstraction_archon');

      expect(
        provider.roadmapNodes
            .firstWhere((n) => n.id == 'node_12_0')
            .unlocked,
        isTrue,
      );
    });
  });

  group('CH4 relic: flutter_mastery_crown', () {
    test('definita in relics_data', () {
      expect(
        relicsData.map((r) => r.id),
        contains('flutter_mastery_crown'),
      );
    });

    test('claim reward nodo ch4 non produce id sconosciuti', () {
      final provider = GameProvider();
      final known = relicsData.map((r) => r.id).toSet();
      final node = provider.roadmapNodes.firstWhere(
        (n) => n.id == 'node_15_boss',
      );
      node.unlocked = true;
      provider.completeRoadmapNode('node_15_boss');

      expect(provider.relics, contains('flutter_mastery_crown'));
      expect(
        provider.relics.every(known.contains),
        isTrue,
        reason: 'ogni relic assegnata deve esistere in relics_data',
      );
    });
  });

  group('CH4 pool quiz boss', () {
    test('pool include domande ch4 (tutti i capitoli del dataset live)', () {
      final provider = GameProvider();
      final pool = provider.getRandomQuestionsFromTopics(200);
      final ch4Texts = ['widgets', 'layouts', 'state-management']
          .expand(
            (id) => getQuizByTopicId(id)!.questions.map((q) => q.question),
          )
          .toSet();
      final poolTexts = pool.map((q) => q.question).toSet();

      expect(
        poolTexts.intersection(ch4Texts),
        isNotEmpty,
        reason: 'i boss ch3-4 non devono usare solo domande ch1-2',
      );
    });

    test('pool copre tutte le domande del dataset live', () {
      final provider = GameProvider();
      final total = quizzesData.fold<int>(
        0,
        (sum, quiz) => sum + quiz.questions.length,
      );
      final pool = provider.getRandomQuestionsFromTopics(total + 100);
      expect(pool.length, total);
    });
  });

  group('CH4 boss fight: numeri consegna 10 HP', () {
    test('widget_warlord (tier 4 / 200 HP roadmap) combatte a 10 HP', () {
      final boss = getBossById('widget_warlord')!;
      expect(boss.tier, 4);
      expect(resolveBossFightHp(boss), 10);
    });

    test('tutti i boss roadmap mappati a 10 HP', () {
      for (final boss in bossesData) {
        expect(resolveBossFightHp(boss), 10, reason: boss.id);
      }
    });
  });
}
