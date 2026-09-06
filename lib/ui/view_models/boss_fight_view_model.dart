import 'package:flutter/material.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/quiz.dart';
import '../../data/repositories/boss_repository.dart';
import 'dart:math';

class BossFightViewModel extends ChangeNotifier {
  final BossRepository _repository;
  final Duration bossTurnDelay;

  BossFight? _currentBoss;
  bool _isLoading = false;
  String? _error;
  Quiz? _currentQuiz;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  String _combatLog = '';
  List<Reward> _initialDeck = const [];

  BossFightViewModel(this._repository,
      {this.bossTurnDelay = const Duration(milliseconds: 1500)});

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
  // (solo attack/defense, copie single-use per il fight).
  void startBattle({List<Reward> inventory = const []}) {
    if (_currentBoss == null) return;

    final deck = inventory
        .where((r) =>
            r.type == RewardType.attack || r.type == RewardType.defense)
        .map((r) => r.copyWith(isSelected: false))
        .toList();
    _initialDeck = List.unmodifiable(deck);

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
  // single-use per fight). Si possono giocare più carte per turno finché
  // c'è energia; a energia 0 le carte sono bloccate. Il turno finisce con
  // il quiz ("quiz di fine turno", sempre disponibile) o con la vittoria.
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

    int damage = _calculateCardDamage(card);
    _dealDamageToBoss(damage);

    // Lethal card -> vittoria immediata
    if (_currentBoss!.isBossDefeated) {
      _currentBoss = _currentBoss!.copyWith(state: BossFightState.victory);
      _addToCombatLog(
          '💥 You used ${card.name}! Dealt $damage damage. 🎉 Victory! You defeated ${_currentBoss!.name}!');
      notifyListeners();
      return;
    }

    _addToCombatLog(
        '💥 You used ${card.name}! Dealt $damage damage. (⚡$newEnergy/${_currentBoss!.maxEnergy} — play another card or answer the quiz)');
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

  void submitQuiz() {
    if (_currentQuiz == null) return;

    int correctAnswers = 0;
    for (int i = 0; i < _currentQuiz!.questions.length; i++) {
      if (_selectedAnswers[i] == _currentQuiz!.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    double percentage = (correctAnswers / _currentQuiz!.questions.length) * 100;
    int damage = (percentage / 10).round(); // 1 damage per 10%
    
    _dealDamageToBoss(damage);
    _addToCombatLog('✅ Quiz complete! Score: ${percentage.toStringAsFixed(0)}%. Dealt $damage damage.');
    
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];
    
    _endPlayerTurn();
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

  void _executeBossTurn() {
    if (_currentBoss == null) return;

    final bossAction = _selectBossAction();
    int damage = bossAction.damage;
    
    _dealDamageToPlayer(damage);
    _addToCombatLog('👹 ${_currentBoss!.name} used ${bossAction.description}! You took $damage damage.');

    // Check if player is defeated
    if (_currentBoss!.isPlayerDefeated) {
      _currentBoss = _currentBoss!.copyWith(
        state: BossFightState.defeat,
      );
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

  BossAction _selectBossAction() {
    final random = Random();
    final availableActions = _currentBoss!.availableBossActions;
    final actionType = availableActions[random.nextInt(availableActions.length)];

    switch (actionType) {
      case BossActionType.normalAttack:
        return const BossAction(
          type: BossActionType.normalAttack,
          damage: 10,
          description: 'Normal Attack',
        );
      case BossActionType.specialAttack:
        return const BossAction(
          type: BossActionType.specialAttack,
          damage: 20,
          description: 'Special Attack',
        );
      case BossActionType.heal:
        int healAmount = 15;
        _currentBoss = _currentBoss!.copyWith(
          currentHp: min(_currentBoss!.currentHp + healAmount, _currentBoss!.maxHp),
        );
        return BossAction(
          type: BossActionType.heal,
          damage: -healAmount,
          description: 'Heal ($healAmount HP)',
        );
      case BossActionType.statusEffect:
        return const BossAction(
          type: BossActionType.statusEffect,
          damage: 5,
          description: 'Poison Effect',
        );
    }
  }

  int _calculateCardDamage(Reward card) {
    int baseDamage = 15;
    
    if (card.type == RewardType.attack) {
      baseDamage += (card.effects['damage'] as num?)?.toInt() ?? 0;
    }
    
    return baseDamage;
  }

  void _dealDamageToBoss(int damage) {
    if (_currentBoss == null) return;
    
    int newHp = max(0, _currentBoss!.currentHp - damage);
    _currentBoss = _currentBoss!.copyWith(currentHp: newHp);
  }

  void _dealDamageToPlayer(int damage) {
    if (_currentBoss == null) return;
    
    int newHp = max(0, _currentBoss!.currentPlayerHp - damage);
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

    // Reset battle state: full HP + energia, deck ripristinato
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
