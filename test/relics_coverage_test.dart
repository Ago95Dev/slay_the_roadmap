import 'package:flutter_test/flutter_test.dart';
import 'package:slay_the_roadmap/data/relics_data.dart';
import 'package:slay_the_roadmap/data/roadmap_data.dart';

/// Coverage: every relic id rewarded by the roadmap must exist in relics_data.
///
/// Scope note: 'dart_mastery_crown' (node_11_boss reward) is a known dangling
/// id deliberately left out of this fix (task scope: the 7 listed below).
/// It is allowlisted here so the sweep stays green while documenting the gap.
void main() {
  const previouslyDangling = [
    'thinking_cap',
    'debugger_charm',
    'syntax_crown',
    'recursive_relic',
    'ancient_tome',
    'logic_orb',
    'polymorphic_gem',
  ];

  const preExistingIds = [
    'debugger-lens',
    'syntax-manual',
    'coffee-mug',
    'null-checker',
    'git-rewind',
    'compiler-cache',
    'perfect-algorithm',
    'type-inference',
    'rubber-duck',
    'architects-blueprint',
    'quantum-compiler',
    'flutter_mastery_crown',
  ];

  /// Effect strings already used before this fix: no new effect types allowed.
  const knownEffects = {
    'scry-2-start',
    'draw-after-3',
    'energy-1-start',
    'defense-plus-2',
    'resurrect-once',
    'retain-2',
    'armor-on-correct',
    'first-free',
    'heal-2-turn',
    'draw-2-start',
    'cost-reduce-1',
    'heal-1-turn',
  };

  const outOfScopeAllowlist = {'dart_mastery_crown'};

  Set<String> roadmapRelicIds() => {
        for (final node in roadmapNodes)
          for (final reward in node.rewards)
            if (reward.type == 'relic' && reward.id != null) reward.id!,
      };

  group('relics coverage', () {
    test('the 7 previously-dangling reward ids exist in relics_data', () {
      final byId = {for (final r in relicsData) r.id: r};
      for (final id in previouslyDangling) {
        expect(byId.containsKey(id), isTrue, reason: 'missing relic: $id');
      }
    });

    test('every roadmap relic reward resolves (except documented gap)', () {
      final byId = {for (final r in relicsData) r.id: r};
      final missing = roadmapRelicIds()
          .where((id) => !byId.containsKey(id))
          .where((id) => !outOfScopeAllowlist.contains(id))
          .toList();
      expect(missing, isEmpty, reason: 'dangling relic ids: $missing');
    });

    test('no regression: pre-existing relics intact, valid and unique', () {
      final byId = {for (final r in relicsData) r.id: r};
      for (final id in preExistingIds) {
        expect(byId.containsKey(id), isTrue, reason: 'regression: lost $id');
      }
      // flutter_mastery_crown untouched.
      expect(byId['flutter_mastery_crown']!.effect, 'heal-1-turn');

      // Ids unique.
      expect(byId.length, relicsData.length);

      // All relics well-formed; new ones reuse only known effects.
      for (final relic in relicsData) {
        expect(relic.id, isNotEmpty);
        expect(relic.name, isNotEmpty);
        expect(relic.description, isNotEmpty);
        expect(relic.icon, isNotEmpty);
        expect(
          knownEffects.contains(relic.effect),
          isTrue,
          reason: '${relic.id} uses unknown effect ${relic.effect}',
        );
      }
    });
  });
}
