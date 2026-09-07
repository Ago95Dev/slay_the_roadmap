import '../models/types.dart';

final List<Relic> relicsData = [
  // Common Relics
  Relic(
    id: 'debugger-lens',
    name: 'Debugger\'s Lens',
    description: 'At the start of each combat, Scry 2',
    rarity: CardRarity.common,
    effect: 'scry-2-start',
    icon: 'visibility',
  ),
  Relic(
    id: 'syntax-manual',
    name: 'Syntax Manual',
    description: 'Whenever you play 3 cards in a turn, draw 1 card',
    rarity: CardRarity.common,
    effect: 'draw-after-3',
    icon: 'menu_book',
  ),
  Relic(
    id: 'coffee-mug',
    name: 'Coffee Mug',
    description: 'Start each combat with +1 Energy',
    rarity: CardRarity.common,
    effect: 'energy-1-start',
    icon: 'local_cafe',
  ),

  // Rare Relics
  Relic(
    id: 'null-checker',
    name: 'Null Safety Checker',
    description: 'Your defense cards block 2 additional damage',
    rarity: CardRarity.rare,
    effect: 'defense-plus-2',
    icon: 'verified_user',
  ),
  Relic(
    id: 'git-rewind',
    name: 'Git Rewind',
    description: 'Once per combat, return a card from your discard pile to your hand',
    rarity: CardRarity.rare,
    effect: 'resurrect-once',
    icon: 'restore',
  ),
  Relic(
    id: 'compiler-cache',
    name: 'Compiler Cache',
    description: 'Retain up to 2 cards between turns',
    rarity: CardRarity.rare,
    effect: 'retain-2',
    icon: 'storage',
  ),

  // Epic Relics
  Relic(
    id: 'perfect-algorithm',
    name: 'The Perfect Algorithm',
    description: 'Whenever you answer correctly, gain 3 Armor',
    rarity: CardRarity.epic,
    effect: 'armor-on-correct',
    icon: 'auto_awesome',
  ),
  Relic(
    id: 'type-inference',
    name: 'Type Inference Engine',
    description: 'Your first card each turn costs 0 Energy',
    rarity: CardRarity.epic,
    effect: 'first-free',
    icon: 'flash_on',
  ),
  Relic(
    id: 'rubber-duck',
    name: 'Rubber Duck Debugger',
    description: 'At the start of your turn, heal 2 HP',
    rarity: CardRarity.epic,
    effect: 'heal-2-turn',
    icon: 'favorite',
  ),

  // Legendary Relics
  Relic(
    id: 'architects-blueprint',
    name: 'Architect\'s Blueprint',
    description: 'Draw 2 additional cards at the start of each turn',
    rarity: CardRarity.legendary,
    effect: 'draw-2-start',
    icon: 'layers',
  ),
  Relic(
    id: 'quantum-compiler',
    name: 'Quantum Compiler',
    description: 'You may play cards as if they cost 1 less Energy',
    rarity: CardRarity.legendary,
    effect: 'cost-reduce-1',
    icon: 'memory',
  ),
];

final Map<String, Map<String, dynamic>> bossThresholdPowers = {
  'chapter-1': {
    '75': {
      'name': 'Syntax Surge',
      'description': 'The boss attacks with increased syntax complexity',
      'effect': 'extra-question',
    },
    '50': {
      'name': 'Type Confusion',
      'description': 'Questions become harder and time pressure increases',
      'effect': 'harder-questions',
    },
    '25': {
      'name': 'Final Compilation',
      'description': 'Burn phase activated - rapid fire questions!',
      'effect': 'burn-phase',
    },
  },
  'chapter-2': {
    '75': {
      'name': 'Logic Overload',
      'description': 'The boss creates complex logical chains',
      'effect': 'extra-question',
    },
    '50': {
      'name': 'Function Recursion',
      'description': 'Questions loop back with increased difficulty',
      'effect': 'harder-questions',
    },
    '25': {
      'name': 'Stack Overflow',
      'description': 'Overwhelming complexity - survive the barrage!',
      'effect': 'burn-phase',
    },
  },
  'chapter-3': {
    '75': {
      'name': 'Polymorphic Shift',
      'description': 'The boss transforms, asking questions from multiple angles',
      'effect': 'extra-question',
    },
    '50': {
      'name': 'Inheritance Storm',
      'description': 'Complex hierarchies challenge your understanding',
      'effect': 'harder-questions',
    },
    '25': {
      'name': 'Abstract Apocalypse',
      'description': 'The final test of your OOP mastery!',
      'effect': 'burn-phase',
    },
  },
};
