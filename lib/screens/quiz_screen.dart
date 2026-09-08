import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/types.dart';
import '../providers/game_provider.dart';
import '../widgets/compact_stats_bar.dart';
import 'reward_selection_screen.dart';
import '../data/knowledge_cards_data.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String topicId;
  final String topicTitle;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _showExplanation = false;
  final List<int> _userAnswers = [];

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.quiz.questions.length - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          // Compact stats bar
          const CompactStatsBar(),
          
          // Quiz content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question counter
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question text
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _currentQuestion.question,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        return _buildAnswerOption(index, theme);
                      },
                    ),
                  ),

                  // Explanation panel (animated slide-in)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _showExplanation && _currentQuestion.explanation != null ? null : 0,
                    child: _showExplanation && _currentQuestion.explanation != null
                        ? Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedAnswer == _currentQuestion.correctAnswer
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedAnswer == _currentQuestion.correctAnswer
                                    ? Colors.green
                                    : Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _selectedAnswer == _currentQuestion.correctAnswer
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      color: _selectedAnswer == _currentQuestion.correctAnswer
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Explanation',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedAnswer == _currentQuestion.correctAnswer
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _currentQuestion.explanation ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Navigation button
                  if (_hasAnswered)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FilledButton(
                        onPressed: _nextQuestion,
                        child: Text(_isLastQuestion ? 'Finish Quiz' : 'Next Question'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, ThemeData theme) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == _currentQuestion.correctAnswer;
    
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (_hasAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primaryContainer;
      borderColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: _hasAnswered ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor ?? Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _currentQuestion.options[index],
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      _userAnswers.add(index);

      if (index == _currentQuestion.correctAnswer) {
        _score++;
      }
    });

    // Show explanation after a brief moment (inline, not popup)
    if (_currentQuestion.explanation != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _showExplanation = true;
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _showExplanation = false; // Reset explanation for next question
      });
    }
  }

  void _finishQuiz() {
    final percentage = (_score / widget.quiz.questions.length * 100).round();
    final passed = percentage >= widget.quiz.passingScore;

    // Update game provider
    final gameProvider = context.read<GameProvider>();
    gameProvider.completeTopicQuiz(widget.topicId, _score, passed);

    // Award knowledge card if quiz passed
    if (passed) {
      final knowledgeCard = getKnowledgeCardByTopicId(widget.topicId);
      if (knowledgeCard != null) {
        gameProvider.addCardToInventory(knowledgeCard.id);
      }
    }

    // Get rewards for this topic (Fase 2, US-03: enforce 1/topic — se la
    // reward risulta già in claimedRewardTopics si blocca il re-claim con
    // messaggio, la preview resta descrittiva).
    final topicNode = gameProvider.roadmapNodes.where((node) =>
      node.type == RoadmapNodeType.topic && node.topicId == widget.topicId
    ).firstOrNull;

    final alreadyClaimed = gameProvider.isRewardClaimed(widget.topicId);
    final hasRewards =
        topicNode != null && topicNode.rewards.isNotEmpty && passed && !alreadyClaimed;

    // Show results
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.error_outline,
              color: passed ? Colors.amber : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(passed ? 'Quiz Passed! 🎉' : 'Quiz Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $_score / ${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Percentage: $percentage%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Passing Score: ${widget.quiz.passingScore}%',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (passed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasRewards
                            ? 'Topic completed! Choose your reward.'
                            : alreadyClaimed
                                ? 'Reward già riscattata per questo topic (1/topic).'
                                : 'Topic completed! Next topics unlocked.',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'Study the topic and try again!',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              if (passed) {
                if (hasRewards) {
                  // Navigate to reward selection
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardSelectionScreen(
                        topicId: widget.topicId,
                        topicTitle: widget.topicTitle,
                        rewards: topicNode.rewards,
                      ),
                    ),
                  );
                } else {
                  // No rewards, just close quiz screen
                  Navigator.pop(context); // Close quiz screen, return to roadmap
                }
              } else {
                // Failed - just close quiz screen
                Navigator.pop(context); // Close quiz screen, return to roadmap
              }
            },
            child: Text(passed ? (hasRewards ? 'Claim Reward!' : 'Done') : 'Try Again'),
          ),
        ],
      ),
    );
  }
}
