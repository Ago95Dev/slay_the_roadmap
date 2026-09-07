import { SkillNode } from '../types';

export const initialSkillTree: SkillNode[] = [
  // OFFENSIVE BRANCH
  {
    id: 'off-tier1-damage',
    name: 'Power Strike',
    description: 'Increase damage of attack cards by 2',
    branch: 'offensive',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'cardDamage',
      value: 2
    }
  },
  {
    id: 'off-tier1-energy',
    name: 'Adrenaline',
    description: 'Start each combat with +1 Energy',
    branch: 'offensive',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'maxEnergy',
      value: 1
    }
  },
  {
    id: 'off-tier2-crit',
    name: 'Critical Thinking',
    description: 'Attack cards deal +5 damage',
    branch: 'offensive',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'off-tier1-damage',
    effect: {
      type: 'cardDamage',
      value: 5
    }
  },
  {
    id: 'off-tier2-combo',
    name: 'Combo Master',
    description: 'Playing 3 cards in a turn grants +1 Energy next turn',
    branch: 'offensive',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'off-tier1-energy',
    effect: {
      type: 'maxEnergy',
      value: 0
    }
  },
  {
    id: 'off-tier3-burst',
    name: 'Burst Damage',
    description: 'Attack cards deal +10 damage',
    branch: 'offensive',
    tier: 3,
    cost: 3,
    unlocked: false,
    prerequisite: 'off-tier2-crit',
    effect: {
      type: 'cardDamage',
      value: 10
    }
  },

  // DEFENSIVE BRANCH
  {
    id: 'def-tier1-hp',
    name: 'Fortitude',
    description: 'Increase maximum HP by 10',
    branch: 'defensive',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'maxHp',
      value: 10
    }
  },
  {
    id: 'def-tier1-armor',
    name: 'Armored Shell',
    description: 'Start each combat with 3 Armor',
    branch: 'defensive',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'armor',
      value: 3
    }
  },
  {
    id: 'def-tier2-block',
    name: 'Enhanced Defense',
    description: 'Defense cards block +3 additional damage',
    branch: 'defensive',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'def-tier1-armor',
    effect: {
      type: 'cardBlock',
      value: 3
    }
  },
  {
    id: 'def-tier2-hp2',
    name: 'Vitality',
    description: 'Increase maximum HP by 20',
    branch: 'defensive',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'def-tier1-hp',
    effect: {
      type: 'maxHp',
      value: 20
    }
  },
  {
    id: 'def-tier3-tank',
    name: 'Unbreakable',
    description: 'Increase maximum HP by 30 and start with 5 Armor',
    branch: 'defensive',
    tier: 3,
    cost: 3,
    unlocked: false,
    prerequisite: 'def-tier2-hp2',
    effect: {
      type: 'maxHp',
      value: 30
    }
  },

  // UTILITY BRANCH
  {
    id: 'util-tier1-draw',
    name: 'Card Knowledge',
    description: 'Draw 1 additional card at start of turn',
    branch: 'utility',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'drawSize',
      value: 1
    }
  },
  {
    id: 'util-tier1-energy',
    name: 'Efficiency',
    description: 'Increase maximum Energy by 1',
    branch: 'utility',
    tier: 1,
    cost: 1,
    unlocked: false,
    effect: {
      type: 'maxEnergy',
      value: 1
    }
  },
  {
    id: 'util-tier2-draw2',
    name: 'Speed Reader',
    description: 'Draw 1 more additional card at start of turn',
    branch: 'utility',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'util-tier1-draw',
    effect: {
      type: 'drawSize',
      value: 1
    }
  },
  {
    id: 'util-tier2-versatile',
    name: 'Versatile Mind',
    description: 'Increase maximum Energy by 1',
    branch: 'utility',
    tier: 2,
    cost: 2,
    unlocked: false,
    prerequisite: 'util-tier1-energy',
    effect: {
      type: 'maxEnergy',
      value: 1
    }
  },
  {
    id: 'util-tier3-master',
    name: 'Master Learner',
    description: 'Draw 2 additional cards and gain +1 Energy',
    branch: 'utility',
    tier: 3,
    cost: 3,
    unlocked: false,
    prerequisite: 'util-tier2-draw2',
    effect: {
      type: 'drawSize',
      value: 2
    }
  }
];

export function calculateSkillPoints(level: number, prestigeLevel: number): number {
  // Base points from leveling
  const levelPoints = Math.floor(level / 5);
  
  // Bonus points from prestige
  const prestigePoints = prestigeLevel * 3;
  
  return levelPoints + prestigePoints;
}

export function calculateNextLevelXP(currentLevel: number): number {
  // XP required increases by 100 each level
  return 100 + (currentLevel * 100);
}
