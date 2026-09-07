import '../models/types.dart';

// Boss Data
final List<Boss> bossesData = [
  // Chapter 1 Boss
  Boss(
    id: 'syntax_sentinel',
    name: 'Syntax Sentinel',
    description: 'Guardian of basic Dart syntax. Punishes incorrect type usage.',
    maxHp: 80,
    currentHp: 80,
    icon: '🤖',
    tier: 1,
    imageAsset: 'assets/images/bosses/syntax_sentinel.png',
    backgroundImage: 'assets/images/backgrounds/spire_bg.png',
    openingDialogue: [
      "HALT.",
      "COMPILE_ERROR: PLAYER_NOT_FOUND.",
      "INITIATING_TERMINATION_PROTOCOL..."
    ],
    abilities: [
      BossAbility(
        name: 'Type Error',
        description: 'Deal 8 damage and apply 2 Vulnerable',
        damage: 8,
        cooldown: 0,
        effects: [
          CardEffect(
            type: 'status',
            value: 2,
            target: 'enemy',
            statusEffect: StatusEffect.vulnerable,
            statusStacks: 2,
          ),
        ],
      ),
      BossAbility(
        name: 'Null Pointer',
        description: 'Deal 12 damage',
        damage: 12,
        cooldown: 2,
      ),
    ],
    thresholdPowers: {
      50: 'Gains +2 Strength when below 50% HP',
      25: 'Deals double damage when below 25% HP',
    },
  ),

  // Chapter 2 Boss
  Boss(
    id: 'logic_leviathan',
    name: 'Logic Leviathan',
    description: 'Master of control flow. Tests your understanding of loops and conditions.',
    maxHp: 120,
    currentHp: 120,
    icon: '🐉',
    tier: 2,
    imageAsset: 'assets/images/bosses/logic_lich.png',
    backgroundImage: 'assets/images/backgrounds/spire_bg.png',
    openingDialogue: [
      "Your logic is flawed.",
      "Let me correct it.",
      "There is no escape from this loop."
    ],
    abilities: [
      BossAbility(
        name: 'Infinite Loop',
        description: 'Deal 10 damage. Apply 3 Bleed.',
        damage: 10,
        cooldown: 1,
        effects: [
          CardEffect(
            type: 'status',
            value: 3,
            target: 'enemy',
            statusEffect: StatusEffect.bleed,
            statusStacks: 3,
          ),
        ],
      ),
      BossAbility(
        name: 'Stack Overflow',
        description: 'Deal 15 damage to player and self',
        damage: 15,
        cooldown: 3,
      ),
      BossAbility(
        name: 'Conditional Strike',
        description: 'Deal 8 damage. If player HP < 50%, deal 16 instead.',
        damage: 8,
        cooldown: 2,
      ),
    ],
    thresholdPowers: {
      60: 'Executes two abilities per turn',
      30: 'Applies 5 Poison at start of turn',
    },
  ),

  // Chapter 3 Final Boss
  Boss(
    id: 'abstraction_archon',
    name: 'Abstraction Archon',
    description: 'Ultimate OOP challenge. Master of inheritance and polymorphism.',
    maxHp: 180,
    currentHp: 180,
    icon: '👑',
    tier: 3,
    imageAsset: 'assets/images/bosses/bug_bear.png',
    backgroundImage: 'assets/images/backgrounds/spire_bg.png',
    openingDialogue: [
      "N-n-ull P-p-ointer...",
      "RRRRAAAH!",
      "SEGMENTATION FAULT (CORE DUMPED)"
    ],
    abilities: [
      BossAbility(
        name: 'Polymorphic Blast',
        description: 'Deal 12 damage. Changes type each turn.',
        damage: 12,
        cooldown: 0,
      ),
      BossAbility(
        name: 'Override',
        description: 'Deal 18 damage. Ignore all Block.',
        damage: 18,
        cooldown: 3,
        effects: [
          CardEffect(
            type: 'damage',
            value: 18,
            target: 'enemy',
            statusEffect: StatusEffect.pierce,
          ),
        ],
      ),
      BossAbility(
        name: 'Encapsulate',
        description: 'Gain 20 Block. Apply 4 Vulnerable to player.',
        damage: 0,
        cooldown: 2,
        effects: [
          CardEffect(
            type: 'status',
            value: 4,
            target: 'enemy',
            statusEffect: StatusEffect.vulnerable,
            statusStacks: 4,
          ),
        ],
      ),
      BossAbility(
        name: 'Async Apocalypse',
        description: 'Deal 25 damage. Apply 5 Burn, 5 Poison, 5 Bleed.',
        damage: 25,
        cooldown: 5,
        effects: [
          CardEffect(
            type: 'status',
            value: 5,
            target: 'enemy',
            statusEffect: StatusEffect.burn,
            statusStacks: 5,
          ),
          CardEffect(
            type: 'status',
            value: 5,
            target: 'enemy',
            statusEffect: StatusEffect.poison,
            statusStacks: 5,
          ),
          CardEffect(
            type: 'status',
            value: 5,
            target: 'enemy',
            statusEffect: StatusEffect.bleed,
            statusStacks: 5,
          ),
        ],
      ),
    ],
    thresholdPowers: {
      75: 'Summons a copy of last played card',
      50: 'Gains immunity to status effects',
      25: 'All abilities deal +10 damage',
    },
  ),
];

// Roadmap Nodes - Slay the Spire style
final List<RoadmapNode> roadmapNodes = [
  // ============ TIER 0 - START ============
  RoadmapNode(
    id: 'start',
    type: RoadmapNodeType.dungeonStart,
    title: 'Begin Journey',
    description: 'Start your Dart learning adventure',
    tier: 0,
    lane: 1,
    connections: ['node_1_0', 'node_1_1', 'node_1_2'],
    unlocked: true,
    completed: false,
    rewards: [],
    chapterId: 'chapter-1',
  ),

  // ============ TIER 1 - CHAPTER 1 START ============
  RoadmapNode(
    id: 'node_1_0',
    type: RoadmapNodeType.topic,
    topicId: 'variables-types',
    title: 'Variables & Types',
    description: 'Learn Dart basics',
    tier: 1,
    lane: 0,
    connections: ['node_2_0', 'node_2_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.common),
      RoadmapReward(type: 'experience', amount: 50),
    ],
    chapterId: 'chapter-1',
  ),
  RoadmapNode(
    id: 'node_1_1',
    type: RoadmapNodeType.topic,
    topicId: 'operators',
    title: 'Operators',
    description: 'Master Dart operators',
    tier: 1,
    lane: 1,
    connections: ['node_2_1', 'node_2_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.common),
      RoadmapReward(type: 'gold', amount: 100),
    ],
    chapterId: 'chapter-1',
  ),
  RoadmapNode(
    id: 'node_1_2',
    type: RoadmapNodeType.treasure,
    title: 'Treasure Chest',
    description: 'Choose a rare reward',
    tier: 1,
    lane: 2,
    connections: ['node_2_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'relic', id: 'thinking_cap'),
    ],
    chapterId: 'chapter-1',
  ),

  // ============ TIER 2 ============
  RoadmapNode(
    id: 'node_2_0',
    type: RoadmapNodeType.event,
    title: 'Code Review',
    description: 'A mysterious stranger offers help',
    tier: 2,
    lane: 0,
    connections: ['node_3_0'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'health', amount: 15),
      RoadmapReward(type: 'card', rarity: CardRarity.common),
    ],
    chapterId: 'chapter-1',
  ),
  RoadmapNode(
    id: 'node_2_1',
    type: RoadmapNodeType.topic,
    topicId: 'null-safety',
    title: 'Null Safety',
    description: 'Understand null safety',
    tier: 2,
    lane: 1,
    connections: ['node_3_0', 'node_3_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'experience', amount: 75),
    ],
    chapterId: 'chapter-1',
  ),
  RoadmapNode(
    id: 'node_2_2',
    type: RoadmapNodeType.rest,
    title: 'Rest Area',
    description: 'Restore HP or upgrade a card',
    tier: 2,
    lane: 2,
    connections: ['node_3_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'health', amount: 20),
    ],
    chapterId: 'chapter-1',
  ),

  // ============ TIER 3 - MINI BOSS ============
  RoadmapNode(
    id: 'node_3_0',
    type: RoadmapNodeType.elite,
    title: 'Debug Demon',
    description: 'An elite enemy blocks your path',
    tier: 3,
    lane: 0,
    connections: ['node_4_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'relic', id: 'debugger_charm'),
      RoadmapReward(type: 'gold', amount: 200),
    ],
    chapterId: 'chapter-1',
  ),
  RoadmapNode(
    id: 'node_3_1',
    type: RoadmapNodeType.treasure,
    title: 'Secret Cache',
    description: 'Hidden treasures await',
    tier: 3,
    lane: 2,
    connections: ['node_4_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'experience', amount: 100),
    ],
    chapterId: 'chapter-1',
  ),

  // ============ TIER 4 - CHAPTER 1 BOSS ============
  RoadmapNode(
    id: 'node_4_boss',
    type: RoadmapNodeType.boss,
    bossId: 'syntax_sentinel',
    title: 'Syntax Sentinel',
    description: 'Defeat the guardian of Chapter 1',
    tier: 4,
    lane: 1,
    connections: ['node_5_0', 'node_5_1', 'node_5_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'relic', id: 'syntax_crown'),
      RoadmapReward(type: 'experience', amount: 200),
      RoadmapReward(type: 'gold', amount: 300),
    ],
    chapterId: 'chapter-1',
  ),

  // ============ TIER 5 - CHAPTER 2 START ============
  RoadmapNode(
    id: 'node_5_0',
    type: RoadmapNodeType.topic,
    topicId: 'conditionals',
    title: 'Conditionals',
    description: 'Learn if-else statements',
    tier: 5,
    lane: 0,
    connections: ['node_6_0', 'node_6_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'experience', amount: 80),
    ],
    chapterId: 'chapter-2',
  ),
  RoadmapNode(
    id: 'node_5_1',
    type: RoadmapNodeType.topic,
    topicId: 'loops',
    title: 'Loops',
    description: 'Master iteration',
    tier: 5,
    lane: 1,
    connections: ['node_6_1', 'node_6_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'gold', amount: 150),
    ],
    chapterId: 'chapter-2',
  ),
  RoadmapNode(
    id: 'node_5_2',
    type: RoadmapNodeType.event,
    title: 'Pair Programming',
    description: 'Team up with another developer',
    tier: 5,
    lane: 2,
    connections: ['node_6_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.common),
      RoadmapReward(type: 'health', amount: 25),
    ],
    chapterId: 'chapter-2',
  ),

  // ============ TIER 6 ============
  RoadmapNode(
    id: 'node_6_0',
    type: RoadmapNodeType.rest,
    title: 'Coffee Break',
    description: 'Restore energy',
    tier: 6,
    lane: 0,
    connections: ['node_7_0'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'health', amount: 30),
    ],
    chapterId: 'chapter-2',
  ),
  RoadmapNode(
    id: 'node_6_1',
    type: RoadmapNodeType.topic,
    topicId: 'functions',
    title: 'Functions',
    description: 'Create powerful functions',
    tier: 6,
    lane: 1,
    connections: ['node_7_0', 'node_7_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'experience', amount: 100),
    ],
    chapterId: 'chapter-2',
  ),
  RoadmapNode(
    id: 'node_6_2',
    type: RoadmapNodeType.topic,
    topicId: 'collections',
    title: 'Collections',
    description: 'Master Lists, Sets, Maps',
    tier: 6,
    lane: 2,
    connections: ['node_7_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'gold', amount: 175),
    ],
    chapterId: 'chapter-2',
  ),

  // ============ TIER 7 - ELITE BATTLE ============
  RoadmapNode(
    id: 'node_7_0',
    type: RoadmapNodeType.elite,
    title: 'Recursion Wraith',
    description: 'A powerful recursive enemy',
    tier: 7,
    lane: 0,
    connections: ['node_8_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'relic', id: 'recursive_relic'),
      RoadmapReward(type: 'gold', amount: 250),
    ],
    chapterId: 'chapter-2',
  ),
  RoadmapNode(
    id: 'node_7_1',
    type: RoadmapNodeType.treasure,
    title: 'Library Archive',
    description: 'Ancient Dart knowledge',
    tier: 7,
    lane: 2,
    connections: ['node_8_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'relic', id: 'ancient_tome'),
    ],
    chapterId: 'chapter-2',
  ),

  // ============ TIER 8 - CHAPTER 2 BOSS ============
  RoadmapNode(
    id: 'node_8_boss',
    type: RoadmapNodeType.boss,
    bossId: 'logic_leviathan',
    title: 'Logic Leviathan',
    description: 'Master of control flow',
    tier: 8,
    lane: 1,
    connections: ['node_9_0', 'node_9_1', 'node_9_2'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'relic', id: 'logic_orb'),
      RoadmapReward(type: 'experience', amount: 300),
      RoadmapReward(type: 'gold', amount: 400),
    ],
    chapterId: 'chapter-2',
  ),

  // ============ TIER 9 - CHAPTER 3 START ============
  RoadmapNode(
    id: 'node_9_0',
    type: RoadmapNodeType.topic,
    topicId: 'classes',
    title: 'Classes & Objects',
    description: 'Enter the world of OOP',
    tier: 9,
    lane: 0,
    connections: ['node_10_0'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'experience', amount: 120),
    ],
    chapterId: 'chapter-3',
  ),
  RoadmapNode(
    id: 'node_9_1',
    type: RoadmapNodeType.topic,
    topicId: 'inheritance',
    title: 'Inheritance & Mixins',
    description: 'Extend your knowledge',
    tier: 9,
    lane: 1,
    connections: ['node_10_0', 'node_10_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.epic),
      RoadmapReward(type: 'gold', amount: 200),
    ],
    chapterId: 'chapter-3',
  ),
  RoadmapNode(
    id: 'node_9_2',
    type: RoadmapNodeType.event,
    title: 'Code Dojo',
    description: 'Train with masters',
    tier: 9,
    lane: 2,
    connections: ['node_10_1'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.rare),
      RoadmapReward(type: 'health', amount: 35),
    ],
    chapterId: 'chapter-3',
  ),

  // ============ TIER 10 ============
  RoadmapNode(
    id: 'node_10_0',
    type: RoadmapNodeType.elite,
    title: 'Polymorphic Phantom',
    description: 'Shape-shifting challenge',
    tier: 10,
    lane: 0,
    connections: ['node_11_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'relic', id: 'polymorphic_gem'),
      RoadmapReward(type: 'gold', amount: 300),
    ],
    chapterId: 'chapter-3',
  ),
  RoadmapNode(
    id: 'node_10_1',
    type: RoadmapNodeType.topic,
    topicId: 'async',
    title: 'Async & Futures',
    description: 'Master asynchronous code',
    tier: 10,
    lane: 2,
    connections: ['node_11_boss'],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'experience', amount: 150),
    ],
    chapterId: 'chapter-3',
  ),

  // ============ TIER 11 - FINAL BOSS ============
  RoadmapNode(
    id: 'node_11_boss',
    type: RoadmapNodeType.boss,
    bossId: 'abstraction_archon',
    title: 'Abstraction Archon',
    description: 'The ultimate Dart challenge',
    tier: 11,
    lane: 1,
    connections: [],
    unlocked: false,
    completed: false,
    rewards: [
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'card', rarity: CardRarity.legendary),
      RoadmapReward(type: 'relic', id: 'dart_mastery_crown'),
      RoadmapReward(type: 'experience', amount: 500),
      RoadmapReward(type: 'gold', amount: 1000),
    ],
    chapterId: 'chapter-3',
  ),
];

// Helper functions
Boss? getBossById(String id) {
  try {
    return bossesData.firstWhere((boss) => boss.id == id);
  } catch (e) {
    return null;
  }
}

RoadmapNode? getNodeById(String id) {
  try {
    return roadmapNodes.firstWhere((node) => node.id == id);
  } catch (e) {
    return null;
  }
}

List<RoadmapNode> getNodesByTier(int tier) {
  return roadmapNodes.where((node) => node.tier == tier).toList()
    ..sort((a, b) => a.lane.compareTo(b.lane));
}

List<RoadmapNode> getNodesByChapter(String chapterId) {
  return roadmapNodes.where((node) => node.chapterId == chapterId).toList();
}

int getMaxTier() {
  return roadmapNodes.map((node) => node.tier).reduce((a, b) => a > b ? a : b);
}
