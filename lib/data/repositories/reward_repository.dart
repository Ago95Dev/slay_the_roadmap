import '../../domain/models/reward.dart';

abstract class RewardRepository {
  Future<List<Reward>> getAvailableRewards();
  Future<List<Reward>> getRewardsForTopic(String topicId);
}

class LocalRewardRepository implements RewardRepository {
  final List<Reward> _allRewards = [
    Reward(
      id: 'fireball',
      name: 'Fireball',
      description: 'Launch a fireball that deals 15 damage to the boss',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '🔥',
      effects: {'damage': 15, 'cooldown': 2},
    ),
    Reward(
      id: 'shield',
      name: 'Magic Shield',
      description: 'Block 10 damage from the next boss attack',
      type: RewardType.defense,
      rarity: RewardRarity.common,
      icon: '🛡️',
      effects: {'block': 10, 'duration': 1},
    ),
    Reward(
      id: 'healing_potion',
      name: 'Healing Potion',
      description: 'Restore 25 HP',
      type: RewardType.utility,
      rarity: RewardRarity.common,
      icon: '🧪',
      effects: {'heal': 25},
    ),
    Reward(
      id: 'lightning_strike',
      name: 'Lightning Strike',
      description: 'Deal 25 damage and stun the boss for 1 turn',
      type: RewardType.attack,
      rarity: RewardRarity.rare,
      icon: '⚡',
      effects: {'damage': 25, 'stun': 1},
    ),
    Reward(
      id: 'time_warp',
      name: 'Time Warp',
      description: 'Take an extra turn immediately',
      type: RewardType.special,
      rarity: RewardRarity.epic,
      icon: '⏰',
      effects: {'extra_turn': true},
    ),
    Reward(
      id: 'mirror_shield',
      name: 'Mirror Shield',
      description: 'Reflect 50% of damage back to the boss',
      type: RewardType.defense,
      rarity: RewardRarity.rare,
      icon: '📯',
      effects: {'reflect': 0.5, 'duration': 2},
    ),
  ];

  @override
  Future<List<Reward>> getAvailableRewards() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allRewards;
  }

  @override
  Future<List<Reward>> getRewardsForTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 3 carte di 3 TIPI diversi: priorità attack, defense, utility
    // poi special; random dentro il tipo; fallback se un tipo esaurito.
    const priority = [
      RewardType.attack,
      RewardType.defense,
      RewardType.utility,
      RewardType.special,
    ];
    final picked = <Reward>[];
    final pickedIds = <String>{};
    for (final type in priority) {
      if (picked.length >= 3) break;
      final pool = _allRewards.where(
        (r) => r.type == type && !pickedIds.contains(r.id),
      ).toList()
        ..shuffle();
      if (pool.isNotEmpty) {
        picked.add(pool.first);
        pickedIds.add(pool.first.id);
      }
    }
    // Fallback: riempi con le rimanenti se qualche tipo era esaurito.
    if (picked.length < 3) {
      final rest = _allRewards.where(
        (r) => !pickedIds.contains(r.id),
      ).toList()
        ..shuffle();
      for (final r in rest) {
        if (picked.length >= 3) break;
        // Evita duplicati di tipo se possibile.
        if (picked.any((p) => p.type == r.type)) continue;
        picked.add(r);
        pickedIds.add(r.id);
      }
      // Ultima spiaggia: prendi comunque le rimanenti (tipi ripetuti).
      for (final r in rest) {
        if (picked.length >= 3) break;
        if (pickedIds.contains(r.id)) continue;
        picked.add(r);
        pickedIds.add(r.id);
      }
    }
    return picked;
  }
}
