import 'package:flutter/material.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/quiz.dart';
import '../../data/repositories/boss_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import 'dart:math';

class BossFightViewModel extends ChangeNotifier {
  final BossRepository _repository;
  final QuizRepository _quizRepository;
  final Random _random;
  final Duration bossTurnDelay;

  BossFight? _currentBoss;
  bool _isLoading = false;
  String? _error;
  Quiz? _currentQuiz;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  String _combatLog = '';
  List<Reward> _initialDeck = const [];
  int _shield = 0;

  BossFightViewModel(
    this._repository, {
    this.bossTurnDelay = const Duration(milliseconds: 1500),
    QuizRepository? quizRepository,
    Random? random,
  })  : _quizRepository = quizRepository ?? LocalQuizRepository(),
        _random = random ?? Random();

  // Getters
  BossFight? get currentBoss => _currentBoss;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int?> get selectedAnswers => _selectedAnswers;
  String get combatLog => _combatLog;
  
  bool get isQuizActive => _currentQuiz != null;
  bool get canAttack => _currentBoss?.state == BossFightState.playerTurn && !isQuizActive;
  bool get canUseCard =>
      canAttack &&
      (_currentBoss?.currentEnergy ?? 0) > 0 &&
      (_currentBoss?.playerDeck.isNotEmpty ?? false);
  bool get isBossDefeated => _currentBoss?.isBossDefeated ?? false;
  bool get isPlayerDefeated => _currentBoss?.isPlayerDefeated ?? false;
  bool get isBattleOver => isBossDefeated || isPlayerDefeated;

  // Load boss by ID
  Future<void> loadBoss(String bossId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentBoss = await _repository.getBossById(bossId);
      if (_currentBoss == null) {
        _error = 'Boss not found';
      } else {
        _addToCombatLog('🎮 Battle started against ${_currentBoss!.name}!');
      }
    } catch (e) {
      _error = 'Failed to load boss: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start the battle. Il deck è popolato dall'inventario del giocatore
  // (attack/defense + utility con heal, copie single-use per il fight).
  void startBattle({List<Reward> inventory = const []}) {
    if (_currentBoss == null) return;

    final deck = inventory
        .where((r) =>
            r.type == RewardType.attack ||
            r.type == RewardType.defense ||
            (r.type == RewardType.utility &&
                ((r.effects['heal'] as num?)?.toDouble() ?? 0) > 0))
        .map((r) => r.copyWith(isSelected: false))
        .toList();
    _initialDeck = List.unmodifiable(deck);
    _shield = 0;

    _currentBoss = _currentBoss!.copyWith(
      state: BossFightState.playerTurn,
      currentTurn: 1,
      playerDeck: List.of(deck),
      maxEnergy: _currentBoss!.maxEnergy,
      currentEnergy: _currentBoss!.maxEnergy,
    );
    _addToCombatLog('⚔️ Your turn! Choose your action.');
    notifyListeners();
  }

  // Player chooses to use a card from their deck (costo: 1 energia,
  // single-use per fight). Effetti semplici clampati a max 2:
  // damage -> boss, block -> scudo sul prossimo attacco, heal -> player.
  // Si possono giocare più carte per turno finché c'è energia; a energia 0
  // le carte sono bloccate. Il turno finisce con il quiz ("quiz di fine
  // turno", sempre disponibile) o con la vittoria.
  void useCard(Reward card) {
    if (_currentBoss == null || !canAttack) return;
    if (_currentBoss!.currentEnergy <= 0) {
      _addToCombatLog('⚡ Not enough energy to use ${card.name}! Answer the quiz to end your turn.');
      notifyListeners();
      return;
    }
    if (!_currentBoss!.playerDeck.any((c) => c.id == card.id)) return;

    final newEnergy = _currentBoss!.currentEnergy - 1;
    final newDeck =
        _currentBoss!.playerDeck.where((c) => c.id != card.id).toList();
    _currentBoss = _currentBoss!.copyWith(
      currentEnergy: newEnergy,
      playerDeck: newDeck,
    );

    final damage = _clampedEffect(card, 'damage');
    final block = _clampedEffect(card, 'block');
    final heal = _clampedEffect(card, 'heal');
    final parts = <String>[];
    if (damage > 0) {
      _dealDamageToBoss(damage);
      parts.add('dealt $damage damage');
    }
    if (block > 0) {
      _shield += block;
      parts.add('gained $block shield');
    }
    if (heal > 0) {
      _healPlayer(heal);
      parts.add('healed $heal HP');
    }

    // Lethal card -> vittoria immediata
    if (_currentBoss!.isBossDefeated) {
      _currentBoss = _currentBoss!.copyWith(state: BossFightState.victory);
      _addToCombatLog(
          '💥 You used ${card.name}! ${parts.join(', ')}. 🎉 Victory! You defeated ${_currentBoss!.name}!');
      notifyListeners();
      return;
    }

    final effect = parts.isEmpty ? 'no effect' : parts.join(', ');
    _addToCombatLog(
        '💥 You used ${card.name}! $effect. (⚡$newEnergy/${_currentBoss!.maxEnergy} — play another card or answer the quiz)');
    notifyListeners();
  }

  // Player chooses to answer quiz questions for attack
  void startQuiz() {
    if (_currentBoss == null || !canAttack) return;
    if (_currentBoss!.adaptiveQuizzes.isEmpty) {
      _addToCombatLog('❌ No quiz available for this boss.');
      return;
    }

    _currentQuiz = _currentBoss!.adaptiveQuizzes[0];
    _currentQuestionIndex = 0;
    _selectedAnswers = List.filled(_currentQuiz!.questions.length, null);
    _addToCombatLog('📝 Started quiz to attack the boss!');
    notifyListeners();
  }

  void selectQuizAnswer(int answerIndex) {
    if (_currentQuestionIndex >= _selectedAnswers.length) return;
    _selectedAnswers[_currentQuestionIndex] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Il quiz chiude il turno del player (1 danno per risposta giusta)
  /// oppure risolve il turno del boss (domanda singola: giusta -> boss -1,
  /// errata -> mossa del boss).
  void submitQuiz() {
    if (_currentQuiz == null) return;

    if (_currentBoss?.state == BossFightState.bossTurn) {
      _resolveBossQuiz();
      return;
    }

    int correctAnswers = 0;
    for (int i = 0; i < _currentQuiz!.questions.length; i++) {
      if (_selectedAnswers[i] == _currentQuiz!.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    // Danni riscalati: 1 per risposta giusta (niente più formula %/10).
    final damage = correctAnswers;

    _dealDamageToBoss(damage);
    _addToCombatLog('✅ Quiz complete! Score: $correctAnswers/${_currentQuiz!.questions.length}. Dealt $damage damage.');

    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];

    _endPlayerTurn();
  }

  /// Risolve la domanda singola del turno boss: giusta -> boss -1 HP,
  /// errata -> SEMPRE danno al player (-1 normale, -2 se il boss è
  /// enraged a HP ≤50%). Mai heal come risposta a un errore.
  void _resolveBossQuiz() {
    final question = _currentQuiz!.questions.first;
    final selected =
        _selectedAnswers.isNotEmpty ? _selectedAnswers.first : null;
    final correct = selected == question.correctAnswerIndex;

    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];

    if (correct) {
      _dealDamageToBoss(1);
      _addToCombatLog(
          '✅ Correct! You counter ${_currentBoss!.name} for 1 damage.');
    } else {
      _strikePlayer();
    }

    if (_currentBoss!.isBossDefeated) {
      _currentBoss = _currentBoss!.copyWith(state: BossFightState.victory);
      _addToCombatLog('🎉 Victory! You defeated ${_currentBoss!.name}!');
      notifyListeners();
      return;
    }

    if (_currentBoss!.isPlayerDefeated) {
      _currentBoss = _currentBoss!.copyWith(state: BossFightState.defeat);
      _addToCombatLog('💀 Defeat! You were defeated by ${_currentBoss!.name}.');
      notifyListeners();
      return;
    }

    // Back to player turn, energia ripristinata
    _currentBoss = _currentBoss!.copyWith(
      state: BossFightState.playerTurn,
      currentTurn: _currentBoss!.currentTurn + 1,
      currentEnergy: _currentBoss!.maxEnergy,
    );
    _addToCombatLog('⚔️ Your turn again! (⚡${_currentBoss!.maxEnergy}/${_currentBoss!.maxEnergy})');
    notifyListeners();
  }

  void _endPlayerTurn() {
    if (_currentBoss == null) return;

    // Check if boss is defeated
    if (_currentBoss!.isBossDefeated) {
      _currentBoss = _currentBoss!.copyWith(
        state: BossFightState.victory,
      );
      _addToCombatLog('🎉 Victory! You defeated ${_currentBoss!.name}!');
      notifyListeners();
      return;
    }

    // Boss turn
    _currentBoss = _currentBoss!.copyWith(
      state: BossFightState.bossTurn,
    );
    notifyListeners();

    Future.delayed(bossTurnDelay, () {
      _executeBossTurn();
    });
  }

  /// Turno boss: se HP ≤25% il boss si rigenera +2 PRIMA di porre la
  /// domanda (tratto di soglia, clamp a maxHp), poi pesca 1 domanda RANDOM
  /// dai quiz dei topic del capitolo (adaptiveQuizzes del boss, o fallback
  /// ai quiz del capitolo via QuizRepository). Giusta -> boss -1,
  /// errata -> danno al player. Senza domande, il boss colpisce subito.
  Future<void> _executeBossTurn() async {
    if (_currentBoss == null) return;

    if (_currentBoss!.bossHpPercentage <= 0.25) {
      _currentBoss = _currentBoss!.copyWith(
        currentHp: _currentBoss!.currentHp + 2,
      );
      _addToCombatLog(
          '👹 ${_currentBoss!.name} si rigenera (+2 HP)!');
    }

    final question = await _drawChapterQuestion();
    if (_currentBoss == null) return;
    if (question == null) {
      _strikePlayer();
      if (_currentBoss!.isPlayerDefeated) {
        _currentBoss = _currentBoss!.copyWith(state: BossFightState.defeat);
        _addToCombatLog('💀 Defeat! You were defeated by ${_currentBoss!.name}.');
        notifyListeners();
        return;
      }
      _currentBoss = _currentBoss!.copyWith(
        state: BossFightState.playerTurn,
        currentTurn: _currentBoss!.currentTurn + 1,
        currentEnergy: _currentBoss!.maxEnergy,
      );
      notifyListeners();
      return;
    }

    _currentQuiz = Quiz(
      id: 'boss_turn_${_currentBoss!.id}_${_currentBoss!.currentTurn}',
      topicId: _currentBoss!.chapterId,
      questions: [question],
    );
    _currentQuestionIndex = 0;
    _selectedAnswers = [null];
    _addToCombatLog(
        '👹 ${_currentBoss!.name} challenges you! Answer to counter (right: boss -1, wrong: boss strikes).');
    notifyListeners();
  }

  /// Pesca una domanda random dal pool del capitolo.
  Future<Question?> _drawChapterQuestion() async {
    if (_currentBoss == null) return null;
    var pool = _currentBoss!.adaptiveQuizzes
        .expand((q) => q.questions)
        .toList();
    if (pool.isEmpty) {
      // Fallback: quiz dei topic del capitolo via QuizRepository.
      final quizzes = <Quiz>[];
      for (final topicId
          in BossRepository.chapterTopicIds(_currentBoss!.chapterId)) {
        try {
          quizzes.add(await _quizRepository.getQuizForTopic(topicId));
        } catch (_) {
          // Topic senza quiz: si salta.
        }
      }
      if (quizzes.isEmpty) return null;
      _currentBoss = _currentBoss!.copyWith(adaptiveQuizzes: quizzes);
      pool = quizzes.expand((q) => q.questions).toList();
      if (pool.isEmpty) return null;
    }
    return pool[_random.nextInt(pool.length)];
  }

  /// Colpo del boss su errore: SEMPRE danno al player — -1 normale,
  /// -2 special se enraged (boss HP ≤50%). Mai heal qui.
  void _strikePlayer() {
    final enraged = _currentBoss!.bossHpPercentage <= 0.5;
    final damage = enraged ? 2 : 1;
    final moveName = enraged ? 'Special Attack' : 'Normal Attack';
    _dealDamageToPlayer(damage);
    _addToCombatLog(
        '👹 ${_currentBoss!.name} used $moveName! You took $damage damage.');
  }

  /// Effetto carta clampato a max 2 (sicurezza numeri: i save vecchi
  /// possono avere damage 15+).
  int _clampedEffect(Reward card, String key) {
    return ((card.effects[key] as num?)?.toInt() ?? 0).clamp(0, 2);
  }

  void _dealDamageToBoss(int damage) {
    if (_currentBoss == null) return;
    
    int newHp = max(0, _currentBoss!.currentHp - damage);
    _currentBoss = _currentBoss!.copyWith(currentHp: newHp);
  }

  void _dealDamageToPlayer(int damage) {
    if (_currentBoss == null) return;

    var remaining = damage;
    if (_shield > 0 && remaining > 0) {
      final absorbed = min(_shield, remaining);
      _shield -= absorbed;
      remaining -= absorbed;
      _addToCombatLog('🛡️ Shield absorbed $absorbed damage!');
    }

    int newHp = max(0, _currentBoss!.currentPlayerHp - remaining);
    _currentBoss = _currentBoss!.copyWith(currentPlayerHp: newHp);
  }

  void _healPlayer(int amount) {
    if (_currentBoss == null) return;
    final newHp = min(
      _currentBoss!.currentPlayerHp + amount,
      _currentBoss!.maxPlayerHp,
    );
    _currentBoss = _currentBoss!.copyWith(currentPlayerHp: newHp);
  }

  void _addToCombatLog(String message) {
    _combatLog = '$message\n$_combatLog';
    if (_combatLog.split('\n').length > 10) {
      _combatLog = _combatLog.split('\n').take(10).join('\n');
    }
  }

  void retryBattle() {
    if (_currentBoss == null) return;

    // Reset battle state: full HP + energia + scudo, deck ripristinato
    _shield = 0;
    _currentBoss = _currentBoss!.copyWith(
      currentHp: _currentBoss!.maxHp,
      currentPlayerHp: _currentBoss!.maxPlayerHp,
      state: BossFightState.notStarted,
      currentTurn: 0,
      currentEnergy: _currentBoss!.maxEnergy,
      playerDeck: List.of(_initialDeck),
    );
    _combatLog = '';
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];
    
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
