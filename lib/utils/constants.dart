class GameConstants {
  // Quiz Constants
  static const int quizPassingScore = 80;
  static const int quizTimeLimit = 300; // seconds
  
  // Player Stats
  static const int baseMaxHp = 50;
  static const int baseMaxEnergy = 3;
  static const int baseDrawSize = 5;
  static const int baseArmor = 0;
  
  // Experience & Leveling
  static const int baseXpPerLevel = 100;
  static const int xpPerLevel = 100; // Increases by 100 each level
  static const int skillPointsPerLevel = 5;
  
  // Rewards (H3: vittoria boss → 100 XP, allineata al bonus Hub di
  // `boss_defeated`; soglie livello 0/100/500 invariate).
  static const int xpPerTopicComplete = 50;
  static const int xpPerQuizPerfect = 100;
  static const int xpPerRunVictory = 200;
  static const int xpPerBossDefeated = 100;
  
  // Dungeon Run
  static const int maxDeckSize = 30;
  static const int minDeckSize = 10;
  static const int startingDeckSize = 10;
  
  // Boss Thresholds
  static const int bossThreshold1 = 75;
  static const int bossThreshold2 = 50;
  static const int bossThreshold3 = 25;
  
  // Ascension
  static const int maxAscensionLevel = 20;
  static const double ascensionHpMultiplier = 0.15;
  static const double ascensionDamageMultiplier = 0.1;
  static const double ascensionPlayerHpReduction = 0.05;
  
  // Card Costs
  static const int minManaCost = 0;
  static const int maxManaCost = 5;
  
  // Rarity Chances (percentage)
  static const Map<String, int> rarityChances = {
    'common': 60,
    'rare': 25,
    'epic': 12,
    'legendary': 3,
  };
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;
  
  // Storage Keys
  static const String progressKey = 'dart_quest_progress';
  static const String settingsKey = 'dart_quest_settings';
  
  // Chapters
  static const Map<String, Map<String, dynamic>> chapters = {
    'chapter-1': {
      'title': 'Dart Basics',
      'description': 'Learn the fundamentals of Dart programming',
      'topics': 3,
      'boss': 'Syntax Dragon',
    },
    'chapter-2': {
      'title': 'Control Flow & Functions',
      'description': 'Master control structures and functions',
      'topics': 4,
      'boss': 'Logic Leviathan',
    },
    'chapter-3': {
      'title': 'OOP & Advanced',
      'description': 'Dive into object-oriented programming',
      'topics': 3,
      'boss': 'Polymorphic Phoenix',
    },
  };
  
  // Error Messages
  static const String errorLoadProgress = 'Failed to load progress';
  static const String errorSaveProgress = 'Failed to save progress';
  static const String errorInvalidDeck = 'Invalid deck configuration';
  static const String errorNotEnoughEnergy = 'Not enough energy';
  
  // Success Messages
  static const String successTopicComplete = 'Topic completed!';
  static const String successQuizPassed = 'Quiz passed!';
  static const String successLevelUp = 'Level up!';
  static const String successRunComplete = 'Dungeon run completed!';
}

class CardKeywordDescriptions {
  static const Map<String, String> descriptions = {
    'exhaust': 'Remove this card from your deck after playing it',
    'ethereal': 'This card is discarded at the end of your turn',
    'retain': 'Keep this card in your hand at the end of your turn',
    'combo': 'Bonus effect if you\'ve played another card this turn',
    'overload': 'Reduces your energy next turn',
    'evolve': 'This card transforms after meeting certain conditions',
    'discover': 'Choose 1 card from 3 random options',
  };
  
  static String getDescription(String keyword) {
    return descriptions[keyword.toLowerCase()] ?? 'Unknown keyword';
  }
}

class SkillBranchDescriptions {
  static const Map<String, String> descriptions = {
    'offensive': 'Increase your damage output and energy generation',
    'defensive': 'Boost your survivability with more HP and armor',
    'utility': 'Enhance your card draw and deck manipulation',
  };
  
  static String getDescription(String branch) {
    return descriptions[branch.toLowerCase()] ?? 'Unknown branch';
  }
}
