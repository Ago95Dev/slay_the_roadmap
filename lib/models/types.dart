// Enums
enum CardRarity { common, rare, epic, legendary }

enum CardKeyword { exhaust, ethereal, retain, combo, overload, evolve, discover }

enum CardType { attack, defense, utility, knowledge }

enum StatusEffect { poison, pierce, critical, bleed, burn, freeze, vulnerable, weak, strength }

enum DungeonRoomType {
  topicQuiz,
  combat,
  treasure,
  choice,
  rest,
  merchant,
  elite,
  boss,
  secret
}

enum SkillBranch { offensive, defensive, utility }

enum EventTheme { mystery, coding, bugHunt, refactor }

enum TopicStatus { locked, inProgress, completed, skipped }

enum TopicType { core, elective }

// Card Effect with Status Effects
class CardEffect {
  final String type; // damage, block, heal, draw, energy, scry, vulnerable, weak
  final int value;
  final String? target; // self, enemy
  final StatusEffect? statusEffect;
  final int? statusStacks; // For stackable effects like poison, bleed

  CardEffect({
    required this.type,
    required this.value,
    this.target,
    this.statusEffect,
    this.statusStacks,
  });

  factory CardEffect.fromJson(Map<String, dynamic> json) => CardEffect(
        type: json['type'],
        value: json['value'],
        target: json['target'],
        statusEffect: json['statusEffect'] != null 
            ? StatusEffect.values[json['statusEffect']]
            : null,
        statusStacks: json['statusStacks'],
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'target': target,
        'statusEffect': statusEffect?.index,
        'statusStacks': statusStacks,
      };
}

// Card/Reward Model
class CardModel {
  final String id;
  final String name;
  final CardType type;
  final String description;
  final int effect;
  final int manaCost;
  final CardRarity rarity;
  final String icon;
  final String? imageAsset; // New field for custom card art
  final List<String>? synergies;
  final List<CardKeyword>? keywords;
  final List<CardEffect>? effects;
  final String? evolvesInto;
  final String? evolveCondition;
  final List<CardEffect>? comboEffect;
  final int? overloadAmount;
  final String? topicId; // For knowledge cards - associated topic
  final String? questionTopicFilter; // For knowledge cards - force boss questions on this topic
  final String? flavourText; // Optional flavour text for lore/atmosphere

  CardModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.effect,
    required this.manaCost,
    required this.rarity,
    required this.icon,
    this.imageAsset,
    this.synergies,
    this.keywords,
    this.effects,
    this.evolvesInto,
    this.evolveCondition,
    this.comboEffect,
    this.overloadAmount,
    this.topicId,
    this.questionTopicFilter,
    this.flavourText,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'],
        name: json['name'],
        type: CardType.values[json['type']],
        description: json['description'],
        effect: json['effect'],
        manaCost: json['manaCost'],
        rarity: CardRarity.values[json['rarity']],
        icon: json['icon'],
        imageAsset: json['imageAsset'],
        synergies: json['synergies']?.cast<String>(),
        keywords: json['keywords']?.map<CardKeyword>((k) => CardKeyword.values[k]).toList(),
        effects: json['effects']?.map<CardEffect>((e) => CardEffect.fromJson(e)).toList(),
        evolvesInto: json['evolvesInto'],
        evolveCondition: json['evolveCondition'],
        comboEffect: json['comboEffect']?.map<CardEffect>((e) => CardEffect.fromJson(e)).toList(),
        overloadAmount: json['overloadAmount'],
        topicId: json['topicId'],
        questionTopicFilter: json['questionTopicFilter'],
        flavourText: json['flavourText'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'description': description,
        'effect': effect,
        'manaCost': manaCost,
        'rarity': rarity.index,
        'icon': icon,
        'imageAsset': imageAsset,
        'synergies': synergies,
        'keywords': keywords?.map((k) => k.index).toList(),
        'effects': effects?.map((e) => e.toJson()).toList(),
        'evolvesInto': evolvesInto,
        'evolveCondition': evolveCondition,
        'comboEffect': comboEffect?.map((e) => e.toJson()).toList(),
        'overloadAmount': overloadAmount,
        'topicId': topicId,
        'questionTopicFilter': questionTopicFilter,
        'flavourText': flavourText,
      };
}

// Card Overrides (Upgrades)
class CardOverrides {
  final int damageBonus;
  final int blockBonus;
  final CardRarity? rarityOverride;

  CardOverrides({
    this.damageBonus = 0,
    this.blockBonus = 0,
    this.rarityOverride,
  });

  factory CardOverrides.fromJson(Map<String, dynamic> json) => CardOverrides(
        damageBonus: json['damageBonus'] ?? 0,
        blockBonus: json['blockBonus'] ?? 0,
        rarityOverride: json['rarityOverride'] != null
            ? CardRarity.values[json['rarityOverride']]
            : null,
      );

  Map<String, dynamic> toJson() => {
        'damageBonus': damageBonus,
        'blockBonus': blockBonus,
        'rarityOverride': rarityOverride?.index,
      };
}

// Relic Model
class Relic {
  final String id;
  final String name;
  final String description;
  final CardRarity rarity;
  final String effect;
  final String icon;

  Relic({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.effect,
    required this.icon,
  });

  factory Relic.fromJson(Map<String, dynamic> json) => Relic(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        rarity: CardRarity.values[json['rarity']],
        effect: json['effect'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rarity': rarity.index,
        'effect': effect,
        'icon': icon,
      };
}

// Player Stats
class PlayerStats {
  int maxHp;
  int currentHp;
  int maxEnergy;
  int currentEnergy;
  int armor;
  int drawSize;
  int level;
  int experience;
  String playerName;
  String playerClass;

  PlayerStats({
    this.maxHp = 50,
    this.currentHp = 50,
    this.maxEnergy = 3,
    this.currentEnergy = 3,
    this.armor = 0,
    this.drawSize = 5,
    this.level = 1,
    this.experience = 0,
    this.playerName = 'Traveler',
    this.playerClass = 'Novice',
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        maxHp: json['maxHp'] ?? 50,
        currentHp: json['currentHp'] ?? 50,
        maxEnergy: json['maxEnergy'] ?? 3,
        currentEnergy: json['currentEnergy'] ?? 3,
        armor: json['armor'] ?? 0,
        drawSize: json['drawSize'] ?? 5,
        level: json['level'] ?? 1,
        experience: json['experience'] ?? 0,
        playerName: json['playerName'] ?? 'Traveler',
        playerClass: json['playerClass'] ?? 'Novice',
      );

  Map<String, dynamic> toJson() => {
        'maxHp': maxHp,
        'currentHp': currentHp,
        'maxEnergy': maxEnergy,
        'currentEnergy': currentEnergy,
        'armor': armor,
        'drawSize': drawSize,
        'level': level,
        'experience': experience,
        'playerName': playerName,
        'playerClass': playerClass,
      };

  PlayerStats copyWith({
    int? maxHp,
    int? currentHp,
    int? maxEnergy,
    int? currentEnergy,
    int? armor,
    int? drawSize,
    int? level,
    int? experience,
    String? playerName,
    String? playerClass,
  }) {
    return PlayerStats(
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      currentEnergy: currentEnergy ?? this.currentEnergy,
      armor: armor ?? this.armor,
      drawSize: drawSize ?? this.drawSize,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      playerName: playerName ?? this.playerName,
      playerClass: playerClass ?? this.playerClass,
    );
  }
}

// Skill Node
class SkillNode {
  final String id;
  final String name;
  final String description;
  final SkillBranch branch;
  final int tier;
  final int cost;
  bool unlocked;
  final String? prerequisite;
  final SkillEffect effect;
  final String? requiredClass;
  final double x;
  final double y;

  SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.branch,
    required this.tier,
    required this.cost,
    this.unlocked = false,
    this.prerequisite,
    required this.effect,
    this.requiredClass,
    this.x = 0.0,
    this.y = 0.0,
  });

  factory SkillNode.fromJson(Map<String, dynamic> json) => SkillNode(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        branch: SkillBranch.values[json['branch']],
        tier: json['tier'],
        cost: json['cost'],
        unlocked: json['unlocked'] ?? false,
        prerequisite: json['prerequisite'],
        effect: SkillEffect.fromJson(json['effect']),
        requiredClass: json['requiredClass'],
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'branch': branch.index,
        'tier': tier,
        'cost': cost,
        'unlocked': unlocked,
        'prerequisite': prerequisite,
        'effect': effect.toJson(),
        'requiredClass': requiredClass,
        'x': x,
        'y': y,
      };
}

class SkillEffect {
  final String type; // maxHp, maxEnergy, drawSize, armor, cardDamage, cardBlock
  final int value;

  SkillEffect({required this.type, required this.value});

  factory SkillEffect.fromJson(Map<String, dynamic> json) =>
      SkillEffect(type: json['type'], value: json['value']);

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

// Dungeon Room
class DungeonRoom {
  final String id;
  final DungeonRoomType type;
  final String? topicId;
  final String? eventId;
  final int x;
  final int y;
  final List<String> connections;
  bool cleared;
  final bool optional;

  DungeonRoom({
    required this.id,
    required this.type,
    this.topicId,
    this.eventId,
    required this.x,
    required this.y,
    required this.connections,
    this.cleared = false,
    this.optional = false,
  });

  factory DungeonRoom.fromJson(Map<String, dynamic> json) => DungeonRoom(
        id: json['id'],
        type: DungeonRoomType.values[json['type']],
        topicId: json['topicId'],
        eventId: json['eventId'],
        x: json['x'],
        y: json['y'],
        connections: List<String>.from(json['connections']),
        cleared: json['cleared'] ?? false,
        optional: json['optional'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'topicId': topicId,
        'eventId': eventId,
        'x': x,
        'y': y,
        'connections': connections,
        'cleared': cleared,
        'optional': optional,
      };
}

// Run History
class RunHistory {
  final String id;
  final DateTime completedAt;
  final int floor;
  final int ascensionLevel;
  final bool victory;
  final int finalScore;
  final int cardsCollected;
  final int elitesDefeated;
  final int bossesDefeated;
  final int duration;
  final String playerClass;

  RunHistory({
    required this.id,
    required this.completedAt,
    required this.floor,
    required this.ascensionLevel,
    required this.victory,
    required this.finalScore,
    required this.cardsCollected,
    required this.elitesDefeated,
    required this.bossesDefeated,
    required this.duration,
    this.playerClass = 'Novice',
  });

  factory RunHistory.fromJson(Map<String, dynamic> json) => RunHistory(
        id: json['id'],
        completedAt: DateTime.parse(json['completedAt']),
        floor: json['floor'],
        ascensionLevel: json['ascensionLevel'],
        victory: json['victory'],
        finalScore: json['finalScore'],
        cardsCollected: json['cardsCollected'],
        elitesDefeated: json['elitesDefeated'],
        bossesDefeated: json['bossesDefeated'],
        duration: json['duration'],
        playerClass: json['playerClass'] ?? 'Novice',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toIso8601String(),
        'floor': floor,
        'ascensionLevel': ascensionLevel,
        'victory': victory,
        'finalScore': finalScore,
        'cardsCollected': cardsCollected,
        'elitesDefeated': elitesDefeated,
        'bossesDefeated': bossesDefeated,
        'duration': duration,
        'playerClass': playerClass,
      };
}

// Dungeon Run
class DungeonRun {
  final String id;
  String? currentRoomId;
  final List<DungeonRoom> rooms;
  PlayerStats playerStats;
  int reputation;
  final int floor;
  final List<String> relics;
  final List<String> deck;
  final List<String> drawPile;
  final List<String> hand;
  final List<String> discardPile;
  final List<String> exhaustPile;
  bool active;
  DateTime? completedAt;
  final int ascensionLevel;

  DungeonRun({
    required this.id,
    this.currentRoomId,
    required this.rooms,
    required this.playerStats,
    this.reputation = 0,
    required this.floor,
    required this.relics,
    required this.deck,
    required this.drawPile,
    required this.hand,
    required this.discardPile,
    required this.exhaustPile,
    this.active = true,
    this.completedAt,
    this.ascensionLevel = 0,
  });

  factory DungeonRun.fromJson(Map<String, dynamic> json) => DungeonRun(
        id: json['id'],
        currentRoomId: json['currentRoomId'],
        rooms: (json['rooms'] as List).map((r) => DungeonRoom.fromJson(r)).toList(),
        playerStats: PlayerStats.fromJson(json['playerStats']),
        reputation: json['reputation'] ?? 0,
        floor: json['floor'],
        relics: List<String>.from(json['relics']),
        deck: List<String>.from(json['deck']),
        drawPile: List<String>.from(json['drawPile']),
        hand: List<String>.from(json['hand']),
        discardPile: List<String>.from(json['discardPile']),
        exhaustPile: List<String>.from(json['exhaustPile']),
        active: json['active'] ?? true,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        ascensionLevel: json['ascensionLevel'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentRoomId': currentRoomId,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'playerStats': playerStats.toJson(),
        'reputation': reputation,
        'floor': floor,
        'relics': relics,
        'deck': deck,
        'drawPile': drawPile,
        'hand': hand,
        'discardPile': discardPile,
        'exhaustPile': exhaustPile,
        'active': active,
        'completedAt': completedAt?.toIso8601String(),
        'ascensionLevel': ascensionLevel,
      };
}

// Topic
class Topic {
  final String id;
  final String title;
  final String description;
  final String chapterId;
  final TopicType type;
  final String difficulty;
  final List<String> resources;
  final int order;
  final List<Topic> subtopics;
  TopicStatus status;
  bool isExpanded;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.chapterId,
    required this.type,
    required this.difficulty,
    required this.resources,
    required this.order,
    this.subtopics = const [],
    this.status = TopicStatus.locked,
    this.isExpanded = false,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        chapterId: json['chapterId'],
        type: json['type'] != null 
            ? TopicType.values.firstWhere(
                (e) => e.toString() == 'TopicType.${json['type']}',
                orElse: () => TopicType.core,
              )
            : TopicType.core,
        difficulty: json['difficulty'],
        resources: List<String>.from(json['resources'] ?? []),
        order: json['order'],
        subtopics: (json['subtopics'] as List? ?? [])
            .map((t) => Topic.fromJson(t))
            .toList(),
        status: json['status'] != null
            ? TopicStatus.values[json['status']]
            : TopicStatus.locked,
        isExpanded: json['isExpanded'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'chapterId': chapterId,
        'type': type.toString().split('.').last,
        'difficulty': difficulty,
        'resources': resources,
        'order': order,
        'subtopics': subtopics.map((t) => t.toJson()).toList(),
        'status': status.index,
        'isExpanded': isExpanded,
      };
}

// Quiz Question
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'],
        options: List<String>.from(json['options']),
        correctAnswer: json['correctAnswer'],
        explanation: json['explanation'],
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
      };
}

// Quiz
class Quiz {
  final String topicId;
  final List<QuizQuestion> questions;
  final int passingScore;
  final int timeLimit;

  Quiz({
    required this.topicId,
    required this.questions,
    this.passingScore = 80,
    this.timeLimit = 300,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        topicId: json['topicId'],
        questions: (json['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList(),
        passingScore: json['passingScore'] ?? 80,
        timeLimit: json['timeLimit'] ?? 300,
      );

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'questions': questions.map((q) => q.toJson()).toList(),
        'passingScore': passingScore,
        'timeLimit': timeLimit,
      };
}

// Roadmap Node Types
enum RoadmapNodeType { topic, boss, treasure, event, rest, elite, dungeonStart }

// Roadmap Reward
class RoadmapReward {
  final String type; // card, relic, gold, experience, health
  final String? id; // ID of card or relic
  final int? amount; // For gold, experience, health
  final CardRarity? rarity; // For random card rewards

  RoadmapReward({
    required this.type,
    this.id,
    this.amount,
    this.rarity,
  });

  factory RoadmapReward.fromJson(Map<String, dynamic> json) => RoadmapReward(
        type: json['type'],
        id: json['id'],
        amount: json['amount'],
        rarity: json['rarity'] != null ? CardRarity.values[json['rarity']] : null,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'amount': amount,
        'rarity': rarity?.index,
      };
}

// Roadmap Node
class RoadmapNode {
  final String id;
  final RoadmapNodeType type;
  final String? topicId;
  final String? bossId;
  final String title;
  final String description;
  final int tier; // Vertical position in roadmap
  final int lane; // Horizontal position (0-2 for 3 lanes)
  final List<String> connections; // IDs of nodes this connects to
  bool unlocked;
  bool completed;
  final List<RoadmapReward> rewards;
  final String? chapterId;

  RoadmapNode({
    required this.id,
    required this.type,
    this.topicId,
    this.bossId,
    required this.title,
    required this.description,
    required this.tier,
    required this.lane,
    required this.connections,
    this.unlocked = false,
    this.completed = false,
    required this.rewards,
    this.chapterId,
  });

  factory RoadmapNode.fromJson(Map<String, dynamic> json) => RoadmapNode(
        id: json['id'],
        type: RoadmapNodeType.values[json['type']],
        topicId: json['topicId'],
        bossId: json['bossId'],
        title: json['title'],
        description: json['description'],
        tier: json['tier'],
        lane: json['lane'],
        connections: List<String>.from(json['connections']),
        unlocked: json['unlocked'] ?? false,
        completed: json['completed'] ?? false,
        rewards: (json['rewards'] as List)
            .map((r) => RoadmapReward.fromJson(r))
            .toList(),
        chapterId: json['chapterId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'topicId': topicId,
        'bossId': bossId,
        'title': title,
        'description': description,
        'tier': tier,
        'lane': lane,
        'connections': connections,
        'unlocked': unlocked,
        'completed': completed,
        'rewards': rewards.map((r) => r.toJson()).toList(),
        'chapterId': chapterId,
      };
}

// Boss Model
class Boss {
  final String id;
  final String name;
  final String description;
  final int maxHp;
  int currentHp;
  final List<BossAbility> abilities;
  final Map<int, String> thresholdPowers; // HP threshold -> power description
  final String icon;
  final int tier; // Which tier/chapter this boss appears
  final String? imageAsset;
  final String? backgroundImage;
  final List<String>? openingDialogue;

  Boss({
    required this.id,
    required this.name,
    required this.description,
    required this.maxHp,
    required this.currentHp,
    required this.abilities,
    required this.thresholdPowers,
    required this.icon,
    required this.tier,
    this.imageAsset,
    this.backgroundImage,
    this.openingDialogue,
  });

  factory Boss.fromJson(Map<String, dynamic> json) => Boss(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        maxHp: json['maxHp'],
        currentHp: json['currentHp'],
        abilities: (json['abilities'] as List)
            .map((a) => BossAbility.fromJson(a))
            .toList(),
        thresholdPowers: Map<int, String>.from(json['thresholdPowers']),
        icon: json['icon'],
        tier: json['tier'],
        imageAsset: json['imageAsset'],
        backgroundImage: json['backgroundImage'],
        openingDialogue: json['openingDialogue']?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'abilities': abilities.map((a) => a.toJson()).toList(),
        'thresholdPowers': thresholdPowers,
        'icon': icon,
        'tier': tier,
        'imageAsset': imageAsset,
        'backgroundImage': backgroundImage,
        'openingDialogue': openingDialogue,
      };
}

// Boss Ability
class BossAbility {
  final String name;
  final String description;
  final int damage;
  final List<CardEffect>? effects;
  final int cooldown;
  int currentCooldown;

  BossAbility({
    required this.name,
    required this.description,
    required this.damage,
    this.effects,
    required this.cooldown,
    this.currentCooldown = 0,
  });

  factory BossAbility.fromJson(Map<String, dynamic> json) => BossAbility(
        name: json['name'],
        description: json['description'],
        damage: json['damage'],
        effects: json['effects'] != null
            ? (json['effects'] as List)
                .map((e) => CardEffect.fromJson(e))
                .toList()
            : null,
        cooldown: json['cooldown'],
        currentCooldown: json['currentCooldown'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'damage': damage,
        'effects': effects?.map((e) => e.toJson()).toList(),
        'cooldown': cooldown,
        'currentCooldown': currentCooldown,
      };
}
