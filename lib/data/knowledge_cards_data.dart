import '../models/types.dart';

// Knowledge Cards - Special cards obtained from completing quizzes
// These cards don't deal damage but force boss questions on specific topics
final List<CardModel> knowledgeCards = [
  // Variables & Types Knowledge Card
  CardModel(
    id: 'knowledge_variables',
    name: 'Variables Mastery',
    type: CardType.knowledge,
    description: 'Force next question: Variables & Types',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '📚',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'variables-types',
    questionTopicFilter: 'variables-types',
    flavourText: '"The var keyword holds many secrets... or does it? The compiler knows, but it will never tell."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Operators Knowledge Card
  CardModel(
    id: 'knowledge_operators',
    name: 'Operators Expert',
    type: CardType.knowledge,
    description: 'Force next question: Operators',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🎓',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'operators',
    questionTopicFilter: 'operators',
    flavourText: '"++ or +=1? The ancient debate continues. Both lead to the same destination, yet the journey differs."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Functions Knowledge Card
  CardModel(
    id: 'knowledge_functions',
    name: 'Functions Scholar',
    type: CardType.knowledge,
    description: 'Force next question: Functions',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '📖',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'functions',
    questionTopicFilter: 'functions',
    flavourText: '"void returns nothing, yet teaches everything. Some say it\'s the most honest function of all."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Classes Knowledge Card
  CardModel(
    id: 'knowledge_classes',
    name: 'Classes Guru',
    type: CardType.knowledge,
    description: 'Force next question: Classes & Objects',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '📝',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'classes',
    questionTopicFilter: 'classes',
    flavourText: '"Private fields whisper secrets only their class can hear. Public methods scream them to the void."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Conditionals Knowledge Card
  CardModel(
    id: 'knowledge_conditionals',
    name: 'Conditionals Master',
    type: CardType.knowledge,
    description: 'Force next question: Conditionals',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🔀',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'conditionals',
    questionTopicFilter: 'conditionals',
    flavourText: '"If false, else. If false again, else. If you keep going, you\'ll find the truth... or a compiler error."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Loops Knowledge Card
  CardModel(
    id: 'knowledge_loops',
    name: 'Loops Virtuoso',
    type: CardType.knowledge,
    description: 'Force next question: Loops',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🔁',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'loops',
    questionTopicFilter: 'loops',
    flavourText: '"while(true) { break; } - The eternal struggle. To loop forever or escape? Choose wisely."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Collections Knowledge Card
  CardModel(
    id: 'knowledge_collections',
    name: 'Collections Sage',
    type: CardType.knowledge,
    description: 'Force next question: Collections',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '📦',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'collections',
    questionTopicFilter: 'collections',
    flavourText: '"[1, 2, 3]... The list knows its order. The Set refuses duplicates. The Map holds all answers."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Null Safety Knowledge Card
  CardModel(
    id: 'knowledge_null_safety',
    name: 'Null Safety Guardian',
    type: CardType.knowledge,
    description: 'Force next question: Null Safety',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🛡️',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'null-safety',
    questionTopicFilter: 'null-safety',
    flavourText: '"The ? guards the void. The ! screams certainty into darkness. Both fear the NullPointerException."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Inheritance Knowledge Card
  CardModel(
    id: 'knowledge_inheritance',
    name: 'Inheritance Maestro',
    type: CardType.knowledge,
    description: 'Force next question: Inheritance & Mixins',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🏛️',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'inheritance',
    questionTopicFilter: 'inheritance',
    flavourText: '"extends speaks of lineage. with mixin whispers of borrowed power. @override declares rebellion."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Async Knowledge Card
  CardModel(
    id: 'knowledge_async',
    name: 'Async Architect',
    type: CardType.knowledge,
    description: 'Force next question: Async & Futures',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '⏱️',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'async',
    questionTopicFilter: 'async',
    flavourText: '"await the Future, it says. The program pauses, reality fractures. Has the future already happened?"',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Widgets Knowledge Card
  CardModel(
    id: 'knowledge_widgets',
    name: 'Widgets Adept',
    type: CardType.knowledge,
    description: 'Force next question: Widgets Basics',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🧩',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'widgets',
    questionTopicFilter: 'widgets',
    flavourText: '"Everything is a widget, and every widget has its place."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // Layouts Knowledge Card
  CardModel(
    id: 'knowledge_layouts',
    name: 'Layouts Tactician',
    type: CardType.knowledge,
    description: 'Force next question: Layouts',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '📐',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'layouts',
    questionTopicFilter: 'layouts',
    flavourText: '"Row by row, column by column, order emerges from chaos."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),

  // State Management Knowledge Card
  CardModel(
    id: 'knowledge_state_management',
    name: 'State Keeper',
    type: CardType.knowledge,
    description: 'Force next question: State Management Basics',
    effect: 0,
    manaCost: 0,
    rarity: CardRarity.epic,
    icon: '🗂️',
    imageAsset: 'assets/images/cards/card_knowledge.png',
    topicId: 'state-management',
    questionTopicFilter: 'state-management',
    flavourText: '"Lift the state up, and the whole tree shall follow."',
    effects: [
      CardEffect(type: 'force_topic', value: 0, target: 'boss'),
    ],
  ),
];

// Helper function to get knowledge card by topic ID
CardModel? getKnowledgeCardByTopicId(String topicId) {
  try {
    return knowledgeCards.firstWhere((card) => card.topicId == topicId);
  } catch (e) {
    return null;
  }
}
