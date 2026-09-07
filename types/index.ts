export type TopicStatus = 'locked' | 'available' | 'in-progress' | 'completed';

export type TopicType = 'required' | 'optional';

export interface Resource {
  title: string;
  url: string;
  type: 'article' | 'video' | 'documentation';
}

export interface Topic {
  id: string;
  title: string;
  description: string;
  detailedDescription: string;
  type: TopicType;
  parentId: string | null;
  children: string[];
  chapterId: string;
  resources: Resource[];
}

export interface Question {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
  difficulty: 'easy' | 'medium' | 'hard';
}

export interface Quiz {
  topicId: string;
  questions: Question[];
}

export type CardRarity = 'common' | 'rare' | 'epic' | 'legendary';

export type CardKeyword = 'exhaust' | 'ethereal' | 'retain' | 'combo' | 'overload' | 'evolve' | 'discover';

export interface CardEffect {
  type: 'damage' | 'block' | 'heal' | 'draw' | 'energy' | 'scry' | 'vulnerable' | 'weak';
  value: number;
  target?: 'self' | 'enemy';
}

export interface Reward {
  id: string;
  name: string;
  type: 'attack' | 'defense' | 'utility';
  description: string;
  effect: number;
  manaCost: number;
  rarity: CardRarity;
  icon: string;
  synergies?: string[];
  keywords?: CardKeyword[];
  effects?: CardEffect[];
  evolvesInto?: string;
  evolveCondition?: string;
  comboEffect?: CardEffect[];
  overloadAmount?: number;
}

export interface Chapter {
  id: string;
  title: string;
  description: string;
  bossName: string;
  bossHp: number;
  topicIds: string[];
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  unlocked: boolean;
  unlockedAt?: Date;
}

export interface Relic {
  id: string;
  name: string;
  description: string;
  rarity: CardRarity;
  effect: string;
  icon: string;
}

export type DungeonRoomType = 'topic-quiz' | 'combat' | 'treasure' | 'choice' | 'rest' | 'merchant' | 'elite' | 'boss' | 'secret';

export interface DungeonRoom {
  id: string;
  type: DungeonRoomType;
  topicId?: string;
  eventId?: string;
  x: number;
  y: number;
  connections: string[];
  cleared: boolean;
  optional: boolean;
}

export interface DungeonEvent {
  id: string;
  type: 'combat' | 'treasure' | 'choice' | 'rest' | 'merchant' | 'narrative';
  title: string;
  description: string;
  theme?: 'mystery' | 'coding' | 'bug-hunt' | 'refactor';
  choices?: EventChoice[];
  reward?: string;
  rarity?: 'common' | 'rare' | 'special';
  reputationRequired?: number;
}

export interface EventChoice {
  text: string;
  consequence: {
    type: 'hp' | 'mana' | 'card' | 'reputation';
    value: number | string;
  };
}

export interface PlayerStats {
  maxHp: number;
  currentHp: number;
  maxEnergy: number;
  currentEnergy: number;
  armor: number;
  drawSize: number;
  level: number;
  experience: number;
}

export interface SkillNode {
  id: string;
  name: string;
  description: string;
  branch: 'offensive' | 'defensive' | 'utility';
  tier: number;
  cost: number;
  unlocked: boolean;
  prerequisite?: string;
  effect: {
    type: 'maxHp' | 'maxEnergy' | 'drawSize' | 'armor' | 'cardDamage' | 'cardBlock';
    value: number;
  };
}

export interface DungeonRun {
  id: string;
  currentRoomId: string | null;
  rooms: DungeonRoom[];
  playerStats: PlayerStats;
  reputation: number;
  floor: number;
  relics: string[];
  deck: string[];
  drawPile: string[];
  hand: string[];
  discardPile: string[];
  exhaustPile: string[];
  active: boolean;
  completedAt?: Date;
  ascensionLevel: number;
}

export interface TopicStats {
  topicId: string;
  attempts: number;
  correctAnswers: number;
  totalAnswers: number;
  averageTime: number;
  lastAttempt?: Date;
}

export interface RunHistory {
  id: string;
  completedAt: Date;
  floor: number;
  ascensionLevel: number;
  victory: boolean;
  finalScore: number;
  cardsCollected: number;
  elitesDefeated: number;
  bossesDefeated: number;
  duration: number;
}

export interface PlayerProgress {
  completedTopics: string[];
  currentTopic: string | null;
  inventory: string[];
  activeDeck: string[];
  chapterProgress: {
    [chapterId: string]: {
      bossHp: number;
      defeated: boolean;
    };
  };
  achievements: Achievement[];
  dungeonRun: DungeonRun | null;
  stats: {
    totalStudyTime: number;
    currentStreak: number;
    longestStreak: number;
    topicStats: TopicStats[];
  };
  playerStats: PlayerStats;
  skillTree: SkillNode[];
  relics: string[];
  ascensionLevel: number;
  prestigeLevel: number;
  runHistory: RunHistory[];
}

export interface BossQuestion extends Question {
  damage: number;
}
