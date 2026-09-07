import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/types.dart';
import '../data/skill_tree_data.dart';
import '../data/roadmap_data.dart' as data;
import '../data/cards_data.dart' as cards_data;
import '../services/storage_service.dart';
import '../services/dungeon_generator.dart';
import '../data/topics_and_quizzes.dart';

class GameProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  // Player State
  List<String> _completedTopics = [];
  List<String> _skippedTopics = []; // Track skipped topics separately
  String? _currentTopic;
  List<String> _inventory = [];
  List<String> _activeDeck = [];
  Map<String, Map<String, dynamic>> _chapterProgress = {};
  List<String> _achievements = [];
  DungeonRun? _dungeonRun;
  PlayerStats _playerStats = PlayerStats();
  List<SkillNode> _skillTree = [];
  List<String> _relics = [];
  int _ascensionLevel = 0;
  int _prestigeLevel = 0;
  // Track viewed resources for rewards (format: "topicId_resourceIndex")
  Set<String> _viewedResources = {};
  List<RunHistory> _runHistory = [];
  List<RoadmapNode> _roadmapNodes = [];
  int _gold = 0;
  
  // Path selection
  String? _selectedPath;
  bool _hasStartedJourney = false;

  // Getters
  List<String> get completedTopics => _completedTopics;
  List<String> get skippedTopics => _skippedTopics;
  String? get currentTopic => _currentTopic;
  List<String> get inventory => _inventory;
  List<String> get activeDeck => _activeDeck;
  Map<String, Map<String, dynamic>> get chapterProgress => _chapterProgress;
  DungeonRun? get dungeonRun => _dungeonRun;
  PlayerStats get playerStats => _playerStats;
  List<SkillNode> get skillTree => _skillTree;
  List<String> get relics => _relics;
  int get ascensionLevel => _ascensionLevel;
  int get prestigeLevel => _prestigeLevel;
  List<RunHistory> get runHistory => _runHistory;
  List<RoadmapNode> get roadmapNodes => _roadmapNodes;
  int get gold => _gold;
  String? get selectedPath => _selectedPath;
  bool get hasStartedJourney => _hasStartedJourney;

  int get availableSkillPoints {
    final used = _skillTree.where((s) => s.unlocked).fold(0, (sum, s) => sum + s.cost);
    final total = calculateSkillPoints(_playerStats.level, _prestigeLevel);
    return total - used;
  }

  GameProvider() {
    _initializeRoadmap();
    _loadProgress();
  }

  void _initializeRoadmap() {
    _roadmapNodes = List.from(data.roadmapNodes);
  }



  Future<void> _loadProgress() async {
    final progress = await _storage.loadProgress();
    if (progress != null) {
      _completedTopics = List<String>.from(progress['completedTopics'] ?? []);
      _skippedTopics = List<String>.from(progress['skippedTopics'] ?? []);
      _currentTopic = progress['currentTopic'];
      _inventory = List<String>.from(progress['inventory'] ?? []);
      _activeDeck = List<String>.from(progress['activeDeck'] ?? []);
      _chapterProgress = Map<String, Map<String, dynamic>>.from(progress['chapterProgress'] ?? {});
      _playerStats = PlayerStats.fromJson(progress['playerStats'] ?? {});
      // Merge saved skills with initial skill tree to ensure new skills appear
      final savedSkills = (progress['skillTree'] as List? ?? [])
          .map((s) => SkillNode.fromJson(s is Map ? s : s.toJson()))
          .toList();
      
      final Map<String, SkillNode> savedSkillMap = {
        for (var s in savedSkills) s.id: s
      };

      _skillTree = initialSkillTree.map((initialSkill) {
        final saved = savedSkillMap[initialSkill.id];
        if (saved != null) {
          // Keep unlocked status from save, but update static data (desc, cost, etc) from initial
          initialSkill.unlocked = saved.unlocked;
          return initialSkill;
        }
        return initialSkill;
      }).toList();
      _relics = List<String>.from(progress['relics'] ?? []);
      _ascensionLevel = progress['ascensionLevel'] ?? 0;
      _prestigeLevel = progress['prestigeLevel'] ?? 0;
      _runHistory = (progress['runHistory'] as List? ?? [])
          .map((r) => RunHistory.fromJson(r))
          .toList();
      _gold = progress['gold'] ?? 0;
      _viewedResources = Set<String>.from(progress['viewedResources'] ?? []);
      _selectedPath = progress['selectedPath'];
      _hasStartedJourney = progress['hasStartedJourney'] ?? false;
      
      if (progress['cardUpgrades'] != null) {
        _cardUpgrades = (progress['cardUpgrades'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, CardOverrides.fromJson(value)),
        );
      }

      if (progress['dungeonRun'] != null) {
        _dungeonRun = DungeonRun.fromJson(progress['dungeonRun']);
      }
      if (progress['roadmapNodes'] != null) {
        _roadmapNodes = (progress['roadmapNodes'] as List)
            .map((n) => RoadmapNode.fromJson(n))
            .toList();
      }
    } else {
      _skillTree = List.from(initialSkillTree);
    }
    
    // Always ensure start node is completed and first topics are unlocked
    // This runs AFTER loading progress to guarantee initial accessibility
    final startNode = _roadmapNodes.firstWhere((node) => node.id == 'start');
    startNode.unlocked = true;
    startNode.completed = true;
    
    // Unlock the nodes connected to start (first chapter topics)
    for (final connectionId in startNode.connections) {
      final connectedNode = _roadmapNodes.firstWhere((n) => n.id == connectionId);
      connectedNode.unlocked = true;
    }
    
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final progress = {
      'completedTopics': _completedTopics,
      'skippedTopics': _skippedTopics,
      'currentTopic': _currentTopic,
      'inventory': _inventory,
      'activeDeck': _activeDeck,
      'chapterProgress': _chapterProgress,
      'playerStats': _playerStats.toJson(),
      'skillTree': _skillTree.map((s) => s.toJson()).toList(),
      'relics': _relics,
      'ascensionLevel': _ascensionLevel,
      'prestigeLevel': _prestigeLevel,
      'runHistory': _runHistory.map((r) => r.toJson()).toList(),
      'dungeonRun': _dungeonRun?.toJson(),
      'roadmapNodes': _roadmapNodes.map((n) => n.toJson()).toList(),
      'gold': _gold,
      'viewedResources': _viewedResources.toList(),
      'selectedPath': _selectedPath,
      'hasStartedJourney': _hasStartedJourney,
      'cardUpgrades': _cardUpgrades.map((k, v) => MapEntry(k, v.toJson())),
    };
    await _storage.saveProgress(progress);
  }

  // Complete a topic
  void completeTopic(String topicId) {
    if (!_completedTopics.contains(topicId)) {
      _completedTopics.add(topicId);
      _skippedTopics.remove(topicId); // Ensure it's not skipped anymore
      _awardExperience(50);
      _saveProgress();
      notifyListeners();
    }
  }

  // Update topic status (Done, In Progress, Skip)
  void updateTopicStatus(String topicId, TopicStatus status) {
    if (status == TopicStatus.completed) {
      if (!_completedTopics.contains(topicId)) {
        _completedTopics.add(topicId);
        _skippedTopics.remove(topicId);
        _awardExperience(50);
        _unlockNextNodes(topicId);
      }
    } else if (status == TopicStatus.skipped) {
      if (!_skippedTopics.contains(topicId)) {
        _skippedTopics.add(topicId);
        _completedTopics.remove(topicId); // Cannot be both completed and skipped
        // Skipping also unlocks next nodes, but no XP
        _unlockNextNodes(topicId);
      }
    } else if (status == TopicStatus.inProgress) {
      _completedTopics.remove(topicId);
      _skippedTopics.remove(topicId);
      _currentTopic = topicId;
    }
    
    _saveProgress();
    notifyListeners();
  }

  void _unlockNextNodes(String topicId) {
    // Find and complete/unlock roadmap node
    final topicNode = _roadmapNodes.where((node) => 
      node.type == RoadmapNodeType.topic && node.topicId == topicId
    ).firstOrNull;
    
    if (topicNode != null) {
      completeRoadmapNode(topicNode.id);
    }
  }

  // Complete a topic quiz
  void completeTopicQuiz(String topicId, int score, bool passed) {
    if (!passed) {
      _saveProgress();
      notifyListeners();
      return;
    }

    // Mark topic as completed
    if (!_completedTopics.contains(topicId)) {
      _completedTopics.add(topicId);
      
      // Award experience based on score
      final experienceReward = 50 + (score * 10);
      _awardExperience(experienceReward);
      
      // Find and complete the corresponding roadmap node
      final topicNode = _roadmapNodes.where((node) => 
        node.type == RoadmapNodeType.topic && node.topicId == topicId
      ).firstOrNull;
      
      if (topicNode != null) {
        completeRoadmapNode(topicNode.id);
      }
      
      _saveProgress();
      notifyListeners();
    }
  }

  // Add card to inventory
  void addCardToInventory(String cardId) {
    // Generate a unique ID if it doesn't already have one
    final uniqueId = cardId.contains(':') ? cardId : '$cardId:${_uuid.v4()}';
    _inventory.add(uniqueId);
    _saveProgress();
    notifyListeners();
  }

  // Update active deck
  void updateActiveDeck(List<String> deck) {
    _activeDeck = deck;
    _saveProgress();
    notifyListeners();
  }

  // Check if resource has been viewed
  bool hasViewedResource(String topicId, int resourceIndex) {
    final key = '${topicId}_$resourceIndex';
    return _viewedResources.contains(key);
  }

  // Mark resource as viewed and award reward
  Map<String, dynamic> markResourceViewed(String topicId, int resourceIndex) {
    final key = '${topicId}_$resourceIndex';
    
    // Check if already viewed
    if (_viewedResources.contains(key)) {
      return {
        'alreadyViewed': true,
        'reward': null,
      };
    }
    
    // Mark as viewed
    _viewedResources.add(key);
    
    // Award rewards for viewing educational material
    const xpReward = 30;
    const goldReward = 10;
    
    _awardExperience(xpReward);
    _gold += goldReward;
    
    _saveProgress();
    notifyListeners();
    
    return {
      'alreadyViewed': false,
      'reward': {
        'xp': xpReward,
        'gold': goldReward,
      },
    };
  }

  // Select learning path
  void selectPath(String path) {
    _selectedPath = path;
    _saveProgress();
    notifyListeners();
  }

  // Select Class
  void selectClass(String className) {
    String name = 'Novice';
    List<String> starterDeckBaseIds = [];

    switch (className) {
      case 'warrior':
        name = 'Warrior';
        starterDeckBaseIds = ['strike', 'strike', 'strike', 'defend', 'defend', 'defend', 'bash'];
        break;
      case 'hunter':
        name = 'Hunter';
        starterDeckBaseIds = ['strike', 'strike', 'strike', 'defend', 'defend', 'defend', 'quick_shot'];
        break;
      case 'mage':
        name = 'Mage';
        starterDeckBaseIds = ['strike', 'strike', 'strike', 'defend', 'defend', 'defend', 'fireball'];
        break;
    }

    _playerStats.playerClass = name;
    
    // Generate unique IDs for the starter deck
    List<String> starterDeck = starterDeckBaseIds.map((id) => '$id:${_uuid.v4()}').toList();
    
    _activeDeck = List.from(starterDeck);
    
    // Also add to inventory so they are "owned"
    _inventory = List.from(starterDeck);
    
    _hasStartedJourney = true;
    _saveProgress();
    notifyListeners();
  }

  // Unlock skill
  void unlockSkill(String skillId) {
    final skill = _skillTree.firstWhere((s) => s.id == skillId);
    if (availableSkillPoints >= skill.cost) {
      skill.unlocked = true;
      
      // Apply skill effect
      switch (skill.effect.type) {
        case 'maxHp':
          _playerStats.maxHp += skill.effect.value;
          _playerStats.currentHp += skill.effect.value;
          break;
        case 'maxEnergy':
          _playerStats.maxEnergy += skill.effect.value;
          break;
        case 'drawSize':
          _playerStats.drawSize += skill.effect.value;
          break;
        case 'armor':
          _playerStats.armor += skill.effect.value;
          break;
      }
      
      _saveProgress();
      notifyListeners();
    }
  }

  // Start new dungeon run
  void startDungeonRun(List<Topic> topics, String chapterId) {
    final rooms = DungeonGenerator.generateDungeonRooms(topics, chapterId, true);
    
    _dungeonRun = DungeonRun(
      id: _uuid.v4(),
      currentRoomId: null,
      rooms: rooms,
      playerStats: PlayerStats(
        maxHp: _playerStats.maxHp,
        currentHp: _playerStats.maxHp,
        maxEnergy: _playerStats.maxEnergy,
        currentEnergy: _playerStats.maxEnergy,
        armor: _playerStats.armor,
        drawSize: _playerStats.drawSize,
        level: _playerStats.level,
        experience: _playerStats.experience,
      ),
      reputation: 0,
      floor: 1,
      relics: List.from(_relics),
      deck: List.from(_activeDeck),
      drawPile: [],
      hand: [],
      discardPile: [],
      exhaustPile: [],
      active: true,
      ascensionLevel: _ascensionLevel,
    );
    
    _saveProgress();
    notifyListeners();
  }

  // Complete dungeon room
  void completeRoom(String roomId, List<String> rewards) {
    if (_dungeonRun == null) return;
    
    final room = _dungeonRun!.rooms.firstWhere((r) => r.id == roomId);
    room.cleared = true;
    _dungeonRun!.currentRoomId = roomId;
    
    // Add rewards
    for (final reward in rewards) {
      addCardToInventory(reward);
    }
    
    _saveProgress();
    notifyListeners();
  }

  // Complete dungeon run
  void completeDungeonRun(bool victory) {
    if (_dungeonRun == null) return;
    
    final run = RunHistory(
      id: _uuid.v4(),
      completedAt: DateTime.now(),
      floor: _dungeonRun!.floor,
      ascensionLevel: _dungeonRun!.ascensionLevel,
      victory: victory,
      finalScore: DungeonGenerator.calculateRunScore(
        _dungeonRun!.floor,
        _dungeonRun!.deck.length,
        0,
        0,
        _dungeonRun!.playerStats.currentHp,
        _dungeonRun!.ascensionLevel,
      ),
      cardsCollected: _dungeonRun!.deck.length,
      elitesDefeated: 0,
      bossesDefeated: victory ? 1 : 0,
      duration: 0,
      playerClass: _playerStats.playerClass,
    );
    
    _runHistory.add(run);
    _dungeonRun = null;
    
    if (victory) {
      _awardExperience(200);
    }
    
    _saveProgress();
    notifyListeners();
  }

  // Award experience
  void _awardExperience(int amount) {
    _playerStats.experience += amount;
    
    final xpNeeded = calculateNextLevelXP(_playerStats.level);
    while (_playerStats.experience >= xpNeeded) {
      _playerStats.experience -= xpNeeded;
      _playerStats.level += 1;
      _playerStats.maxHp += 5;
      _playerStats.currentHp = _playerStats.maxHp;
    }
  }

  // Increase ascension level
  void increaseAscensionLevel() {
    _ascensionLevel += 1;
    _saveProgress();
    notifyListeners();
  }

  // Prestige
  void prestige() {
    _prestigeLevel += 1;
    _completedTopics.clear();
    _inventory.clear();
    _activeDeck.clear();
    _chapterProgress.clear();
    _playerStats = PlayerStats();
    _skillTree = List.from(initialSkillTree);
    _saveProgress();
    notifyListeners();
  }

  // Complete roadmap node
  void completeRoadmapNode(String nodeId) {
    final node = _roadmapNodes.firstWhere((n) => n.id == nodeId);
    if (!node.unlocked) return;

    node.completed = true;

    // Unlock connected nodes
    for (final connectionId in node.connections) {
      final connectedNode = _roadmapNodes.firstWhere((n) => n.id == connectionId);
      connectedNode.unlocked = true;
    }

    // Award rewards
    for (final reward in node.rewards) {
      _processReward(reward);
    }

    // If it's a topic node, mark topic as completed
    if (node.type == RoadmapNodeType.topic && node.topicId != null) {
      completeTopic(node.topicId!);
    }

    _saveProgress();
    notifyListeners();
  }

  void _processReward(RoadmapReward reward) {
    switch (reward.type) {
      case 'card':
        // Award a random card based on rarity
        // For now, just add placeholder
        addCardToInventory('card_${DateTime.now().millisecondsSinceEpoch}');
        break;
      case 'relic':
        if (reward.id != null) {
          _relics.add(reward.id!);
        }
        break;
      case 'gold':
        _gold += reward.amount ?? 0;
        break;
      case 'experience':
        _awardExperience(reward.amount ?? 0);
        break;
      case 'health':
        _playerStats.currentHp = (_playerStats.currentHp + (reward.amount ?? 0))
            .clamp(0, _playerStats.maxHp);
        break;
    }
  }

  // Add gold
  void addGold(int amount) {
    _gold += amount;
    _saveProgress();
    notifyListeners();
  }

  // Spend gold
  bool spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      _saveProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Card Upgrades ---
  Map<String, CardOverrides> _cardUpgrades = {};

  CardModel? getCardInstance(String uniqueId) {
    // 1. Get base card
    final baseId = uniqueId.split(':')[0];
    final baseCard = cards_data.getCardById(baseId);
    if (baseCard == null) return null;

    // 2. Check for upgrades
    final upgrades = _cardUpgrades[uniqueId];
    if (upgrades == null) return baseCard;

    // 3. Apply upgrades (create a new CardModel with modified stats)
    // Note: This assumes CardModel has a copyWith-like constructor or we create a new one manually.
    // Since CardModel doesn't have copyWith, we'll create a new instance.
    
    // Apply damage bonus to effects
    List<CardEffect>? newEffects = baseCard.effects;
    if (upgrades.damageBonus > 0 && baseCard.effects != null) {
      newEffects = baseCard.effects!.map((e) {
        if (e.type == 'damage') {
          return CardEffect(
            type: e.type,
            value: e.value + upgrades.damageBonus,
            target: e.target,
            statusEffect: e.statusEffect,
            statusStacks: e.statusStacks,
          );
        }
        return e;
      }).toList();
    }

    // Apply block bonus to effects
    if (upgrades.blockBonus > 0 && newEffects != null) {
      newEffects = newEffects.map((e) {
        if (e.type == 'block') {
          return CardEffect(
            type: e.type,
            value: e.value + upgrades.blockBonus,
            target: e.target,
            statusEffect: e.statusEffect,
            statusStacks: e.statusStacks,
          );
        }
        return e;
      }).toList();
    }

    // Update main effect value if it matches damage/block
    int newEffectValue = baseCard.effect;
    if (baseCard.type == CardType.attack && upgrades.damageBonus > 0) {
      newEffectValue += upgrades.damageBonus;
    } else if (baseCard.type == CardType.defense && upgrades.blockBonus > 0) {
      newEffectValue += upgrades.blockBonus;
    }

    // Update description to reflect changes (simple regex replacement or append)
    String newDescription = baseCard.description;
    if (upgrades.damageBonus > 0) {
      newDescription = newDescription.replaceAll(RegExp(r'\d+ damage'), '$newEffectValue damage');
    }
    if (upgrades.blockBonus > 0) {
      newDescription = newDescription.replaceAll(RegExp(r'\d+ Block'), '$newEffectValue Block');
    }

    return CardModel(
      id: baseCard.id, // Keep base ID for lookup, but this is a specific instance context
      name: baseCard.name + (upgrades.rarityOverride != null ? '+' : ''), // Visual indicator
      type: baseCard.type,
      description: newDescription,
      effect: newEffectValue,
      manaCost: baseCard.manaCost,
      rarity: upgrades.rarityOverride ?? baseCard.rarity,
      icon: baseCard.icon,
      synergies: baseCard.synergies,
      keywords: baseCard.keywords,
      effects: newEffects,
      evolvesInto: baseCard.evolvesInto,
      evolveCondition: baseCard.evolveCondition,
      comboEffect: baseCard.comboEffect,
      overloadAmount: baseCard.overloadAmount,
    );
  }

  void upgradeCard(String uniqueId, String type) {
    final currentUpgrades = _cardUpgrades[uniqueId] ?? CardOverrides();
    CardOverrides newUpgrades;

    switch (type) {
      case 'damage':
        newUpgrades = CardOverrides(
          damageBonus: currentUpgrades.damageBonus + 2,
          blockBonus: currentUpgrades.blockBonus,
          rarityOverride: currentUpgrades.rarityOverride,
        );
        break;
      case 'block':
        newUpgrades = CardOverrides(
          damageBonus: currentUpgrades.damageBonus,
          blockBonus: currentUpgrades.blockBonus + 2,
          rarityOverride: currentUpgrades.rarityOverride,
        );
        break;
      case 'rarity':
        // Promote to next rarity
        final card = getCardInstance(uniqueId);
        if (card != null) {
          final nextRarity = _getNextRarity(card.rarity);
          newUpgrades = CardOverrides(
            damageBonus: currentUpgrades.damageBonus,
            blockBonus: currentUpgrades.blockBonus,
            rarityOverride: nextRarity,
          );
        } else {
          return;
        }
        break;
      default:
        return;
    }

    _cardUpgrades[uniqueId] = newUpgrades;
    _saveProgress();
    notifyListeners();
  }

  CardRarity _getNextRarity(CardRarity current) {
    switch (current) {
      case CardRarity.common: return CardRarity.rare;
      case CardRarity.rare: return CardRarity.epic;
      case CardRarity.epic: return CardRarity.legendary;
      case CardRarity.legendary: return CardRarity.legendary;
    }
  }

  // Get random questions from completed topics for Boss Fight
  List<QuizQuestion> getRandomQuestionsFromTopics(int count) {
    final allQuestions = <QuizQuestion>[];
    
    // Collect questions from all completed topics (or all topics for now if few completed)
    // Ideally we filter by _completedTopics, but for demo we might want more variety
    for (var topic in topicsData) {
      // Only include topics from chapters 1 & 2 for the Basic Test boss
      if (['chapter-1', 'chapter-2'].contains(topic.chapterId)) {
        final quiz = getQuizByTopicId(topic.id);
        if (quiz != null) {
          allQuestions.addAll(quiz.questions);
        }
      }
    }
    
    if (allQuestions.isEmpty) return [];
    
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  // Get random questions from a specific topic (for knowledge cards)
  List<QuizQuestion> getRandomQuestionsFromTopic(String topicId, int count) {
    final quiz = getQuizByTopicId(topicId);
    if (quiz == null) return [];
    
    final questions = List<QuizQuestion>.from(quiz.questions);
    questions.shuffle();
    return questions.take(count).toList();
  }

  // Reset progress
  Future<void> resetProgress() async {
    _completedTopics = [];
    _skippedTopics = [];
    _currentTopic = null;
    _inventory = [];
    _activeDeck = [];
    _chapterProgress = {};
    _achievements = [];
    _dungeonRun = null;
    _playerStats = PlayerStats();
    _skillTree = List.from(initialSkillTree);
    _relics = [];
    _ascensionLevel = 0;
    _prestigeLevel = 0;
    _runHistory = [];
    _gold = 0;
    _initializeRoadmap();
    await _storage.resetProgress();
    notifyListeners();
  }
}
