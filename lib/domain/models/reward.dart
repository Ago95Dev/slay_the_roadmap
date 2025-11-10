class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final String previewAsset;
  final Map<String, dynamic> effect;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.previewAsset,
    required this.effect,
  });
}

enum RewardType { attack, defense, utility, special }
