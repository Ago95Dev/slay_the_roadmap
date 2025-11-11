import 'package:equatable/equatable.dart';

class Quiz extends Equatable {
  final String id;
  final String topicId;
  final List<Question> questions;
  final int passingThreshold; // 80%

  const Quiz({
    required this.id,
    required this.topicId,
    required this.questions,
    this.passingThreshold = 80,
  });

  int get totalQuestions => questions.length;
  int get requiredCorrectAnswers => (totalQuestions * passingThreshold / 100).ceil();

  @override
  List<Object?> get props => [id, topicId, questions, passingThreshold];
}

class Question extends Equatable {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;

  @override
  List<Object?> get props => [text, options, correctAnswerIndex, explanation];
}

class QuizResult extends Equatable {
  final String quizId;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final DateTime completedAt;

  const QuizResult({
    required this.quizId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
    quizId,
    correctAnswers,
    totalQuestions,
    percentage,
    passed,
    completedAt,
  ];
}
