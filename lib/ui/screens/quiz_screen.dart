import 'package:flutter/material.dart';
import '../../domain/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import '../widgets/quiz/quiz_questions.dart';

class QuizScreen extends StatefulWidget {
  final String topicId;

  const QuizScreen({super.key, required this.topicId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Quiz> _quizFuture;
  final QuizRepository _quizRepository = LocalQuizRepository();

  @override
  void initState() {
    super.initState();
    _quizFuture = _quizRepository.getQuizForTopic(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Quiz>(
        future: _quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
