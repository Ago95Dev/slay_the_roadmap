import { PlayerProgress, PlayerStats } from '../types';
import { initialSkillTree } from '../data/skillTree';

export function createDefaultPlayerProgress(): PlayerProgress {
  return {
    completedTopics: [],
    currentTopic: null,
    inventory: [],
    activeDeck: [],
    chapterProgress: {},
    achievements: [],
    dungeonRun: null,
    stats: {
      totalStudyTime: 0,
      currentStreak: 0,
      longestStreak: 0,
      topicStats: []
    },
    playerStats: {
      maxHp: 50,
      currentHp: 50,
      maxEnergy: 3,
      currentEnergy: 3,
      armor: 0,
      drawSize: 5,
      level: 1,
      experience: 0
    },
    skillTree: [...initialSkillTree],
    relics: [],
    ascensionLevel: 0,
    prestigeLevel: 0,
    runHistory: []
  };
}

export function migrateProgressData(saved: any): PlayerProgress {
  const defaults = createDefaultPlayerProgress();
  
  return {
    ...defaults,
    ...saved,
    playerStats: saved.playerStats || defaults.playerStats,
    skillTree: saved.skillTree || defaults.skillTree,
    relics: saved.relics || defaults.relics,
    ascensionLevel: saved.ascensionLevel || defaults.ascensionLevel,
    prestigeLevel: saved.prestigeLevel || defaults.prestigeLevel,
    runHistory: saved.runHistory || defaults.runHistory,
    stats: {
      ...defaults.stats,
      ...saved.stats
    }
  };
}

export function awardExperience(
  currentStats: PlayerStats,
  xpAmount: number
): { newStats: PlayerStats; leveledUp: boolean; skillPointsGained: number } {
  let newStats = { ...currentStats };
  let leveledUp = false;
  let skillPointsGained = 0;
  
  newStats.experience += xpAmount;
  
  // Check for level up
  const xpNeeded = 100 + (newStats.level * 100);
  while (newStats.experience >= xpNeeded) {
    newStats.experience -= xpNeeded;
    newStats.level += 1;
    leveledUp = true;
    
    // Award skill point every 5 levels
    if (newStats.level % 5 === 0) {
      skillPointsGained += 1;
    }
    
    // Increase stats on level up
    newStats.maxHp += 5;
    newStats.currentHp = newStats.maxHp;
  }
  
  return { newStats, leveledUp, skillPointsGained };
}
