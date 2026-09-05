import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/boss_fight.dart';
import '../../domain/models/reward.dart';
import '../view_models/boss_fight_view_model.dart';
import '../view_models/quiz_view_model.dart';
import '../widgets/boss/boss_health_bar.dart';
import '../widgets/boss/player_health_bar.dart';
import '../widgets/boss/action_card.dart';
import '../../data/repositories/quiz_repository.dart';

class BossFightActiveScreen extends StatefulWidget {
  final String bossId;

  const BossFightActiveScreen({
    super.key,
    required this.bossId,
  });

  @override
  State<BossFightActiveScreen> createState() => _BossFightActiveScreenState();
}

class _BossFightActiveScreenState extends State<BossFightActiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BossFightViewModel>().loadBoss(widget.bossId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Boss Fight',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BossFightViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.currentBoss == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null && viewModel.currentBoss == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final boss = viewModel.currentBoss!;

          // Show battle start screen
          if (boss.state == BossFightState.notStarted) {
            return _buildStartScreen(context, viewModel, boss);
          }

          // Show victory screen
          if (boss.state == BossFightState.victory) {
            return _buildVictoryScreen(context, viewModel, boss);
          }

          // Show defeat screen
          if (boss.state == BossFightState.defeat) {
            return _buildDefeatScreen(context, viewModel, boss);
          }

          // Show quiz if active
          if (viewModel.isQuizActive && viewModel.currentQuiz != null) {
            return _buildQuizView(context, viewModel);
          }

          // Show battle interface
          return _buildBattleInterface(context, viewModel, boss);
        },
      ),
    );
  }

  Widget _buildStartScreen(
    BuildContext context,
    BossFightViewModel viewModel,
    BossFight boss,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_martial_arts,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              boss.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'HP: ${boss.maxHp}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            const Text(
              'Defeat this boss to earn powerful rewards!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => viewModel.startBattle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'START BATTLE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleInterface(
    BuildContext context,
    BossFightViewModel viewModel,
    BossFight boss,
  ) {
    final bool isPlayerTurn = boss.state == BossFightState.playerTurn;

    return Column(
      children: [
        // Boss section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red.withValues(alpha: 0.1),
          child: Column(
            children: [
              BossHealthBar(
                currentHp: boss.currentHp,
                maxHp: boss.maxHp,
                bossName: boss.name,
              ),
              const SizedBox(height: 12),
              const Icon(Icons.sports_martial_arts, size: 64),
            ],
          ),
        ),

        // Combat log 
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                viewModel.combatLog,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),

        // Player section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withValues(alpha: 0.1),
          child: Column(
            children: [
              PlayerHealthBar(
                currentHp: boss.currentPlayerHp,
                maxHp: boss.maxPlayerHp,
              ),
              const SizedBox(height: 16),

              // Action buttons
              if (isPlayerTurn) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => viewModel.startQuiz(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.quiz),
                        label: const Text('Answer Quiz'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: boss.playerDeck.isNotEmpty
                            ? () => _showDeckDialog(context, viewModel, boss)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.style),
                        label: const Text('Use Card'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text(
                      'Boss is thinking...',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    BossFightViewModel viewModel,
  ) {
    final quiz = viewModel.currentQuiz!;
    final currentQuestion = quiz.questions[viewModel.currentQuestionIndex];
    final isLastQuestion = viewModel.currentQuestionIndex == quiz.questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (viewModel.currentQuestionIndex + 1) / quiz.questions.length,
            backgroundColor: Colors.grey[300],
            color: Colors.purple,
          ),
          const SizedBox(height: 16),

          Text(
            'Question ${viewModel.currentQuestionIndex + 1} of ${quiz.questions.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Question
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion.options.length,
              itemBuilder: (context, index) {
                final isSelected =
                    viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isSelected ? Colors.purple[50] : null,
                  child: ListTile(
                    title: Text(currentQuestion.options[index]),
                    leading: Radio<int>(
                      value: index,
                      groupValue: viewModel.selectedAnswers[viewModel.currentQuestionIndex],
                      onChanged: (value) {
                        viewModel.selectQuizAnswer(value!);
                      },
                    ),
                    onTap: () {
                      viewModel.selectQuizAnswer(index);
                    },
                  ),
                );
              },
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: null, // Back disabled for boss fights
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: viewModel.selectedAnswers[viewModel.currentQuestionIndex] != null
                      ? () {
                          if (isLastQuestion) {
                            viewModel.submitQuiz();
                          } else {
                            viewModel.nextQuestion();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen(
    BuildContext context,
    BossFightViewModel viewModel,
    BossFight boss,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'VICTORY!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You defeated ${boss.name}!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Show reward selection screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'CLAIM REWARDS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefeatScreen(
    BuildContext context,
    BossFightViewModel viewModel,
    BossFight boss,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'DEFEATED',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${boss.name} was too powerful...',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => viewModel.retryBattle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('TRY AGAIN'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('GO BACK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeckDialog(
    BuildContext context,
    BossFightViewModel viewModel,
    BossFight boss,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use a Card'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: boss.playerDeck.length,
            itemBuilder: (context, index) {
              final card = boss.playerDeck[index];
              return ActionCard(
                reward: card,
                onTap: () {
                  Navigator.pop(context);
                  viewModel.useCard(card);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
