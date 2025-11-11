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
    // Return 3 random rewards for the topic completion
    final shuffled = List.of(_allRewards)..shuffle();
    return shuffled.take(3).toList();
  }
}
