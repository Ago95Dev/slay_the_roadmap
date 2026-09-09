import 'package:flutter_test/flutter_test.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';

/// Curva 10 livelli (disegno approvato):
/// 0/100/500/1000/1600/2300/3100/4000/5000/6100.
PlayerProgress progressWith(int xp) => PlayerProgress(
      playerId: 'test',
      playerName: 'test',
      experience: xp,
      inventory: const PlayerInventory(rewards: []),
      lastSaved: DateTime(2026),
    );

void main() {
  group('Curva 10 livelli', () {
    test('maxLevel 10 e 10 soglie', () {
      expect(PlayerProgress.maxLevel, 10);
      expect(
        PlayerProgress.levelThresholds,
        [0, 100, 500, 1000, 1600, 2300, 3100, 4000, 5000, 6100],
      );
    });

    test('alias L2/L3 preservati', () {
      expect(PlayerProgress.level2Threshold, 100);
      expect(PlayerProgress.level3Threshold, 500);
    });

    test('boundary tutti i livelli', () {
      final cases = <int, int>{
        -10: 1,
        0: 1,
        99: 1,
        100: 2,
        499: 2,
        500: 3,
        999: 3,
        1000: 4,
        1599: 4,
        1600: 5,
        2299: 5,
        2300: 6,
        3099: 6,
        3100: 7,
        3999: 7,
        4000: 8,
        4999: 8,
        5000: 9,
        6099: 9,
        6100: 10,
        99999: 10,
      };
      for (final entry in cases.entries) {
        expect(
          PlayerProgress.levelForXp(entry.key),
          entry.value,
          reason: 'xp=${entry.key}',
        );
      }
    });

    test('845 → L3 con xpToNextLevel 155', () {
      expect(PlayerProgress.levelForXp(845), 3);
      final p = progressWith(845);
      expect(p.level, 3);
      expect(p.xpForNextLevel, 1000);
      expect(p.xpToNextLevel, 155);
    });

    test('compat HUD: next(100)==500, progress(50)==0.5', () {
      expect(PlayerProgress.xpForNextLevelOf(100), 500);
      expect(PlayerProgress.xpProgressOf(50), 0.5);
    });

    test('max livello: next null, progress 1.0', () {
      expect(PlayerProgress.xpForNextLevelOf(6100), isNull);
      expect(PlayerProgress.xpForNextLevelOf(99999), isNull);
      expect(PlayerProgress.xpProgressOf(6100), 1.0);
      final p = progressWith(6100);
      expect(p.xpForNextLevel, isNull);
      expect(p.xpToNextLevel, isNull);
      expect(p.xpProgress, 1.0);
    });

    test('getter istanza delegati agli statici', () {
      final p = progressWith(50);
      expect(p.xpForNextLevel, PlayerProgress.xpForNextLevelOf(50));
      expect(p.xpProgress, PlayerProgress.xpProgressOf(50));
    });
  });
}
