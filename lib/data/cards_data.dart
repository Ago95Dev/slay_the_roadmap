import '../models/types.dart';
import 'knowledge_cards_data.dart';

// Carte Common - Base damage e block
final List<CardModel> commonCards = [
  // Attack Cards
  CardModel(
    id: 'strike',
    name: 'Strike',
    type: CardType.attack,
    description: 'Deal 6 damage',
    effect: 6,
    manaCost: 1,
    rarity: CardRarity.common,
    icon: '⚔️',
    imageAsset: 'assets/images/cards/card_slash.png',
    effects: [
      CardEffect(type: 'damage', value: 6, target: 'enemy'),
    ],
  ),
  CardModel(
    id: 'bash',
    name: 'Bash',
    type: CardType.attack,
    description: 'Deal 8 damage. Apply 2 Vulnerable.',
    effect: 8,
    manaCost: 2,
    rarity: CardRarity.common,
    icon: '🔨',
    imageAsset: 'assets/images/cards/card_slash.png',
    effects: [
      CardEffect(type: 'damage', value: 8, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 2,
        target: 'enemy',
        statusEffect: StatusEffect.vulnerable,
        statusStacks: 2,
      ),
    ],
  ),
  CardModel(
    id: 'twin_strike',
    name: 'Twin Strike',
    type: CardType.attack,
    description: 'Deal 5 damage twice',
    effect: 5,
    manaCost: 1,
    rarity: CardRarity.common,
    icon: '⚔️⚔️',
    imageAsset: 'assets/images/cards/card_slash.png',
    effects: [
      CardEffect(type: 'damage', value: 5, target: 'enemy'),
      CardEffect(type: 'damage', value: 5, target: 'enemy'),
    ],
  ),
  
  // Defense Cards
  CardModel(
    id: 'defend',
    name: 'Defend',
    type: CardType.defense,
    description: 'Gain 5 Block',
    effect: 5,
    manaCost: 1,
    rarity: CardRarity.common,
    icon: '🛡️',
    imageAsset: 'assets/images/cards/card_shield.png',
    effects: [
      CardEffect(type: 'block', value: 5, target: 'self'),
    ],
  ),
  CardModel(
    id: 'armored_defend',
    name: 'Armored Defend',
    type: CardType.defense,
    description: 'Gain 8 Block',
    effect: 8,
    manaCost: 2,
    rarity: CardRarity.common,
    icon: '🛡️',
    imageAsset: 'assets/images/cards/card_shield.png',
    effects: [
      CardEffect(type: 'block', value: 8, target: 'self'),
    ],
  ),
  CardModel(
    id: 'quick_shot',
    name: 'Quick Shot',
    type: CardType.attack,
    description: 'Deal 4 damage. Draw 1 card.',
    effect: 4,
    manaCost: 0,
    rarity: CardRarity.common,
    icon: '🏹',
    imageAsset: 'assets/images/cards/card_arrow.png',
    effects: [
      CardEffect(type: 'damage', value: 4, target: 'enemy'),
      CardEffect(type: 'draw', value: 1, target: 'self'),
    ],
  ),
  CardModel(
    id: 'fireball',
    name: 'Fireball',
    type: CardType.attack,
    description: 'Deal 12 damage.',
    effect: 12,
    manaCost: 2,
    rarity: CardRarity.common,
    icon: '🔥',
    imageAsset: 'assets/images/cards/card_fire.png',
    effects: [
      CardEffect(type: 'damage', value: 12, target: 'enemy'),
    ],
  ),
];

// Carte Rare - Con effetti speciali base
final List<CardModel> rareCards = [
  CardModel(
    id: 'poison_strike',
    name: 'Poison Strike',
    type: CardType.attack,
    description: 'Deal 7 damage. Apply 3 Poison.',
    effect: 7,
    manaCost: 1,
    rarity: CardRarity.rare,
    icon: '🧪',
    imageAsset: 'assets/images/cards/card_poison.png',
    effects: [
      CardEffect(type: 'damage', value: 7, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 3,
        target: 'enemy',
        statusEffect: StatusEffect.poison,
        statusStacks: 3,
      ),
    ],
  ),
  CardModel(
    id: 'piercing_shot',
    name: 'Piercing Shot',
    type: CardType.attack,
    description: 'Deal 10 damage. Pierce (ignores armor).',
    effect: 10,
    manaCost: 2,
    rarity: CardRarity.rare,
    icon: '🏹',
    imageAsset: 'assets/images/cards/card_arrow.png',
    effects: [
      CardEffect(
        type: 'damage',
        value: 10,
        target: 'enemy',
        statusEffect: StatusEffect.pierce,
      ),
    ],
  ),
  CardModel(
    id: 'bleeding_slash',
    name: 'Bleeding Slash',
    type: CardType.attack,
    description: 'Deal 8 damage. Apply 4 Bleed.',
    effect: 8,
    manaCost: 2,
    rarity: CardRarity.rare,
    icon: '🩸',
    imageAsset: 'assets/images/cards/card_blood.png',
    effects: [
      CardEffect(type: 'damage', value: 8, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 4,
        target: 'enemy',
        statusEffect: StatusEffect.bleed,
        statusStacks: 4,
      ),
    ],
  ),
  CardModel(
    id: 'frost_nova',
    name: 'Frost Nova',
    type: CardType.attack,
    description: 'Deal 6 damage. Apply 2 Freeze.',
    effect: 6,
    manaCost: 1,
    rarity: CardRarity.rare,
    icon: '❄️',
    imageAsset: 'assets/images/cards/card_ice.png',
    effects: [
      CardEffect(type: 'damage', value: 6, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 2,
        target: 'enemy',
        statusEffect: StatusEffect.freeze,
        statusStacks: 2,
      ),
    ],
  ),
  CardModel(
    id: 'immolate',
    name: 'Immolate',
    type: CardType.attack,
    description: 'Deal 9 damage. Apply 5 Burn.',
    effect: 9,
    manaCost: 2,
    rarity: CardRarity.rare,
    icon: '🔥',
    imageAsset: 'assets/images/cards/card_fire.png',
    keywords: [CardKeyword.exhaust],
    effects: [
      CardEffect(type: 'damage', value: 9, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 5,
        target: 'enemy',
        statusEffect: StatusEffect.burn,
        statusStacks: 5,
      ),
    ],
  ),
];

// Carte Epic - Combo potenti
final List<CardModel> epicCards = [
  CardModel(
    id: 'critical_strike',
    name: 'Critical Strike',
    type: CardType.attack,
    description: 'Deal 12 damage with 50% chance to deal double damage.',
    effect: 12,
    manaCost: 2,
    rarity: CardRarity.epic,
    icon: '💥',
    imageAsset: 'assets/images/cards/card_slash.png',
    effects: [
      CardEffect(
        type: 'damage',
        value: 12,
        target: 'enemy',
        statusEffect: StatusEffect.critical,
      ),
    ],
  ),
  CardModel(
    id: 'venomous_barrage',
    name: 'Venomous Barrage',
    type: CardType.attack,
    description: 'Deal 5 damage 3 times. Apply 2 Poison for each hit.',
    effect: 5,
    manaCost: 3,
    rarity: CardRarity.epic,
    icon: '🧪🧪🧪',
    imageAsset: 'assets/images/cards/card_poison.png',
    keywords: [CardKeyword.combo],
    effects: [
      CardEffect(type: 'damage', value: 5, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 2,
        target: 'enemy',
        statusEffect: StatusEffect.poison,
        statusStacks: 2,
      ),
    ],
    comboEffect: [
      CardEffect(type: 'damage', value: 5, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 2,
        target: 'enemy',
        statusEffect: StatusEffect.poison,
        statusStacks: 2,
      ),
      CardEffect(type: 'damage', value: 5, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 2,
        target: 'enemy',
        statusEffect: StatusEffect.poison,
        statusStacks: 2,
      ),
    ],
  ),
  CardModel(
    id: 'inferno',
    name: 'Inferno',
    type: CardType.attack,
    description: 'Deal 18 damage. Apply 8 Burn. Exhaust.',
    effect: 18,
    manaCost: 3,
    rarity: CardRarity.epic,
    icon: '🔥🔥🔥',
    imageAsset: 'assets/images/cards/card_fire.png',
    keywords: [CardKeyword.exhaust],
    effects: [
      CardEffect(type: 'damage', value: 18, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 8,
        target: 'enemy',
        statusEffect: StatusEffect.burn,
        statusStacks: 8,
      ),
    ],
  ),
  CardModel(
    id: 'glacial_prison',
    name: 'Glacial Prison',
    type: CardType.attack,
    description: 'Deal 10 damage. Apply 5 Freeze. Gain 10 Block.',
    effect: 10,
    manaCost: 3,
    rarity: CardRarity.epic,
    icon: '❄️🛡️',
    imageAsset: 'assets/images/cards/card_ice.png',
    keywords: [CardKeyword.retain],
    effects: [
      CardEffect(type: 'damage', value: 10, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 5,
        target: 'enemy',
        statusEffect: StatusEffect.freeze,
        statusStacks: 5,
      ),
      CardEffect(type: 'block', value: 10, target: 'self'),
    ],
  ),
  CardModel(
    id: 'hemorrhage',
    name: 'Hemorrhage',
    type: CardType.attack,
    description: 'Deal 15 damage. Apply Bleed equal to damage dealt.',
    effect: 15,
    manaCost: 3,
    rarity: CardRarity.epic,
    icon: '🩸💀',
    imageAsset: 'assets/images/cards/card_blood.png',
    keywords: [CardKeyword.exhaust],
    effects: [
      CardEffect(type: 'damage', value: 15, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 15,
        target: 'enemy',
        statusEffect: StatusEffect.bleed,
        statusStacks: 15,
      ),
    ],
  ),
];

// Carte Legendary - Poteri devastanti
final List<CardModel> legendaryCards = [
  CardModel(
    id: 'apocalypse',
    name: 'Apocalypse',
    type: CardType.attack,
    description: 'Deal 25 damage. Apply 10 Poison, 10 Burn, and 10 Bleed. Exhaust.',
    effect: 25,
    manaCost: 4,
    rarity: CardRarity.legendary,
    icon: '☠️',
    imageAsset: 'assets/images/cards/card_chaos.png',
    keywords: [CardKeyword.exhaust],
    effects: [
      CardEffect(type: 'damage', value: 25, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 10,
        target: 'enemy',
        statusEffect: StatusEffect.poison,
        statusStacks: 10,
      ),
      CardEffect(
        type: 'status',
        value: 10,
        target: 'enemy',
        statusEffect: StatusEffect.burn,
        statusStacks: 10,
      ),
      CardEffect(
        type: 'status',
        value: 10,
        target: 'enemy',
        statusEffect: StatusEffect.bleed,
        statusStacks: 10,
      ),
    ],
  ),
  CardModel(
    id: 'perfect_strike',
    name: 'Perfect Strike',
    type: CardType.attack,
    description: 'Deal 30 damage with guaranteed critical hit. Pierce.',
    effect: 30,
    manaCost: 3,
    rarity: CardRarity.legendary,
    icon: '✨⚔️',
    imageAsset: 'assets/images/cards/card_slash.png',
    keywords: [CardKeyword.ethereal],
    effects: [
      CardEffect(
        type: 'damage',
        value: 30,
        target: 'enemy',
        statusEffect: StatusEffect.critical,
      ),
      CardEffect(
        type: 'damage',
        value: 30,
        target: 'enemy',
        statusEffect: StatusEffect.pierce,
      ),
    ],
  ),
  CardModel(
    id: 'omega_protocol',
    name: 'Omega Protocol',
    type: CardType.utility,
    description: 'Draw 3 cards. Gain 3 Energy. Gain 15 Block. Overload 3.',
    effect: 3,
    manaCost: 1,
    rarity: CardRarity.legendary,
    icon: '⚡🎴',
    imageAsset: 'assets/images/cards/card_chaos.png',
    keywords: [CardKeyword.overload],
    overloadAmount: 3,
    effects: [
      CardEffect(type: 'draw', value: 3, target: 'self'),
      CardEffect(type: 'energy', value: 3, target: 'self'),
      CardEffect(type: 'block', value: 15, target: 'self'),
    ],
  ),
  CardModel(
    id: 'eternal_frost',
    name: 'Eternal Frost',
    type: CardType.attack,
    description: 'Deal 20 damage. Apply 15 Freeze. Retain. Gain 20 Block.',
    effect: 20,
    manaCost: 4,
    rarity: CardRarity.legendary,
    icon: '❄️👑',
    imageAsset: 'assets/images/cards/card_ice.png',
    keywords: [CardKeyword.retain],
    effects: [
      CardEffect(type: 'damage', value: 20, target: 'enemy'),
      CardEffect(
        type: 'status',
        value: 15,
        target: 'enemy',
        statusEffect: StatusEffect.freeze,
        statusStacks: 15,
      ),
      CardEffect(type: 'block', value: 20, target: 'self'),
    ],
  ),
];

// All cards combined
final List<CardModel> allCards = [
  ...commonCards,
  ...rareCards,
  ...epicCards,
  ...legendaryCards,
  ...knowledgeCards,
];

// Helper functions
CardModel? getCardById(String id) {
  try {
    // Handle unique IDs (e.g., "strike:123") by taking the part before the colon
    final baseId = id.split(':')[0];
    return allCards.firstWhere((card) => card.id == baseId);
  } catch (e) {
    return null;
  }
}

List<CardModel> getCardsByRarity(CardRarity rarity) {
  return allCards.where((card) => card.rarity == rarity).toList();
}

// Get card rarity color
String getCardRarityColor(CardRarity rarity) {
  switch (rarity) {
    case CardRarity.common:
      return '#9CA3AF'; // Gray
    case CardRarity.rare:
      return '#3B82F6'; // Blue
    case CardRarity.epic:
      return '#A855F7'; // Purple
    case CardRarity.legendary:
      return '#F59E0B'; // Gold
  }
}

// Get status effect description
String getStatusEffectDescription(StatusEffect effect) {
  switch (effect) {
    case StatusEffect.poison:
      return 'Deals damage at the end of turn';
    case StatusEffect.pierce:
      return 'Ignores enemy armor';
    case StatusEffect.critical:
      return 'Chance to deal double damage';
    case StatusEffect.bleed:
      return 'Loses HP when attacking';
    case StatusEffect.burn:
      return 'Takes increasing damage each turn';
    case StatusEffect.freeze:
      return 'Reduces enemy actions';
    case StatusEffect.vulnerable:
      return 'Takes 50% more damage';
    case StatusEffect.weak:
      return 'Deals 25% less damage';
    case StatusEffect.strength:
      return 'Increases damage dealt';
  }
}
