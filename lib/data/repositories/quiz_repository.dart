import '../../domain/models/quiz.dart';

abstract class QuizRepository {
  Future<Quiz> getQuizForTopic(String topicId);
  Future<bool> submitQuizResults(String quizId, int correctAnswers);
}

class LocalQuizRepository implements QuizRepository {
  @override
  Future<Quiz> getQuizForTopic(String topicId) async {
    // Quiz mock in base al topic
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
      id: 'quiz_$topicId',
      topicId: topicId,
      questions: questions,
      passingThreshold: 80,
    );
  }

  @override
  Future<bool> submitQuizResults(String quizId, int correctAnswers) async {
    final quiz = await getQuizForTopic(quizId.replaceFirst('quiz_', ''));
    final percentage = (correctAnswers / quiz.questions.length) * 100;
    return percentage >= quiz.passingThreshold;
  }
}
