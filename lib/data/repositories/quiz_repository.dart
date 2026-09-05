import '../../domain/models/quiz.dart';

abstract class QuizRepository {
  Future<Quiz> getQuizForTopic(String topicId);
  Future<QuizResult> submitQuizAnswers(String quizId, List<int> selectedAnswers);
}

class LocalQuizRepository implements QuizRepository {
  final Map<String, Quiz> _quizzes = {
    'quiz_dart_basics': Quiz(
      id: 'quiz_dart_basics',
      topicId: 'dart_basics',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What is Dart primarily used for?",
          options: [
            "Web development only",
            "Mobile app development with Flutter",
            "Game development",
            "Data science"
          ],
          correctAnswerIndex: 1,
          explanation: "Dart is primarily used for building mobile, web, and desktop apps with Flutter.",
        ),
        Question(
          text: "Which of the following is NOT a valid Dart variable declaration?",
          options: [
            "var name = 'John';",
            "String name = 'John';",
            "name: 'John';",
            "final name = 'John';"
          ],
          correctAnswerIndex: 2,
          explanation: "The syntax 'name: 'John'' is not valid for variable declaration in Dart.",
        ),
        Question(
          text: "What does the 'final' keyword mean in Dart?",
          options: [
            "The variable can be changed later",
            "The variable must be initialized at compile time",
            "The variable can only be set once",
            "The variable is globally accessible"
          ],
          correctAnswerIndex: 2,
          explanation: "'final' means a variable can only be set once and is immutable after initialization.",
        ),
        Question(
          text: "Which type of loop does Dart NOT support?",
          options: [
            "for loop",
            "while loop",
            "do-while loop",
            "foreach loop (but has for-in)"
          ],
          correctAnswerIndex: 3,
          explanation: "Dart has for-in loops for iterating over collections, but not a specific 'foreach' keyword.",
        ),
      ],
    ),
    'quiz_variables': Quiz(
      id: 'quiz_variables',
      topicId: 'variables',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What is the default value of an uninitialized variable in Dart?",
          options: [
            "0",
            "null",
            "undefined",
            "It causes a compile error"
          ],
          correctAnswerIndex: 1,
          explanation: "In Dart, uninitialized variables have an initial value of null.",
        ),
        Question(
          text: "Which keyword is used to declare a compile-time constant?",
          options: [
            "final",
            "const",
            "static",
            "constant"
          ],
          correctAnswerIndex: 1,
          explanation: "'const' is used for compile-time constants, while 'final' is for run-time constants.",
        ),
        Question(
          text: "What is the type of 'var number = 42;' in Dart?",
          options: [
            "dynamic",
            "var",
            "int",
            "Object"
          ],
          correctAnswerIndex: 2,
          explanation: "The type is inferred as 'int' because 42 is an integer literal.",
        ),
      ],
    ),
    'quiz_functions': Quiz(
      id: 'quiz_functions',
      topicId: 'functions',
      passingThreshold: 80,
      questions: [
        Question(
          text: "Which syntax is correct for a function that returns nothing?",
          options: [
            "void functionName() {}",
            "functionName(): void {}",
            "functionName() void {}",
            "None of the above"
          ],
          correctAnswerIndex: 0,
          explanation: "In Dart, 'void' is placed before the function name to indicate no return value.",
        ),
        Question(
          text: "What is a fat arrow (=>) used for in Dart functions?",
          options: [
            "For asynchronous functions",
            "For function expressions with a single expression",
            "For generator functions",
            "For factory constructors"
          ],
          correctAnswerIndex: 1,
          explanation: "The fat arrow syntax is shorthand for functions that contain just one expression.",
        ),
        Question(
          text: "Which is NOT a valid function parameter type in Dart?",
          options: [
            "Required positional",
            "Optional positional",
            "Required named",
            "Optional named (all are valid)"
          ],
          correctAnswerIndex: 3,
          explanation: "All these parameter types are valid in Dart functions.",
        ),
        Question(
          text: "What does the 'required' keyword do in Dart?",
          options: [
            "Makes a parameter non-nullable",
            "Makes a named parameter mandatory",
            "Forces immediate initialization",
            "Both 1 and 2"
          ],
          correctAnswerIndex: 3,
          explanation: "'required' makes a named parameter mandatory and non-nullable.",
        ),
      ],
    ),
  };

  @override
  Future<Quiz> getQuizForTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    final quiz = _quizzes['quiz_$topicId'];
    if (quiz == null) {
      throw Exception('Quiz not found for topic: $topicId');
    }
    return quiz;
  }

  @override
  Future<QuizResult> submitQuizAnswers(String quizId, List<int> selectedAnswers) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing
    
    final quiz = _quizzes[quizId];
    if (quiz == null) {
      throw Exception('Quiz not found: $quizId');
    }

    int correctAnswers = 0;
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (i < quiz.questions.length && selectedAnswers[i] == quiz.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final percentage = (correctAnswers / quiz.questions.length) * 100;
    final passed = percentage >= quiz.passingThreshold;

    return QuizResult(
      quizId: quizId,
      correctAnswers: correctAnswers,
      totalQuestions: quiz.questions.length,
      percentage: percentage,
      passed: passed,
      completedAt: DateTime.now(),
    );
  }
}
