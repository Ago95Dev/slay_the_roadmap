/// Quiz questions widget.
/// UI widget that renders quiz questions and choice controls used in the quiz screen.

import 'package:flutter/material.dart';
import '../../../domain/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizQuestions extends StatefulWidget {
  final Quiz quiz;

  const QuizQuestions({super.key, required this.quiz});

  @override
  _QuizQuestionsState createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  final QuizRepository _quizRepository = LocalQuizRepository();

  void _submitAnswer(int selectedIndex) {
    setState(() {
      widget.quiz.questions[_currentQuestionIndex].selectedAnswer = 
        widget.quiz.questions[_currentQuestionIndex].options[selectedIndex];
      
      if (selectedIndex == widget.quiz.questions[_currentQuestionIndex].correctAnswerIndex) {
        _correctAnswers++;
      }
    });

    _showAnswerFeedback(selectedIndex);

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  void _showAnswerFeedback(int selectedIndex) {
    final isCorrect = selectedIndex == 
      widget.quiz.questions[_currentQuestionIndex].correctAnswerIndex;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Corretto! 🎉' : 'Sbagliato! ❌'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _finishQuiz() async {
    final percentage = (_correctAnswers / widget.quiz.questions.length) * 100;
    final passed = await _quizRepository.submitQuizResults(
      widget.quiz.id, 
      _correctAnswers
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizResultDialog(
        passed: passed,
        correctAnswers: _correctAnswers,
        totalQuestions: widget.quiz.questions.length,
        percentage: percentage,
        onContinue: () {
          Navigator.of(context).pop();
          if (passed) {
            _navigateAfterSuccess();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _navigateAfterSuccess() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          ),
          const SizedBox(height: 16),
          Text(
            'Domanda ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(question.options[index]),
                    onTap: () => _submitAnswer(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultDialog extends StatelessWidget {
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final VoidCallback onContinue;

  const QuizResultDialog({
    super.key,
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(passed ? 'Complimenti! 🎉' : 'Riprova! 💪'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hai risposto correttamente a $correctAnswers su $totalQuestions domande',
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            passed 
              ? 'Hai superato il quiz!'
              : 'Devi raggiungere almeno l\'80% per superare il quiz',
            style: TextStyle(
              color: passed ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onContinue,
          child: const Text('Continua'),
        ),
      ],
    );
  }
}
