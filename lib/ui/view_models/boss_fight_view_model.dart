import 'package:flutter/material.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/quiz.dart';
import '../../data/repositories/boss_repository.dart';
import 'dart:math';

class BossFightViewModel extends ChangeNotifier {
  final BossRepository _repository;
  
  BossFight? _currentBoss;
  bool _isLoading = false;
  String? _error;
  Quiz? _currentQuiz;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  String _combatLog = '';

  BossFightViewModel(this._repository);

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

  // Start the battle
  void startBattle() {
    if (_currentBoss == null) return;
    
    _currentBoss = _currentBoss!.copyWith(
      state: BossFightState.playerTurn,
      currentTurn: 1,
    );
    _addToCombatLog('⚔️ Your turn! Choose your action.');
    notifyListeners();
  }

  // Player chooses to use a card from their deck
  void useCard(Reward card) {
    if (_currentBoss == null || !canAttack) return;

    int damage = _calculateCardDamage(card);
    _dealDamageToBoss(damage);
    _addToCombatLog('💥 You used ${card.name}! Dealt $damage damage.');
    
    _endPlayerTurn();
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

    Future.delayed(const Duration(milliseconds: 1500), () {
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

    // Back to player turn
    _currentBoss = _currentBoss!.copyWith(
      state: BossFightState.playerTurn,
      currentTurn: _currentBoss!.currentTurn + 1,
    );
    _addToCombatLog('⚔️ Your turn again!');
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
    
    // Reset battle state
    _currentBoss = _currentBoss!.copyWith(
      currentHp: _currentBoss!.maxHp,
      currentPlayerHp: _currentBoss!.maxPlayerHp,
      state: BossFightState.notStarted,
      currentTurn: 0,
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
