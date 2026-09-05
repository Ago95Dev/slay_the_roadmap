import 'package:equatable/equatable.dart';

enum RewardType { attack, defense, utility, special }
enum RewardRarity { common, rare, epic, legendary }

class Reward extends Equatable {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final RewardRarity rarity;
  final String icon;
  final Map<String, dynamic> effects;
  final bool isSelected;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.icon,
    required this.effects,
    this.isSelected = false,
  });

  Reward copyWith({
    bool? isSelected,
  }) {
    return Reward(
      id: id,
      name: name,
      description: description,
      type: type,
      rarity: rarity,
      icon: icon,
      effects: effects,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  String get rarityColor {
    switch (rarity) {
      case RewardRarity.common:
        return '0xFF808080'; // Grey
      case RewardRarity.rare:
        return '0xFF008000'; // Green
      case RewardRarity.epic:
        return '0xFF800080'; // Purple
      case RewardRarity.legendary:
        return '0xFFFFD700'; // Gold
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    rarity,
    icon,
    effects,
    isSelected,
  ];
}

class PlayerInventory extends Equatable {
  final List<Reward> rewards;
  final int maxSlots;

  const PlayerInventory({
    required this.rewards,
    this.maxSlots = 20,
  });

  bool get hasEmptySlots => rewards.length < maxSlots;

  PlayerInventory addReward(Reward reward) {
    if (!hasEmptySlots) return this;
    return PlayerInventory(
      rewards: [...rewards, reward],
      maxSlots: maxSlots,
    );
  }

  PlayerInventory removeReward(String rewardId) {
    return PlayerInventory(
      rewards: rewards.where((r) => r.id != rewardId).toList(),
      maxSlots: maxSlots,
    );
  }

  @override
  List<Object?> get props => [rewards, maxSlots];
}
