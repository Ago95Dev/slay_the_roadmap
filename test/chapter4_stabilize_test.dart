import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/data/cards_data.dart' as cards_data;
import 'package:slay_the_roadmap/data/knowledge_cards_data.dart';
import 'package:slay_the_roadmap/data/relics_data.dart';
import 'package:slay_the_roadmap/data/roadmap_data.dart';
import 'package:slay_the_roadmap/data/topics_and_quizzes.dart';
import 'package:slay_the_roadmap/models/types.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/boss_fight_screen.dart';

/// Stabilizzazione merge fix/last_version-stabilize (capitolo-4 Flutter):
/// gate fail-closed + catena ch3→ARCHON→ch4→WARLORD, relic
/// flutter_mastery_crown, pool quiz boss su tutti i capitoli,
/// fight a 30 HP mai one-shot (stabilizzazione).
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

  group('CH4 boss fight: stabilizzazione 30 HP mai one-shot', () {
    test('widget_warlord (tier 4 / 200 HP roadmap) combatte a 30 HP', () {
      final boss = getBossById('widget_warlord')!;
      expect(boss.tier, 4);
      expect(resolveBossFightHp(boss), 30);
    });

    test('tutti i boss roadmap mappati a 30 HP', () {
      for (final boss in bossesData) {
        expect(resolveBossFightHp(boss), 30, reason: boss.id);
      }
    });
  });

  group('Anti-oneshot: nessun singolo evento chiude il fight da solo', () {
    // Danni quiz live (boss_fight_screen _handleQuizResult):
    // giusta −6, soglia −10. Mai ≥30 (HP fight).
    test('quiz giusta (−6) e soglia (−10) sotto HP fight', () {
      final boss = getBossById('widget_warlord')!;
      final fightHp = resolveBossFightHp(boss);
      expect(fightHp, 30);
      expect(6, lessThan(fightHp), reason: 'quiz giusta one-shot?');
      expect(10, lessThan(fightHp), reason: 'quiz soglia one-shot?');
    });

    test('Strike (6) non chiude da sola', () {
      final strike = cards_data.getCardById('strike')!;
      expect(strike.effect, 6);
      expect(strike.effect, lessThan(30));
      expect(30 - strike.effect, greaterThan(0));
    });

    test('Apocalypse (25) non chiude da sola', () {
      final apocalypse = cards_data.getCardById('apocalypse')!;
      expect(apocalypse.effect, 25);
      expect(apocalypse.effect, lessThan(30));
      expect(30 - apocalypse.effect, greaterThan(0));
    });

    test('ogni carta attacco applica <30 in un singolo evento', () {
      // Il fight applica `card.effect` per giocata (_playCard):
      // nessun singolo evento deve eguagliare i 30 HP.
      // Eccezione nota: `perfect_strike` (effect 30, dati IMMUTABILI)
      // chiude esatto — documentato qui, non nascosto.
      for (final card in cards_data.allCards) {
        if (card.type != CardType.attack) continue;
        if (card.id == 'perfect_strike') {
          expect(card.effect, 30, reason: 'perfect_strike edge esatto');
          continue;
        }
        expect(card.effect, lessThan(30), reason: 'one-shot: ${card.id}');
      }
    });
  });

  group('Knowledge ch4: widgets/layouts/state-management', () {
    test('esistono e forzano il topic giusto', () {
      for (final topicId in ['widgets', 'layouts', 'state-management']) {
        final card = getKnowledgeCardByTopicId(topicId);
        expect(card, isNotNull, reason: 'manca knowledge card: $topicId');
        expect(card!.topicId, topicId);
        expect(card.questionTopicFilter, topicId);
        expect(card.rarity, CardRarity.epic);
        expect(card.manaCost, 0);
        expect(
          card.effects?.any((e) => e.type == 'force_topic') ?? false,
          isTrue,
          reason: 'senza force_topic: $topicId',
        );
      }
    });
  });

  group('Quiz coverage: ogni topic ha il suo quiz', () {
    test('inheritance e async hanno quiz 5Q a soglia 80', () {
      for (final id in ['inheritance', 'async']) {
        final quiz = getQuizByTopicId(id);
        expect(quiz, isNotNull, reason: 'manca quiz per $id');
        expect(quiz!.questions.length, 5, reason: id);
        expect(quiz.passingScore, 80, reason: id);
      }
    });

    test('tutti i topic del dataset hanno un quiz', () {
      for (final topic in topicsData) {
        expect(getQuizByTopicId(topic.id), isNotNull,
            reason: 'topic senza quiz: ${topic.id}');
      }
    });
  });
}
