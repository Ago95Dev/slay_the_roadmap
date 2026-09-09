import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/types.dart';
import '../providers/game_provider.dart';
import '../data/cards_data.dart' as cards_data;
import '../data/roadmap_data.dart';
import '../utils/constants.dart';
import '../widgets/tiny_card_widget.dart';

class BossFightScreen extends StatefulWidget {
  final String bossId;

  const BossFightScreen({super.key, required this.bossId});

  @override
  State<BossFightScreen> createState() => _BossFightScreenState();
}

enum TurnPhase { player, bossIntro, bossQuiz, bossAttack, victory, defeat, thresholdQuiz }

/// HP effettivi del fight (numeri consegna US-04: boss 10 HP).
/// I dati roadmap dichiarano HP narrativi di progressione (80/120/180/200,
/// tier 4 = 200 per `widget_warlord`): il fight live li mappa a 10 con clamp,
/// senza toccare i dati. Il player resta a 3 HP (modello `BossFight`).
int resolveBossFightHp(Boss boss) => boss.maxHp.clamp(1, 10).toInt();

class _BossFightScreenState extends State<BossFightScreen> with TickerProviderStateMixin {
  late Boss _boss;
  TurnPhase _phase = TurnPhase.player;
  
  // Player State in Fight
  int _currentEnergy = 3;
  final int _maxEnergy = 3;
  int _playerBlock = 0;
  final List<CardModel> _hand = [];
  List<CardModel> _drawPile = [];
  final List<CardModel> _discardPile = [];
  
  // Boss State in Fight
  int _bossBlock = 0;
  BossAbility? _bossIntent;
  double _lastThresholdCrossed = 100.0;
  
  // Quiz State (Fase 2: quiz boss SENZA scadenza — decisione utente:
  // timer 25s rimosso. Nessun Timer.periodic per le domande.)
  QuizQuestion? _currentQuestion;
  bool _quizAnswered = false;
  bool _quizCorrect = false;
  bool _isThresholdQuiz = false;
  String? _forcedQuestionTopic; // For knowledge cards - force next question topic

  // Dialogue State
  bool _showDialogue = false;
  int _dialogueIndex = 0;
  String _currentDialogueText = '';
  Timer? _typewriterTimer;

  // Fase 2: la vittoria assegna badge+XP+sblocco una sola volta.
  bool _victoryReported = false;

  // Animations
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeFight();
    
    // Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeFight() {
    final gameProvider = context.read<GameProvider>();
    final bossData = getBossById(widget.bossId);
    
    if (bossData == null) {
      Navigator.pop(context);
      return;
    }

    // Clone boss data to avoid modifying static data.
    // Numeri consegna: il fight resta a 10 HP anche se i dati roadmap
    // dichiarano HP narrativi (cfr. resolveBossFightHp).
    final fightHp = resolveBossFightHp(bossData);
    _boss = Boss(
      id: bossData.id,
      name: bossData.name,
      description: bossData.description,
      maxHp: fightHp,
      currentHp: fightHp,
      abilities: bossData.abilities,
      thresholdPowers: bossData.thresholdPowers,
      icon: bossData.icon,
      tier: bossData.tier,
      imageAsset: bossData.imageAsset,
      backgroundImage: bossData.backgroundImage,
      openingDialogue: bossData.openingDialogue,
    );

    // Initialize Deck from player's actual deck
    if (gameProvider.activeDeck.isNotEmpty) {
      // Use player's actual deck
      _drawPile = gameProvider.activeDeck
          .map((uniqueId) {
            final card = gameProvider.getCardInstance(uniqueId);
            return card;
          })
          .whereType<CardModel>()
          .toList();
    } else {
      // Fallback to default deck if no active deck
      _drawPile = [
        cards_data.getCardById('strike')!,
        cards_data.getCardById('strike')!,
        cards_data.getCardById('strike')!,
        cards_data.getCardById('defend')!,
        cards_data.getCardById('defend')!,
        cards_data.getCardById('bash')!,
        cards_data.getCardById('fireball')!,
        cards_data.getCardById('quick_shot')!,
        cards_data.getCardById('strike')!,
        cards_data.getCardById('defend')!,
      ];
    }
   _drawPile.shuffle();
    
    // Start Dialogue if available, otherwise start turn
    if (_boss.openingDialogue != null && _boss.openingDialogue!.isNotEmpty) {
      // Small delay to let UI build
      Future.delayed(const Duration(milliseconds: 500), _startDialogue);
    } else {
      _startPlayerTurn();
    }
  }

  void _startPlayerTurn() {
    setState(() {
      _phase = TurnPhase.player;
      _currentEnergy = _maxEnergy;
      _playerBlock = 0; 
      
      _drawCards(4); 
      _determineBossIntent();
    });
  }

  void _drawCards(int count) {
    for (int i = 0; i < count; i++) {
      if (_drawPile.isEmpty) {
        if (_discardPile.isEmpty) break;
        _drawPile.addAll(_discardPile);
        _discardPile.clear();
        _drawPile.shuffle();
      }
      if (_drawPile.isNotEmpty) {
        _hand.add(_drawPile.removeLast());
      }
    }
  }

  void _determineBossIntent() {
    final ability = _boss.abilities[Random().nextInt(_boss.abilities.length)];
    setState(() {
      _bossIntent = ability;
    });
  }

  void _playCard(CardModel card) {
    if (_phase != TurnPhase.player) return;

    if (_currentEnergy < card.manaCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough energy!'), duration: Duration(milliseconds: 500)),
      );
      return;
    }

    setState(() {
      _currentEnergy -= card.manaCost;
      _hand.remove(card);
      _discardPile.add(card);

      // Check if this is a knowledge card
      if (card.type == CardType.knowledge && card.questionTopicFilter != null) {
        // Set the forced topic for the next quiz
        _forcedQuestionTopic = card.questionTopicFilter;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📚 ${card.name} activated! The boss will be questioned on ${card.topicId}!'),
            backgroundColor: const Color(0xFF8B5CF6), // Purple color
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Apply Card Effects
      else if (card.type == CardType.attack) {
        int damage = card.effect;
        
        // Deal damage to boss
        int actualDamage = damage;
        if (_bossBlock > 0) {
          if (_bossBlock >= actualDamage) {
            _bossBlock -= actualDamage;
            actualDamage = 0;
          } else {
            actualDamage -= _bossBlock;
            _bossBlock = 0;
          }
        }
        
        int oldHp = _boss.currentHp;
        _boss.currentHp = (_boss.currentHp - actualDamage).clamp(0, _boss.maxHp);
        
        if (actualDamage > 0) {
          _shakeController.forward(from: 0);
        }

        // Check Thresholds
        _checkThresholds(oldHp, _boss.currentHp);

      } else if (card.type == CardType.defense) {
        _playerBlock += card.effect;
      }
      
      // Check for victory (if not handled by threshold check)
      if (_boss.currentHp <= 0 && _phase != TurnPhase.victory) {
        _phase = TurnPhase.victory;
      }
    });
  }

  void _checkThresholds(int oldHp, int newHp) {
    double oldPercent = (oldHp / _boss.maxHp) * 100;
    double newPercent = (newHp / _boss.maxHp) * 100;

    if (oldPercent > 75 && newPercent <= 75 && _lastThresholdCrossed > 75) {
      _triggerThresholdQuiz(75);
    } else if (oldPercent > 50 && newPercent <= 50 && _lastThresholdCrossed > 50) {
      _triggerThresholdQuiz(50);
    } else if (oldPercent > 25 && newPercent <= 25 && _lastThresholdCrossed > 25) {
      _triggerThresholdQuiz(25);
    }
  }

  void _triggerThresholdQuiz(double threshold) {
    _lastThresholdCrossed = threshold;
    
    // Interrupt current flow
    setState(() {
      _phase = TurnPhase.thresholdQuiz;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _startQuizPhase(isThreshold: true);
    });
  }

  void _showCardZoom(CardModel card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: SizedBox(
              width: 480,
              height: 672,
              child: TinyCardWidget(
                card: card,
                scaleDescription: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _endTurn() {
    if (_phase != TurnPhase.player) return;

    setState(() {
      _phase = TurnPhase.bossIntro;
      _discardPile.addAll(_hand);
      _hand.clear();
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      _startBossTurn();
    });
  }

  void _startBossTurn() {
    bool triggerQuiz = Random().nextBool(); 
    
    if (triggerQuiz) {
      _startQuizPhase(isThreshold: false);
    } else {
      _executeBossAttack();
    }
  }

  void _startQuizPhase({required bool isThreshold}) {
    final gameProvider = context.read<GameProvider>();
    
    // Check if a knowledge card forced a specific topic
    List<QuizQuestion> questions;
    if (_forcedQuestionTopic != null) {
      questions = gameProvider.getRandomQuestionsFromTopic(_forcedQuestionTopic!, 1);
      // Reset the forced topic after using it
      _forcedQuestionTopic = null;
    } else {
      questions = gameProvider.getRandomQuestionsFromTopics(1);
    }
    
    if (questions.isEmpty) {
      if (isThreshold) {
         // If no questions, just deal bonus damage and continue
         _handleQuizResult(true);
      } else {
        _executeBossAttack(); 
      }
      return;
    }

    setState(() {
      _phase = isThreshold ? TurnPhase.thresholdQuiz : TurnPhase.bossQuiz;
      _isThresholdQuiz = isThreshold;
      _currentQuestion = questions.first;
      _quizAnswered = false;
      _quizCorrect = false;
    });
    // Fase 2: nessun timer — il quiz boss non ha scadenza.
  }

  void _handleQuizAnswer(int index) {
    if (_quizAnswered) return;
    
    bool correct = index == _currentQuestion!.correctAnswer;
    setState(() {
      _quizAnswered = true;
      _quizCorrect = correct;
    });

    Future.delayed(const Duration(seconds: 2), () {
      _handleQuizResult(correct);
    });
  }

  void _handleQuizResult(bool correct) {
    if (correct) {
      if (_isThresholdQuiz) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KNOWLEDGE CHECK PASSED! Bonus Damage!'), backgroundColor: Colors.amber),
        );
        // Bonus damage for threshold success
        setState(() {
          _boss.currentHp = (_boss.currentHp - 20).clamp(0, _boss.maxHp);
          _shakeController.forward(from: 0);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correct! Attack Blocked!'), backgroundColor: Colors.green),
        );
        // Counter damage
        setState(() {
          _boss.currentHp = (_boss.currentHp - 10).clamp(0, _boss.maxHp);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong! Taking Damage!'), backgroundColor: Colors.red),
      );
      // Threshold failure deals damage too
      _takeDamage(_bossIntent?.damage ?? 10);
    }
    
    // Check for victory/defeat or continue
    if (_boss.currentHp <= 0) {
      setState(() => _phase = TurnPhase.victory);
    } else if (context.read<GameProvider>().playerStats.currentHp <= 0) {
      setState(() => _phase = TurnPhase.defeat);
    } else {
      // If it was a threshold quiz during player turn, return to player turn?
      // Or if it was during boss turn...
      // For simplicity, always return to player turn if it was a threshold interrupt during player turn.
      // But wait, if we interrupted player turn, we should probably let them finish?
      // Actually, let's just start a new player turn to keep it simple, or resume.
      // Resuming is tricky without complex state. Let's just start Player Turn.
      _startPlayerTurn();
    }
  }

  void _executeBossAttack() {
    setState(() {
      _phase = TurnPhase.bossAttack;
    });
    
    // Boss attack animation
    _shakeController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _takeDamage(_bossIntent?.damage ?? 5);
      
      if (context.read<GameProvider>().playerStats.currentHp > 0) {
        Future.delayed(const Duration(seconds: 1), _startPlayerTurn);
      } else {
        setState(() => _phase = TurnPhase.defeat);
      }
    });
  }

  void _takeDamage(int amount) {
    int actualDamage = amount;
    if (_playerBlock > 0) {
      if (_playerBlock >= actualDamage) {
        _playerBlock -= actualDamage;
        actualDamage = 0;
      } else {
        actualDamage -= _playerBlock;
        _playerBlock = 0;
      }
    }
    
    final provider = context.read<GameProvider>();
    provider.playerStats.currentHp = (provider.playerStats.currentHp - actualDamage).clamp(0, provider.playerStats.maxHp);
    provider.notifyListeners(); 
    
    if (actualDamage > 0) {
      // Shake effect
    }
  }

  void _startDialogue() {
    if (_boss.openingDialogue == null || _boss.openingDialogue!.isEmpty) return;
    
    setState(() {
      _showDialogue = true;
      _dialogueIndex = 0;
      _currentDialogueText = '';
    });
    _typewriteDialogue(_boss.openingDialogue![0]);
  }

  void _typewriteDialogue(String text) {
    _typewriterTimer?.cancel();
    _currentDialogueText = '';
    int charIndex = 0;
    
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (charIndex < text.length) {
        setState(() {
          _currentDialogueText += text[charIndex];
        });
        charIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  void _advanceDialogue() {
    if (_typewriterTimer != null && _typewriterTimer!.isActive) {
      // Skip typing and show full text
      _typewriterTimer!.cancel();
      setState(() {
        _currentDialogueText = _boss.openingDialogue![_dialogueIndex];
      });
      return;
    }

    if (_dialogueIndex < _boss.openingDialogue!.length - 1) {
      setState(() {
        _dialogueIndex++;
        _currentDialogueText = '';
      });
      _typewriteDialogue(_boss.openingDialogue![_dialogueIndex]);
    } else {
      setState(() {
        _showDialogue = false;
      });
      _startPlayerTurn(); // Start the fight after dialogue
    }
  }

  Widget _buildDialogueOverlay() {
    if (!_showDialogue) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _advanceDialogue,
      child: Container(
        color: Colors.black54,
        child: Stack(
          children: [
            Positioned(
              top: 150, // Near the boss
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Speech Bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(4, 4), blurRadius: 0),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _boss.name.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Courier', // Monospaced for retro feel
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currentDialogueText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Text('▼', style: TextStyle(fontSize: 20, color: Colors.black)), // Continue indicator
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryFight() {
    // Fase 2: retry con conseguenze — nessun XP guadagnato o perso, solo
    // full-heal (ok da design). Il contatore vite boss resta invariato.
    final provider = context.read<GameProvider>();
    provider.playerStats.currentHp = provider.playerStats.maxHp;
    provider.notifyListeners();

    _initializeFight();
  }

  @override
  Widget build(BuildContext context) {
    final playerStats = context.watch<GameProvider>().playerStats;

    if (_phase == TurnPhase.victory) {
      return _buildVictoryScreen();
    }
    if (_phase == TurnPhase.defeat) {
      return _buildDefeatScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            // --- BACKGROUND IMAGE ---
            if (_boss.backgroundImage != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6, // Dim it slightly so UI pops
                  child: Image.asset(
                    _boss.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Column(
              children: [
                // --- BOSS AREA (Drag Target) ---
                Expanded(
                  flex: 8, // Golden Ratio approx (8:5)
                  child: DragTarget<CardModel>(
                    onWillAcceptWithDetails: (data) => _phase == TurnPhase.player,
                    onAcceptWithDetails: (details) => _playCard(details.data),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? Colors.red.withValues(alpha: 0.1) : null,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Boss HP Bar (Rainbow + Notched)
                              _buildBossHpBar(),
                              const SizedBox(height: 20),
                              
                              // Boss Sprite/Icon (Shake only, Flexible Size)
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(sin(_shakeAnimation.value * pi * 4) * 5, 0),
                                    child: child,
                                  );
                                },
                                child: _boss.imageAsset != null
                                    ? SizedBox(
                                        height: 489,
                                        width: 489,
                                        child: Image.asset(_boss.imageAsset!, fit: BoxFit.contain),
                                      )
                                    : Text(
                                        _boss.icon,
                                        style: const TextStyle(fontSize: 95),
                                      ),
                              ),
                              
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _boss.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_bossBlock > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.shield, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text('$_bossBlock', style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- PLAYER AREA ---
                Expanded(
                  flex: 5, // Golden Ratio approx (8:5)
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // Player Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // HP (Hearts)
                            _buildHeartHpBar(playerStats.currentHp, playerStats.maxHp),
                            
                            // Block
                            if (_playerBlock > 0)
                              Row(
                                children: [
                                  const Icon(Icons.shield, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_playerBlock',
                                    style: const TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            // Energy
                            Row(
                              children: [
                                const Icon(Icons.bolt, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  '$_currentEnergy/$_maxEnergy',
                                  style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        
                        // Hand (Row, Spaced, Drag OR Double Tap)
                        // Scale-down su schermi bassi: a spazio pieno
                        // scala 1.0 (256/160x224 invariati), altrimenti la
                        // mano si restringe senza overflow.
                        Flexible(
                          fit: FlexFit.loose,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxHeight: 256),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double budget =
                                    constraints.maxHeight.isFinite
                                        ? constraints.maxHeight
                                        : 256.0;
                                final double scale =
                                    (budget / 256.0).clamp(0.4, 1.0);
                                final double rowH = 256.0 * scale;
                                final double cardW = 160.0 * scale;
                                final double cardH = 224.0 * scale;
                                final double deckW = 96.0 * scale;
                                final double deckH = 128.0 * scale;
                                return SizedBox(
                                  height: rowH,
                                  child: Row(
                                    children: [
                                      // Hand Cards
                                      Expanded(
                                        child: Center(
                                          child: SingleChildScrollView(
                                            scrollDirection:
                                                Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _hand.map((card) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4),
                                                  child: Tooltip(
                                                    message: card.type ==
                                                            CardType
                                                                .knowledge
                                                        ? '${card.name}\n\n${card.description}\n\n${card.flavourText ?? ""}'
                                                        : card.description,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: card.type ==
                                                              CardType
                                                                  .knowledge
                                                          ? const Color(
                                                                  0xFF1A0B2E)
                                                              .withValues(
                                                                  alpha:
                                                                      0.95)
                                                          : Colors.black87,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                      border:
                                                          Border.all(
                                                        color: card.type ==
                                                                CardType
                                                                    .knowledge
                                                            ? const Color(
                                                                0xFF7C3AED)
                                                            : Colors.grey[
                                                                700]!,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    textStyle:
                                                        TextStyle(
                                                      color: card.type ==
                                                              CardType
                                                                  .knowledge
                                                          ? const Color(
                                                              0xFFE9D5FF)
                                                          : Colors.white,
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                                    preferBelow: false,
                                                    waitDuration:
                                                        const Duration(
                                                            milliseconds:
                                                                500),
                                                    child: Draggable<
                                                        CardModel>(
                                                      data: card,
                                                      feedback:
                                                          SizedBox(
                                                        width: 160,
                                                        height: 224,
                                                        child:
                                                            Transform
                                                                .scale(
                                                          scale:
                                                              1.1,
                                                          child:
                                                              TinyCardWidget(
                                                                  card:
                                                                      card),
                                                        ),
                                                      ),
                                                      childWhenDragging:
                                                          SizedBox(
                                                        width:
                                                            160,
                                                        height:
                                                            224,
                                                        child:
                                                            Opacity(
                                                          opacity:
                                                              0.5,
                                                          child:
                                                              TinyCardWidget(
                                                                  card:
                                                                      card),
                                                        ),
                                                      ),
                                                      child:
                                                          GestureDetector(
                                                        onDoubleTap: () =>
                                                            _playCard(
                                                                card),
                                                        onLongPress: () =>
                                                            _showCardZoom(
                                                                card),
                                                        child:
                                                            SizedBox(
                                                          width:
                                                              cardW,
                                                          height:
                                                              cardH,
                                                          child:
                                                              TinyCardWidget(
                                                                  card:
                                                                      card),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Deck Pile
                                      Container(
                                        width: deckW,
                                        height: deckH,
                                        margin: const EdgeInsets.only(
                                            left: 10),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.brown[800],
                                          borderRadius:
                                              BorderRadius.circular(
                                                  8),
                                          border: Border.all(
                                              color: Colors
                                                  .brown[400]!),
                                        ),
                                        child: Center(
                                          child:
                                              FittedBox(
                                            fit: BoxFit
                                                .scaleDown,
                                            child: Column(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .layers,
                                                    color: Colors
                                                        .white70,
                                                    size:
                                                        28),
                                                Text(
                                                  '${_drawPile.length}',
                                                  style: const TextStyle(
                                                      color: Colors
                                                          .white,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                      fontSize:
                                                          18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // End Turn Button
                        ElevatedButton(
                          onPressed: _phase == TurnPhase.player ? _endTurn : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('END TURN'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- QUIZ OVERLAY (Slay the Spire / Darkest Dungeon Style) ---
            if ((_phase == TurnPhase.bossQuiz || _phase == TurnPhase.thresholdQuiz) && _currentQuestion != null)
              Container(
                color: Colors.black38, 
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 700,
                        // Dialog quiz limitato allo schermo: la lista
                        // risposte scrolla, footer conseguenza pinnato.
                        maxHeight: max(
                            280.0, MediaQuery.of(context).size.height - 100),
                      ),
                      decoration: BoxDecoration(
                        // Dark parchment background with gradient
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1a1410),
                            Color(0xFF2d1f1a),
                            Color(0xFF1a1410),
                          ],
                        ),
                        // Ornate thick border (Slay the Spire style)
                        border: Border.all(
                          color: const Color(0xFFd4af37), // Gold color
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.9),
                            offset: const Offset(0, 8),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                          // Inner glow
                          BoxShadow(
                            color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                            offset: const Offset(0, 0),
                            blurRadius: 12,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Inner ornate border
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF8b6f47).withValues(alpha: 0.6),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header with skull decorations
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            '☠',
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: _isThresholdQuiz ? const Color(0xFFa855f7) : const Color(0xFFef4444),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _isThresholdQuiz ? 'KNOWLEDGE CHECK' : 'DEFEND YOURSELF',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 20,
                                                letterSpacing: 2,
                                                color: _isThresholdQuiz ? const Color(0xFFa855f7) : const Color(0xFFef4444),
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withValues(alpha: 0.8),
                                                    offset: const Offset(2, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Fase 2: quiz senza scadenza (timer 25s rimosso).
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF422006),
                                        border: Border.all(
                                          color: const Color(0xFFd4af37),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Text(
                                        '∞ Senza scadenza',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFfbbf24),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Decorative separator
                                Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFFd4af37).withValues(alpha: 0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Question with dramatic styling
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0a0806).withValues(alpha: 0.6),
                                    border: Border.all(
                                      color: const Color(0xFF8b6f47).withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _currentQuestion!.question,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFf5f5dc), // Beige/parchment color
                                      height: 1.5,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Answers with gothic button style:
                                // area scrollabile (Flexible loose: a spazio
                                // pieno resta min, look invariato) così il
                                // footer conseguenza resta sempre visibile.
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(
                                          _currentQuestion!.options.length,
                                          (index) {
                                  bool isCorrect = index == _currentQuestion!.correctAnswer;
                                  bool showResult = _quizAnswered;
                                  
                                  Color buttonColor;
                                  Color borderColor;
                                  Color textColor;
                                  
                                  if (showResult) {
                                    if (isCorrect) {
                                      buttonColor = const Color(0xFF14532d);
                                      borderColor = const Color(0xFF22c55e);
                                      textColor = const Color(0xFF86efac);
                                    } else {
                                      buttonColor = const Color(0xFF1c1917);
                                      borderColor = const Color(0xFF57534e);
                                      textColor = const Color(0xFF78716c);
                                    }
                                  } else {
                                    buttonColor = const Color(0xFF1e1410);
                                    borderColor = const Color(0xFF8b6f47);
                                    textColor = const Color(0xFFf5f5dc);
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minHeight: 56),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            offset: const Offset(0, 4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _handleQuizAnswer(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: buttonColor,
                                              border: Border.all(
                                                color: borderColor,
                                                width: 2,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: borderColor.withValues(alpha: 0.2),
                                                    border: Border.all(color: borderColor, width: 2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      String.fromCharCode(65 + index), // A, B, C, D
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    _currentQuestion!.options[index],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: textColor,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                if (showResult && isCorrect)
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Color(0xFF22c55e),
                                                    size: 24,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                    }),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                
                                // Boss Intent / Damage Warning
                                if (_bossIntent != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF7f1d1d).withValues(alpha: 0.3),
                                          const Color(0xFF991b1b).withValues(alpha: 0.3),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFef4444),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.dangerous,
                                          color: Color(0xFFfca5a5),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            'FAILURE CONSEQUENCE: ${_bossIntent!.damage} DAMAGE',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFfca5a5),
                                              fontSize: 14,
                                              letterSpacing: 1,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                        if (_bossIntent!.effects != null)
                                          ...(_bossIntent!.effects!.map((e) => Padding(
                                            padding: const EdgeInsets.only(left: 12),
                                            child: Icon(
                                              _getStatusIcon(e.statusEffect),
                                              color: const Color(0xFFfca5a5),
                                              size: 20,
                                            ),
                                          ))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // --- DIALOGUE OVERLAY ---
            _buildDialogueOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBossHpBar() {
    double hpPercent = _boss.currentHp / _boss.maxHp;

    // Fase 2, path live delle soglie: la HUD usa GameConstants 75/50/25
    // (tacche + label qui sotto); le DESCRIZIONI dei poteri di soglia
    // vengono da Boss.thresholdPowers (roadmap_data, es. Syntax Sentinel
    // 50/25). Il modello BossFight (domain, enrageThreshold/isEnraged) è
    // usato solo da test/spec, non dal fight live.
    final thresholdNotes = _boss.thresholdPowers.entries
        .map((e) => '${e.key}%: ${e.value}')
        .join('\n');
    return Column(
      children: [
        Stack(
          children: [
        // 1. Background Gradient (Rainbow)
        Container(
          height: 24,
          width: 300,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue],
              stops: [0.0, 0.33, 0.66, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        
        // 2. Cover (The "Lost HP" part)
        // We align it to the right and give it width proportional to lost HP
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 300 * (1 - hpPercent),
            decoration: BoxDecoration(
              color: Colors.grey[800], // Matches background
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                // We don't round left side so it looks like a straight cut
              ),
            ),
          ),
        ),

        // 3. Threshold Markers (Notches)
        Positioned(left: 300 * 0.5, child: Container(width: 2, height: 24, color: Colors.black)),
        Positioned(left: 300 * 0.25, child: Container(width: 2, height: 24, color: Colors.black)),
        Positioned(left: 300 * 0.75, child: Container(width: 2, height: 24, color: Colors.black)),
        
        // 4. Text
        Positioned.fill(
          child: Center(
            child: Text(
              '${_boss.currentHp}/${_boss.maxHp}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
            ),
          ),
        ),
          ],
        ),
        const SizedBox(height: 4),
        // Soglie quiz live (75/50/25) + poteri di soglia del boss.
        Tooltip(
          message: thresholdNotes.isEmpty ? 'Nessun potere di soglia' : thresholdNotes,
          child: Text(
            'Soglie quiz: ${GameConstants.bossThreshold1} • ${GameConstants.bossThreshold2} • ${GameConstants.bossThreshold3}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
  Widget _buildHeartHpBar(int current, int max) {
    // 1 Heart = 10 HP
    int fullHearts = (current / 10).floor();
    bool hasHalfHeart = (current % 10) >= 5;
    int totalHearts = (max / 10).ceil();
    
    return Wrap(
      spacing: 4,
      children: List.generate(totalHearts, (index) {
        if (index < fullHearts) {
          return const Icon(Icons.favorite, color: Colors.red, size: 24);
        } else if (index == fullHearts && hasHalfHeart) {
          return const Icon(Icons.favorite_border, color: Colors.red, size: 24); 
        } else {
          return const Icon(Icons.favorite_border, color: Colors.grey, size: 24);
        }
      }),
    );
  }
  
  IconData _getStatusIcon(StatusEffect? effect) {
    switch (effect) {
      case StatusEffect.poison: return Icons.bubble_chart;
      case StatusEffect.burn: return Icons.local_fire_department;
      case StatusEffect.freeze: return Icons.ac_unit;
      case StatusEffect.vulnerable: return Icons.broken_image;
      case StatusEffect.weak: return Icons.sentiment_dissatisfied;
      case StatusEffect.strength: return Icons.fitness_center;
      default: return Icons.error_outline;
    }
  }

  Widget _buildVictoryScreen() {
    // Fase 2, US-04 victory: claim 1 reward (via nodo boss) + sblocco
    // capitolo + badge locale, assegnati una sola volta (idempotente in
    // GameProvider.defeatBoss). Post-frame: mai notifyListeners durante build.
    if (!_victoryReported) {
      _victoryReported = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<GameProvider>().defeatBoss(widget.bossId);
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            const Text('VICTORY!', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Badge: ${widget.bossId}  •  +${GameConstants.xpPerBossDefeated} XP',
              style: const TextStyle(color: Colors.amber, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capitolo successivo sbloccato!\nReward del boss nell\u2019inventario.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Journey'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefeatScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text('DEFEAT', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Retry senza XP: nessun XP guadagnato o perso.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryFight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('TRY AGAIN (Full Heal)'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Give Up', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
