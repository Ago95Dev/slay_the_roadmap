import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/quiz_view_model.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const QuizScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizViewModel(LocalQuizRepository());
    _viewModel.loadQuiz(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz: ${widget.topicTitle}'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<QuizViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.currentQuiz == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null && viewModel.currentQuiz == null) {
              return _buildErrorView(viewModel);
            }

            if (viewModel.isQuizComplete) {
              return _buildQuizResult(viewModel);
            }

            return _buildQuizQuestions(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(QuizViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Errore nel caricamento del quiz',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.retryLoading,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizQuestions(QuizViewModel viewModel) {
    final quiz = viewModel.currentQuiz!;
    final currentQuestion = quiz.questions[viewModel.currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (viewModel.currentQuestionIndex + 1) / quiz.questions.length,
            backgroundColor: Colors.grey[300],
            color: Colors.purple,
          ),
          const SizedBox(height: 16),

          // Question counter
          Text(
            'Domanda ${viewModel.currentQuestionIndex + 1} di ${quiz.questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Question card
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentQuestion.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion.options.length,
              itemBuilder: (context, index) {
                final isSelected = viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isSelected ? Colors.purple[50] : null,
                  child: ListTile(
                    title: Text(currentQuestion.options[index]),
                    leading: Radio<int>(
                      value: index,
                      groupValue: viewModel.selectedAnswers[viewModel.currentQuestionIndex],
                      onChanged: (value) {
                        viewModel.selectAnswer(value!);
                      },
                    ),
                    onTap: () {
                      viewModel.selectAnswer(index);
                    },
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: viewModel.currentQuestionIndex > 0 
                      ? viewModel.previousQuestion 
                      : null,
                  child: const Text('Indietro'),
                ),
                ElevatedButton(
                  onPressed: viewModel.selectedAnswers[viewModel.currentQuestionIndex] != null
                      ? () {
                          if (viewModel.isLastQuestion) {
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
                  child: Text(viewModel.isLastQuestion ? 'Concludi Quiz' : 'Avanti'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResult(QuizViewModel viewModel) {
    final result = viewModel.quizResult!;
    final passed = result.passed;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            passed ? Icons.celebration : Icons.sentiment_dissatisfied,
            size: 80,
            color: passed ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            passed ? 'Quiz Superato! 🎉' : 'Quiz Non Superato',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: passed ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hai risposto correttamente a ${result.correctAnswers} '
            'su ${result.totalQuestions} domande',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${result.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          if (!passed)
            Column(
              children: [
                Text(
                  'Per superare il quiz è necessario almeno l\'${viewModel.currentQuiz?.passingThreshold}%',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!passed)
                ElevatedButton(
                  onPressed: viewModel.restartQuiz,
                  child: const Text('Riprova'),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(passed ? 'Continua' : 'Torna alla Mappa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
