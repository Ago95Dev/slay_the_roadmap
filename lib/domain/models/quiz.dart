/// Quiz domain model.
/// Models quiz structure: questions, choices, correct answers and metadata.
class Quiz {
  final String id;
  final String topicId;
  final List<Question> questions;
  final int passingThreshold;

  Quiz({
    required this.id,
    required this.topicId,
    required this.questions,
    this.passingThreshold = 80,
  });
}

/// Question domain model.
/// Models a single question with text, options, correct answer index and selected answer.
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  String? selectedAnswer;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedAnswer,
  });
}
