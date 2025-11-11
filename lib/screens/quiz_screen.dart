import 'package:flutter/material.dart';
import '../models/roadmap_models.dart';
import '../services/roadmap_service.dart';

/// Quiz screen.
/// UI for taking quizzes: shows questions, accepts answers and displays results.
class QuizScreen extends StatefulWidget {
  final String topicId;

  const QuizScreen({super.key, required this.topicId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Quiz> _quizFuture;
  final RoadmapService _roadmapService = RoadmapService();

  @override
  void initState() {
    super.initState();
    _quizFuture = _getQuizForTopic();
  }

  Future<Quiz> _getQuizForTopic() async {
    // Quiz mock per il topic
    final questions = [
      Question(
        text: "What is the main purpose of Dart's 'final' keyword?",
        options: [
          "To declare a constant variable",
          "To make a variable mutable", 
          "To create a singleton",
          "To define a class constructor"
        ],
        correctAnswerIndex: 0,
      ),
      Question(
        text: "Which widget is used for responsive layout in Flutter?",
        options: [
          "Container",
          "Row",
          "Column", 
          "All of the above"
        ],
        correctAnswerIndex: 3,
      ),
      Question(
        text: "What does the 'async' keyword do in Dart?",
        options: [
          "Makes a function synchronous",
          "Enables asynchronous operations",
          "Creates a new thread",
          "Optimizes performance"
        ],
        correctAnswerIndex: 1,
      ),
    ];

    return Quiz(
      id: 'quiz_${widget.topicId}',
      topicId: widget.topicId,
      questions: questions,
      passingThreshold: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Quiz>(
        future: _quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return QuizQuestions(quiz: snapshot.data!);
        },
      ),
    );
  }
}

class QuizQuestions extends StatefulWidget {
  final Quiz quiz;

  const QuizQuestions({super.key, required this.quiz});

  @override
  _QuizQuestionsState createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;

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

  void _finishQuiz() {
    final percentage = (_correctAnswers / widget.quiz.questions.length) * 100;
    final passed = percentage >= widget.quiz.passingThreshold;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(passed ? 'Complimenti! 🎉' : 'Riprova! 💪'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hai risposto correttamente a $_correctAnswers su ${widget.quiz.questions.length} domande',
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
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
            onPressed: () {
              Navigator.of(context).pop();
              if (passed) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Text('Continua'),
          ),
        ],
      ),
    );
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
          SizedBox(height: 16),
          Text(
            'Domanda ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 24),
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
