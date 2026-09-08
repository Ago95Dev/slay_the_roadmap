import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/hub_config.dart';
import '../domain/models/analytics_log.dart';
import '../domain/models/campaign_lore.dart';
import '../domain/models/player_progress.dart';
import '../models/types.dart';
import '../data/skill_tree_data.dart';
import '../data/roadmap_data.dart' as data;
import '../data/cards_data.dart' as cards_data;
import '../services/engine_client.dart';
import '../services/storage_service.dart';
import '../services/dungeon_generator.dart';
import '../data/topics_and_quizzes.dart';
import '../utils/constants.dart';

class GameProvider with ChangeNotifier {
  late final EngineClient _engine;
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  /// Indica se l'app è configurata per inviare eventi all'Hub (ha credenziali valide)
  bool get isHubOnline => _engine is HttpEngineClient;

  // --- Hub Gamification (F7) ---
  EngineClient get engine => _engine;
  String _hubPlayerId = '';

  // --- Fase 3: sessione per utente ---
  // `_currentUsername` è il GamerTag loggato (null = anonimo). `_hubPlayerId`
  // è invece lo `slay_<uuid>` stabile per utente (persistito), mai lo
  // username in chiaro: è l'unico id inviato all'Hub (offline-first,
  // FakeEngineClient di default, nessun segreto nel codice).
  String? _currentUsername;

  /// GamerTag loggato (`null` se anonimo). Gate minimo Fase 3: senza utente
  /// non si accede ai save per-utente (chiavi `..._<username>`).
  String? get currentUsername => _currentUsername;

  /// True quando un utente è loggato (gate minimo per l'accesso ai progress).
  bool get isLoggedIn =>
      _currentUsername != null && _currentUsername!.isNotEmpty;

  /// Nome mostrato in UI (username, mai lo slay_id).
  String get displayName => _currentUsername ?? '';

  /// Chiave dello slay_id stabile per utente.
  static String hubPlayerKeyForUser(String username) =>
      'slay_hub_player_id_$username';

  /// Carica lo `slay_<uuid>` persistito per [username] o lo crea (`slay_` +
  /// uuid v4) una sola volta. Mai username in chiaro come playerId.
  Future<String> _resolveHubPlayerId(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = hubPlayerKeyForUser(username);
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'slay_${_uuid.v4()}';
    await prefs.setString(key, id);
    return id;
  }

  // Player State
  List<String> _completedTopics = [];
  List<String> _skippedTopics = []; // Track skipped topics separately
  String? _currentTopic;
  List<String> _inventory = [];
  List<String> _activeDeck = [];
  Map<String, Map<String, dynamic>> _chapterProgress = {};
  List<String> _achievements = [];
  // Badge locali (Fase 2, US-02/US-04): 'topic:<id>' al quiz passato,
  // 'boss:<id>' alla vittoria. L'Hub resta specchio best-effort
  // (quiz_completed/boss_defeated), la collection locale è la fonte per la UI.
  List<String> get badges => List.unmodifiable(_achievements);
  // Reward già riscattate 1/topic (Fase 2, US-03): specchio in-memory del set
  // `claimedRewardTopics` (contratto persistence_repository), consultato da
  // quiz_screen e reward_selection_screen prima di ogni claim.
  final Set<String> _claimedRewardTopics = {};
  Set<String> get claimedRewardTopics => Set.unmodifiable(_claimedRewardTopics);
  bool isRewardClaimed(String topicId) =>
      _claimedRewardTopics.contains(topicId);

  /// Riscatta la reward del topic (1/topic). Ritorna false se già riscattata
  /// (re-claim bloccato, nessun effetto).
  bool claimRewardTopic(String topicId) {
    if (_claimedRewardTopics.contains(topicId)) return false;
    _claimedRewardTopics.add(topicId);
    _saveProgress();
    notifyListeners();
    return true;
  }
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

  // --- Fase 1B / F12: Avatar, Daily Reward, Analytics ---
  int _avatarIconIndex = 0;
  int _avatarFrameIndex = 0;
  String _activeTitle = '';
  String _lastDailyClaim = '';
  Map<String, int> _failCount = {};
  AnalyticsLog _analytics = const AnalyticsLog();

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

  // --- Fase 1B / F12: Getters ---
  int get avatarIconIndex => _avatarIconIndex;
  int get avatarFrameIndex => _avatarFrameIndex;
  String get activeTitle => _activeTitle;
  bool get hasTitle => _activeTitle.isNotEmpty;
  String get lastDailyClaim => _lastDailyClaim;
  Map<String, int> get failCount => _failCount;
  AnalyticsLog get analytics => _analytics;
  String get hubPlayerId => _hubPlayerId;

  /// Icona avatar corrente (indice clampato per i save corrotti).
  String get avatarIcon => PlayerProgress.avatarIcons[
      _avatarIconIndex.clamp(0, PlayerProgress.avatarIcons.length - 1)];

  /// Valore ARGB della cornice avatar corrente (indice clampato).
  int get avatarFrameColorValue => PlayerProgress.avatarFrameColorValues[
      _avatarFrameIndex.clamp(0, PlayerProgress.avatarFrameColorValues.length - 1)];

  /// XP del bonus giornaliero (Fase 1B-E).
  static const int dailyRewardXp = 25;

  /// Data odierna in formato `yyyy-MM-dd`.
  static String dailyDateString(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  /// True se la ricompensa giornaliera è ancora da riscattare oggi.
  bool get isDailyRewardAvailable =>
      _lastDailyClaim != dailyDateString(DateTime.now());

  /// Riscatta il bonus giornaliero (+25 XP). Ritorna true al primo claim.
  bool claimDailyReward({DateTime? now}) {
    final today = dailyDateString(now ?? DateTime.now());
    if (_lastDailyClaim == today) return false;
    _lastDailyClaim = today;
    _awardExperience(dailyRewardXp);
    _hubEvent('daily_login', {'xp': dailyRewardXp, 'streak': 1}); // Integrazione Hub
    _analytics = _analytics.record(
      AnalyticsEvent.rewardClaim,
      value: dailyRewardXp,
    );
    _saveProgress();
    notifyListeners();
    return true;
  }

  /// Avatar (Fase 1B-B): cambia icona e/o cornice.
  void setAvatar({int? iconIndex, int? frameIndex}) {
    final icons = PlayerProgress.avatarIcons.length;
    final frames = PlayerProgress.avatarFrameColorValues.length;
    final nextIcon = (iconIndex ?? _avatarIconIndex).clamp(0, icons - 1);
    final nextFrame = (frameIndex ?? _avatarFrameIndex).clamp(0, frames - 1);
    if (nextIcon == _avatarIconIndex && nextFrame == _avatarFrameIndex) return;
    _avatarIconIndex = nextIcon;
    _avatarFrameIndex = nextFrame;
    _saveProgress();
    notifyListeners();
  }

  static const Map<String, String> _chapterTitles = {
    'foundation': 'Il Novizio',
    'core': 'Lo Studioso',
    'advanced': 'Il Maestro',
  };

  /// Titolo capitolo (Fase 1B-B): assegnato al completamento.
  bool checkAndAwardChapterTitle(
    String chapterId, {
    required bool chapterComplete,
    required bool bossDefeated,
  }) {
    if (!chapterComplete || !bossDefeated) return false;
    final title = _chapterTitles[chapterId];
    if (title == null || title.isEmpty) return false;
    if (_activeTitle == title) return false;
    _activeTitle = title;
    _saveProgress();
    notifyListeners();
    return true;
  }

  /// Topic "da ripassare" (F12): id con almeno 2 fallimenti.
  List<String> get reviewTopics {
    final entries = _failCount.entries
        .where((e) => e.value >= PlayerProgress.reviewThreshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in entries) e.key];
  }

  /// Fallimenti registrati per [topicId].
  int failCountOf(String topicId) => _failCount[topicId] ?? 0;

  /// Registra un fallimento per il topic (F12).
  void recordQuizFail(String topicId) {
    _failCount = Map<String, int>.from(_failCount);
    _failCount[topicId] = (_failCount[topicId] ?? 0) + 1;
    _analytics = _analytics.record(
      AnalyticsEvent.quizFail,
      topicId: topicId,
    );
    _saveProgress();
    notifyListeners();
  }

  /// Registra l'avvio di una sessione (F12).
  void recordSessionStart() {
    _analytics = _analytics.record(AnalyticsEvent.sessionStart);
    _saveProgress();
    notifyListeners();
  }

  int get availableSkillPoints {
    final used = _skillTree.where((s) => s.unlocked).fold(0, (sum, s) => sum + s.cost);
    final total = calculateSkillPoints(_playerStats.level, _prestigeLevel);
    return total - used;
  }

  GameProvider() {
    // Detect Hub credentials from --dart-define
    const hubUser = String.fromEnvironment('HUB_USER', defaultValue: '');
    const hubPass = String.fromEnvironment('HUB_PASS', defaultValue: '');
    _engine = (hubUser.isNotEmpty && hubPass.isNotEmpty)
        ? HttpEngineClient(username: hubUser, password: hubPass)
        : FakeEngineClient();

    // Solo init sincrona nel ctor: MAI lavoro async qui (H1).
    _initializeRoadmap();
  }

  bool _loadStarted = false;

  /// Caricamento async del save, da chiamare FUORI dal ctor (addPostFrameCallback
  /// in main): così notifyListeners() non può mai avvenire durante il build.
  Future<void> loadProgress() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await _loadProgressInternal();
  }

  /// Ricarica il save dell'utente corrente (Fase 3: usata al login per
  /// caricare il save per-utente e notificare la UI). Bypassa il guard
  /// `_loadStarted` (boot una tantum) perché il login può avvenire dopo.
  Future<void> _reloadForUser() async {
    _loadStarted = true;
    await _loadProgressInternal();
  }

  void _initializeRoadmap() {
    _roadmapNodes = List.from(data.roadmapNodes);
  }



  Future<void> _loadProgressInternal() async {
    // Reset state to default before loading to prevent dirty reads across users
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
    _viewedResources = {};
    _runHistory = [];
    _roadmapNodes = List.from(data.roadmapNodes);
    _gold = 0;
    _selectedPath = null;
    _hasStartedJourney = false;
    _avatarIconIndex = 0;
    _avatarFrameIndex = 0;
    _activeTitle = '';
    _lastDailyClaim = '';
    _failCount = {};
    _analytics = const AnalyticsLog();
    _cardUpgrades = {};

    // Load local player profile
    final currentUser = await _storage.loadCurrentUser();
    if (currentUser != null && currentUser.isNotEmpty) {
      _currentUsername = currentUser;
      _hubPlayerId = await _resolveHubPlayerId(currentUser);
    } else {
      _currentUsername = null;
      _hubPlayerId = '';
    }

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
      _claimedRewardTopics
        ..clear()
        ..addAll(
          (progress['claimedRewardTopics'] as List? ?? const []).map(
            (e) => e.toString(),
          ),
        );
      _achievements = List<String>.from(progress['achievements'] ?? []);
      _selectedPath = progress['selectedPath'];
      _hasStartedJourney = progress['hasStartedJourney'] ?? false;
      // Fase 1B / F12: carica nuovi campi con default per save vecchi
      _avatarIconIndex = progress['avatarIconIndex'] ?? 0;
      _avatarFrameIndex = progress['avatarFrameIndex'] ?? 0;
      _activeTitle = progress['activeTitle'] ?? '';
      _lastDailyClaim = progress['lastDailyClaim'] ?? '';
      _failCount = Map<String, int>.from(
        (progress['failCount'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ?? {},
      );
      _analytics = AnalyticsLog.fromJson(progress['analytics'] as List?);
      
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
    
    // Always ensure start node is completed and first topics are unlocked.
    // This runs AFTER loading progress to guarantee initial accessibility.
    // Guard con firstOrNull: save corrotti o roadmap senza 'start' non crashano.
    final startNode =
        _roadmapNodes.where((node) => node.id == 'start').firstOrNull;
    if (startNode != null) {
      startNode.unlocked = true;
      startNode.completed = true;

      // Unlock the nodes connected to start (first chapter topics)
      for (final connectionId in startNode.connections) {
        _roadmapNodes
            .where((n) => n.id == connectionId)
            .firstOrNull
            ?.unlocked = true;
      }
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
      'claimedRewardTopics': _claimedRewardTopics.toList(),
      'achievements': _achievements,
      'selectedPath': _selectedPath,
      'hasStartedJourney': _hasStartedJourney,
      'cardUpgrades': _cardUpgrades.map((k, v) => MapEntry(k, v.toJson())),
      // Fase 1B / F12
      'avatarIconIndex': _avatarIconIndex,
      'avatarFrameIndex': _avatarFrameIndex,
      'activeTitle': _activeTitle,
      'lastDailyClaim': _lastDailyClaim,
      'failCount': _failCount,
      'analytics': _analytics.toJson(),
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
        // Fase 2 (decisione utente: skip-senza-XP RIMOSSO): lo skip NON dà XP
        // e NON sblocca i nodi successivi. Sblocco solo via quiz passato ≥80%
        // (completeTopicQuiz). Niente _unlockNextNodes qui.
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
      // F12: registra il fallimento per "Da ripassare"
      recordQuizFail(topicId);
      _saveProgress();
      notifyListeners();
      return;
    }

    // Mark topic as completed
    if (!_completedTopics.contains(topicId)) {
      _completedTopics.add(topicId);

      // Badge locale topic (Fase 2, US-02): l'Hub resta best-effort.
      final topicBadge = 'topic:$topicId';
      if (!_achievements.contains(topicBadge)) _achievements.add(topicBadge);

      // Award experience based on score
      final experienceReward = 50 + (score * 10);
      _awardExperience(experienceReward);

      // --- Hub: notify quiz passed (fire-and-forget) ---
      _hubEvent(HubConfig.quizCompletedAction, {
        'xp_amount': HubConfig.quizXpAmount,
        'badge': topicId,
      });

      // F12: registra analytics quiz passato e pulisci failCount
      _analytics = _analytics.record(
        AnalyticsEvent.quizPass,
        topicId: topicId,
        value: experienceReward,
      );
      _failCount = Map<String, int>.from(_failCount)..remove(topicId);
      
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
    _hubEvent('study_resource_viewed', {'xp': xpReward, 'gold': goldReward, 'topicId': topicId}); // Integrazione Hub
    
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
    final skill = _skillTree.where((s) => s.id == skillId).firstOrNull;
    if (skill == null) return;
    if (availableSkillPoints >= skill.cost && !skill.unlocked) {
      skill.unlocked = true;
      _hubEvent('skill_unlocked', {'skillId': skillId, 'cost': skill.cost}); // Integrazione Hub
      
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
    
    final room = _dungeonRun!.rooms.where((r) => r.id == roomId).firstOrNull;
    if (room == null) return;
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
      _hubEvent('dungeon_cleared', {
        'ascension_level': _dungeonRun?.ascensionLevel ?? 0, 
        'nodes_visited': _dungeonRun?.floor ?? 1, 
        'xp': 200
      });
    }
    
    _saveProgress();
    notifyListeners();
  }

  // Award experience (Fase 2: unificata su PlayerProgress.levelForXp,
  // soglie cumulative 0/100/500 uguali all'Hub — unica fonte di verità anche
  // per la HUD. Il legacy sottrattivo 100+level*100 (skill_tree_data) non è
  // più usato. Nota numeri: gli XP mostrati sono quelli LOCALI; HubConfig
  // .quizXpAmount (100) è solo lo specchio best-effort inviato all'Hub in
  // `quiz_completed` (offline-first: nessun blocco se l'Hub è down).
  void _awardExperience(int amount) {
    final oldLevel = PlayerProgress.levelForXp(_playerStats.experience);
    _playerStats.experience += amount;
    final newLevel = PlayerProgress.levelForXp(_playerStats.experience);
    if (newLevel > oldLevel) {
      _playerStats.level = newLevel;
      _playerStats.maxHp += 5 * (newLevel - oldLevel);
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
    final node = _roadmapNodes.where((n) => n.id == nodeId).firstOrNull;
    if (node == null || !node.unlocked) return;

    node.completed = true;

    // Unlock connected nodes
    for (final connectionId in node.connections) {
      _roadmapNodes
          .where((n) => n.id == connectionId)
          .firstOrNull
          ?.unlocked = true;
    }

    // Award rewards
    for (final reward in node.rewards) {
      _processReward(reward);
    }

    // If it's a topic node, mark topic as completed
    if (node.type == RoadmapNodeType.topic && node.topicId != null) {
      completeTopic(node.topicId!);
    }

    // --- Hub: notify boss defeated (fire-and-forget) ---
    if (node.type == RoadmapNodeType.boss && node.bossId != null) {
      _hubEvent(HubConfig.bossDefeatedAction, {
        'badge': node.bossId!,
      });
      // F12: analytics boss sconfitto
      _analytics = _analytics.record(
        AnalyticsEvent.bossWin,
        topicId: node.bossId,
      );
    }

    _saveProgress();
    notifyListeners();
  }

  /// Vittoria boss (Fase 2, US-04): badge locale + XP vittoria + sblocco
  /// del capitolo (nodo boss completato -> connessioni aperte) + evento Hub
  /// `boss_defeated` best-effort. Idempotente: se il boss risulta già
  /// sconfitto non riassegna XP/badge/reward.
  void defeatBoss(String bossId) {
    final badge = 'boss:$bossId';
    final node = _roadmapNodes
        .where(
          (n) => n.type == RoadmapNodeType.boss && n.bossId == bossId,
        )
        .firstOrNull;
    if (_achievements.contains(badge) && (node == null || node.completed)) {
      return;
    }
    if (!_achievements.contains(badge)) _achievements.add(badge);
    _awardExperience(GameConstants.xpPerBossDefeated);
    if (node != null && !node.completed) {
      // Sblocco capitolo + reward nodo + evento Hub (in completeRoadmapNode).
      // La vittoria presuppone aver raggiunto il boss: force-unlock del nodo.
      node.unlocked = true;
      completeRoadmapNode(node.id);
    } else {
      _analytics = _analytics.record(
        AnalyticsEvent.bossWin,
        topicId: bossId,
      );
      _saveProgress();
      notifyListeners();
    }
  }

  void _processReward(RoadmapReward reward) {
    // --- Hub: notify reward claimed (fire-and-forget) ---
    _hubEvent(HubConfig.claimRewardAction, {
      'reward_type': reward.type,
      'reward_id': reward.id ?? '',
      'reward_amount': reward.amount ?? 0,
    });

    switch (reward.type) {
      case 'card':
        // Award a random card based on rarity
        // For now, just add placeholder
        addCardToInventory('card_${DateTime.now().millisecondsSinceEpoch}');
        break;
      case 'relic':
        if (reward.id != null && !_relics.contains(reward.id!)) {
          _relics.add(reward.id!);
          _hubEvent('relic_acquired', {'relicId': reward.id!}); // Integrazione Hub
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
    _claimedRewardTopics.clear();
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
    // Fase 1B / F12: reset nuovi campi
    _avatarIconIndex = 0;
    _avatarFrameIndex = 0;
    _activeTitle = '';
    _lastDailyClaim = '';
    _failCount = {};
    _analytics = const AnalyticsLog();
    _initializeRoadmap();
    await _storage.resetProgress();
    notifyListeners();
  }

  // --- Auth & Profile (Fase 3: save per utente + slay_id stabile) ---
  Future<bool> registerLocal(String username, String password) async {
    final exists = await _storage.checkUserExists(username);
    if (exists) return false;
    await _storage.saveLocalUser(username, password);
    return loginLocal(username, password);
  }

  Future<bool> loginLocal(String username, String password) async {
    final isValid = await _storage.checkLocalUser(username, password);
    if (isValid) {
      _currentUsername = username;
      _hubPlayerId = await _resolveHubPlayerId(username);
      await _storage.saveCurrentUser(username);
      // Reload del save per-utente + notify (isolamento tra utenti).
      await _reloadForUser();
      return true;
    }
    return false;
  }

  /// Logout (Fase 3): rimuove solo `current_user`, pulisce TUTTO lo stato
  /// in-memory (nessun accesso ai progress senza utente) e notifica. I save
  /// per-utente restano persistiti sotto le chiavi `..._<username>`.
  Future<void> logout() async {
    _currentUsername = null;
    _hubPlayerId = '';
    await _storage.logoutUser();
    _clearInMemoryState();
    notifyListeners();
  }

  /// Azzera lo stato in-memory ai default (senza toccare lo storage).
  /// Usata dal logout; il wipe persistente resta in [resetProgress].
  void _clearInMemoryState() {
    _completedTopics = [];
    _skippedTopics = [];
    _claimedRewardTopics.clear();
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
    _viewedResources = {};
    _runHistory = [];
    _gold = 0;
    _selectedPath = null;
    _hasStartedJourney = false;
    _avatarIconIndex = 0;
    _avatarFrameIndex = 0;
    _activeTitle = '';
    _lastDailyClaim = '';
    _failCount = {};
    _analytics = const AnalyticsLog();
    _cardUpgrades = {};
    _initializeRoadmap();
  }

  // --- Hub Gamification: fire-and-forget event dispatch ---
  /// Invia un evento all'Hub senza mai bloccare o lanciare eccezioni.
  /// Se l'Hub è offline o le credenziali mancano, non succede niente.
  Future<void> _hubEvent(String actionId, Map<String, dynamic> data) async {
    if (_hubPlayerId.isEmpty) return; // Prevent sending events if user is not logged in locally
    try {
      await _engine.execute(
        actionId: actionId,
        playerId: _hubPlayerId,
        data: data,
      );
    } catch (_) {
      // fire-and-forget: mai bloccare il gioco per errori Hub
    }
  }
}
