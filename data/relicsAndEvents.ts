import { Relic, DungeonEvent } from '../types';

export const relics: Relic[] = [
  // Common Relics
  {
    id: 'debugger-lens',
    name: 'Debugger\'s Lens',
    description: 'At the start of each combat, Scry 2',
    rarity: 'common',
    effect: 'scry-2-start',
    icon: 'Eye'
  },
  {
    id: 'syntax-manual',
    name: 'Syntax Manual',
    description: 'Whenever you play 3 cards in a turn, draw 1 card',
    rarity: 'common',
    effect: 'draw-after-3',
    icon: 'BookOpen'
  },
  {
    id: 'coffee-mug',
    name: 'Coffee Mug',
    description: 'Start each combat with +1 Energy',
    rarity: 'common',
    effect: 'energy-1-start',
    icon: 'Coffee'
  },
  
  // Rare Relics
  {
    id: 'null-checker',
    name: 'Null Safety Checker',
    description: 'Your defense cards block 2 additional damage',
    rarity: 'rare',
    effect: 'defense-plus-2',
    icon: 'ShieldCheck'
  },
  {
    id: 'git-rewind',
    name: 'Git Rewind',
    description: 'Once per combat, return a card from your discard pile to your hand',
    rarity: 'rare',
    effect: 'resurrect-once',
    icon: 'RotateCcw'
  },
  {
    id: 'compiler-cache',
    name: 'Compiler Cache',
    description: 'Retain up to 2 cards between turns',
    rarity: 'rare',
    effect: 'retain-2',
    icon: 'Database'
  },
  
  // Epic Relics
  {
    id: 'perfect-algorithm',
    name: 'The Perfect Algorithm',
    description: 'Whenever you answer correctly, gain 3 Armor',
    rarity: 'epic',
    effect: 'armor-on-correct',
    icon: 'Sparkles'
  },
  {
    id: 'type-inference',
    name: 'Type Inference Engine',
    description: 'Your first card each turn costs 0 Energy',
    rarity: 'epic',
    effect: 'first-free',
    icon: 'Zap'
  },
  {
    id: 'rubber-duck',
    name: 'Rubber Duck Debugger',
    description: 'At the start of your turn, heal 2 HP',
    rarity: 'epic',
    effect: 'heal-2-turn',
    icon: 'HeartHandshake'
  },
  
  // Legendary Relics
  {
    id: 'architects-blueprint',
    name: 'Architect\'s Blueprint',
    description: 'Draw 2 additional cards at the start of each turn',
    rarity: 'legendary',
    effect: 'draw-2-start',
    icon: 'Layers'
  },
  {
    id: 'quantum-compiler',
    name: 'Quantum Compiler',
    description: 'You may play cards as if they cost 1 less Energy',
    rarity: 'legendary',
    effect: 'cost-reduce-1',
    icon: 'Cpu'
  }
];

export const narrativeEvents: DungeonEvent[] = [
  {
    id: 'mysterious-library',
    type: 'narrative',
    title: 'The Mysterious Library',
    description: 'You discover an ancient library filled with dusty tomes. The air smells of old paper and forgotten knowledge. A glowing book floats in the center, pulsing with mysterious energy.',
    theme: 'mystery',
    rarity: 'common',
    choices: [
      {
        text: 'Read the glowing book carefully',
        consequence: { type: 'card', value: 'knowledge-card' }
      },
      {
        text: 'Search the shelves for rare books',
        consequence: { type: 'hp', value: -10 }
      },
      {
        text: 'Leave the library respectfully',
        consequence: { type: 'reputation', value: 5 }
      }
    ]
  },
  {
    id: 'cursed-compiler',
    type: 'narrative',
    title: 'The Cursed Compiler',
    description: 'A corrupted compiler blocks your path. Its error messages are incomprehensible, and it radiates dark energy. "SYNTAX ERROR... EVERYWHERE..." it moans.',
    theme: 'bug-hunt',
    rarity: 'rare',
    choices: [
      {
        text: 'Debug the compiler (risky)',
        consequence: { type: 'hp', value: -15 }
      },
      {
        text: 'Offer a pristine codebase as tribute',
        consequence: { type: 'card', value: 'refactor-blast' }
      },
      {
        text: 'Rewrite from scratch',
        consequence: { type: 'reputation', value: 10 }
      }
    ]
  },
  {
    id: 'null-pointer-shrine',
    type: 'narrative',
    title: 'The Null Pointer Shrine',
    description: 'You encounter a shrine dedicated to the dreaded Null Pointer Exception. Offerings of defensive code litter the altar. A mystical voice whispers: "Protect yourself from the void..."',
    theme: 'mystery',
    rarity: 'rare',
    choices: [
      {
        text: 'Make an offering of your HP',
        consequence: { type: 'hp', value: -20 }
      },
      {
        text: 'Study the protective patterns',
        consequence: { type: 'card', value: 'null-safety' }
      },
      {
        text: 'Leave quickly',
        consequence: { type: 'reputation', value: -5 }
      }
    ]
  },
  {
    id: 'code-review-tribunal',
    type: 'narrative',
    title: 'The Code Review Tribunal',
    description: 'Senior developers surround you, demanding to review your code. They scrutinize every line with eagle eyes. "Show us your best refactoring!" they chant in unison.',
    theme: 'refactor',
    rarity: 'common',
    choices: [
      {
        text: 'Present your cleanest code',
        consequence: { type: 'reputation', value: 15 }
      },
      {
        text: 'Refactor on the spot (exhausting)',
        consequence: { type: 'hp', value: -5 }
      },
      {
        text: 'Explain your architecture',
        consequence: { type: 'card', value: 'code-strike' }
      }
    ]
  },
  {
    id: 'memory-leak-fountain',
    type: 'narrative',
    title: 'The Memory Leak Fountain',
    description: 'A fountain endlessly overflows with data, never garbage collected. The water promises power but at a cost. "Drink deeply..." it beckons, "...or not at all."',
    theme: 'bug-hunt',
    rarity: 'special',
    reputationRequired: 20,
    choices: [
      {
        text: 'Drink and gain power',
        consequence: { type: 'hp', value: 30 }
      },
      {
        text: 'Fix the leak (difficult)',
        consequence: { type: 'reputation', value: 25 }
      },
      {
        text: 'Study the patterns',
        consequence: { type: 'card', value: 'optimization' }
      }
    ]
  },
  {
    id: 'inheritance-maze',
    type: 'narrative',
    title: 'The Inheritance Maze',
    description: 'You find yourself in a labyrinth of class hierarchies. Each path represents a different inheritance chain. Some lead to treasure, others to circular dependencies.',
    theme: 'coding',
    rarity: 'rare',
    choices: [
      {
        text: 'Follow composition over inheritance',
        consequence: { type: 'reputation', value: 20 }
      },
      {
        text: 'Navigate the deepest inheritance',
        consequence: { type: 'hp', value: -10 }
      },
      {
        text: 'Refactor to use mixins',
        consequence: { type: 'card', value: 'bug-smash' }
      }
    ]
  },
  {
    id: 'async-void',
    type: 'narrative',
    title: 'The Async Void',
    description: 'You peer into an abyss of asynchronous operations. Promises float by, some resolved, others eternally pending. A Future whispers secrets of what might be.',
    theme: 'mystery',
    rarity: 'rare',
    choices: [
      {
        text: 'Await the promises patiently',
        consequence: { type: 'hp', value: 20 }
      },
      {
        text: 'Catch all exceptions',
        consequence: { type: 'card', value: 'syntax-shield' }
      },
      {
        text: 'Embrace the chaos',
        consequence: { type: 'reputation', value: -10 }
      }
    ]
  },
  {
    id: 'stack-overflow-merchant',
    type: 'merchant',
    title: 'Stack Overflow Merchant',
    description: 'A mysterious merchant appears, their cart filled with copy-pasted solutions from across the multiverse. "I have what you seek... for a price."',
    theme: 'coding',
    rarity: 'common',
    choices: [
      {
        text: 'Buy a premium card (20 HP)',
        consequence: { type: 'hp', value: -20 }
      },
      {
        text: 'Trade reputation for knowledge',
        consequence: { type: 'reputation', value: -10 }
      },
      {
        text: 'Ask for free advice',
        consequence: { type: 'card', value: 'debug-heal' }
      }
    ]
  }
];

export const bossThresholdPowers = {
  'chapter-1': {
    '75': {
      name: 'Syntax Surge',
      description: 'The boss attacks with increased syntax complexity',
      effect: 'extra-question'
    },
    '50': {
      name: 'Type Confusion',
      description: 'Questions become harder and time pressure increases',
      effect: 'harder-questions'
    },
    '25': {
      name: 'Final Compilation',
      description: 'Burn phase activated - rapid fire questions!',
      effect: 'burn-phase'
    }
  },
  'chapter-2': {
    '75': {
      name: 'Logic Overload',
      description: 'The boss creates complex logical chains',
      effect: 'extra-question'
    },
    '50': {
      name: 'Function Recursion',
      description: 'Questions loop back with increased difficulty',
      effect: 'harder-questions'
    },
    '25': {
      name: 'Stack Overflow',
      description: 'Overwhelming complexity - survive the barrage!',
      effect: 'burn-phase'
    }
  },
  'chapter-3': {
    '75': {
      name: 'Polymorphic Shift',
      description: 'The boss transforms, asking questions from multiple angles',
      effect: 'extra-question'
    },
    '50': {
      name: 'Inheritance Storm',
      description: 'Complex hierarchies challenge your understanding',
      effect: 'harder-questions'
    },
    '25': {
      name: 'Abstract Apocalypse',
      description: 'The final test of your OOP mastery!',
      effect: 'burn-phase'
    }
  }
};
