import '../models/types.dart';

// Topics Data
final List<Topic> topicsData = [
  // CHAPTER 1: Dart Basics
  Topic(
    id: 'variables-types',
    title: 'Variables & Types',
    description: 'In Flutter, variables are used to store values. There are three types of variables in Flutter namely local, global and instance variables. Variables in Flutter can store values of different data types, such as numbers, strings, booleans, and more.',
    chapterId: 'chapter-1',
    type: TopicType.core,
    difficulty: 'easy',
    resources: [
      'https://dart.dev/guides/language/language-tour#variables',
      'https://dart.dev/guides/language/language-tour#built-in-types',
    ],
    order: 1,
  ),
  Topic(
    id: 'operators',
    title: 'Operators',
    description: 'Master Dart operators including arithmetic, relational, and logical',
    chapterId: 'chapter-1',
    type: TopicType.core,
    difficulty: 'easy',
    resources: [
      'https://dart.dev/guides/language/language-tour#operators',
    ],
    order: 2,
  ),
  Topic(
    id: 'null-safety',
    title: 'Null Safety',
    description: 'Understand Dart\'s sound null safety system',
    chapterId: 'chapter-1',
    type: TopicType.elective,
    difficulty: 'medium',
    resources: [
      'https://dart.dev/null-safety',
    ],
    order: 3,
  ),

  // CHAPTER 2: Control Flow & Functions
  Topic(
    id: 'conditionals',
    title: 'Conditionals',
    description: 'Learn if-else statements and switch cases',
    chapterId: 'chapter-2',
    type: TopicType.core,
    difficulty: 'easy',
    resources: [
      'https://dart.dev/guides/language/language-tour#if-and-else',
    ],
    order: 1,
  ),
  Topic(
    id: 'loops',
    title: 'Loops',
    description: 'Master for, while, and do-while loops',
    chapterId: 'chapter-2',
    type: TopicType.core,
    difficulty: 'easy',
    resources: [
      'https://dart.dev/guides/language/language-tour#for-loops',
    ],
    order: 2,
  ),
  Topic(
    id: 'functions',
    title: 'Functions',
    description: 'Create and use functions with parameters and return values',
    chapterId: 'chapter-2',
    type: TopicType.core,
    difficulty: 'medium',
    resources: [
      'https://dart.dev/guides/language/language-tour#functions',
    ],
    order: 3,
  ),
  Topic(
    id: 'collections',
    title: 'Collections',
    description: 'Work with Lists, Sets, and Maps',
    chapterId: 'chapter-2',
    type: TopicType.core,
    difficulty: 'medium',
    resources: [
      'https://dart.dev/guides/language/language-tour#lists',
    ],
    order: 4,
  ),

  // CHAPTER 3: OOP & Advanced
  Topic(
    id: 'classes',
    title: 'Classes & Objects',
    description: 'Understand object-oriented programming in Dart',
    chapterId: 'chapter-3',
    type: TopicType.core,
    difficulty: 'medium',
    resources: [
      'https://dart.dev/guides/language/language-tour#classes',
    ],
    order: 1,
  ),
  Topic(
    id: 'inheritance',
    title: 'Inheritance & Mixins',
    description: 'Learn about class inheritance and mixins',
    chapterId: 'chapter-3',
    type: TopicType.core,
    difficulty: 'hard',
    resources: [
      'https://dart.dev/guides/language/language-tour#extending-a-class',
    ],
    order: 2,
  ),
  Topic(
    id: 'async',
    title: 'Async & Futures',
    description: 'Master asynchronous programming with Future and async/await',
    chapterId: 'chapter-3',
    type: TopicType.elective,
    difficulty: 'hard',
    resources: [
      'https://dart.dev/codelabs/async-await',
    ],
    order: 3,
  ),
];

// Quizzes Data
final List<Quiz> quizzesData = [
  // Variables & Types Quiz
  Quiz(
    topicId: 'variables-types',
    questions: [
      QuizQuestion(
        question: 'Which keyword is used to declare a variable that can be reassigned?',
        options: ['var', 'final', 'const', 'let'],
        correctAnswer: 0,
        explanation: 'var is used for variables that can be reassigned. Use final for variables that can only be set once.',
      ),
      QuizQuestion(
        question: 'What is the default value of an uninitialized variable in Dart?',
        options: ['0', 'null', 'undefined', 'false'],
        correctAnswer: 1,
        explanation: 'All uninitialized variables in Dart have an initial value of null (with null safety, you must explicitly allow null).',
      ),
      QuizQuestion(
        question: 'Which of these is NOT a built-in type in Dart?',
        options: ['int', 'double', 'String', 'character'],
        correctAnswer: 3,
        explanation: 'Dart does not have a character type. Use String for text.',
      ),
      QuizQuestion(
        question: 'How do you declare a constant in Dart?',
        options: ['var x = 10', 'final x = 10', 'const x = 10', 'Both b and c'],
        correctAnswer: 3,
        explanation: 'Both final and const can be used for constants, but const is compile-time constant.',
      ),
      QuizQuestion(
        question: 'What is the type of this variable: var x = 10.5;',
        options: ['int', 'double', 'num', 'float'],
        correctAnswer: 1,
        explanation: 'Dart infers the type as double because of the decimal point.',
      ),
    ],
    passingScore: 80,
    timeLimit: 300,
  ),

  // Operators Quiz
  Quiz(
    topicId: 'operators',
    questions: [
      QuizQuestion(
        question: 'What does the ~/ operator do in Dart?',
        options: ['Bitwise NOT', 'Integer division', 'Modulo', 'XOR'],
        correctAnswer: 1,
        explanation: '~/ performs integer division, returning only the integer part.',
      ),
      QuizQuestion(
        question: 'What is the result of: 5 % 2',
        options: ['2', '2.5', '1', '0'],
        correctAnswer: 2,
        explanation: 'The modulo operator % returns the remainder of division: 5 divided by 2 is 2 with remainder 1.',
      ),
      QuizQuestion(
        question: 'Which operator is used for null-aware access?',
        options: ['?.', '!.', '?.?', '?:'],
        correctAnswer: 0,
        explanation: '?. is the null-aware operator. It returns null if the object is null.',
      ),
      QuizQuestion(
        question: 'What does the ?? operator do?',
        options: ['Null check', 'Null coalescing', 'Type cast', 'Equality check'],
        correctAnswer: 1,
        explanation: '?? is the null-coalescing operator. It returns the right operand if the left is null.',
      ),
      QuizQuestion(
        question: 'What is the result of: true && false',
        options: ['true', 'false', 'null', 'error'],
        correctAnswer: 1,
        explanation: 'The logical AND operator && returns true only if both operands are true.',
      ),
    ],
    passingScore: 80,
    timeLimit: 300,
  ),

  // Functions Quiz
  Quiz(
    topicId: 'functions',
    questions: [
      QuizQuestion(
        question: 'How do you define an optional named parameter in Dart?',
        options: [
          'void func(int x)',
          'void func({int x})',
          'void func([int x])',
          'void func(int? x)',
        ],
        correctAnswer: 1,
        explanation: 'Curly braces {} define named optional parameters.',
      ),
      QuizQuestion(
        question: 'What is the shorthand syntax for a simple function?',
        options: [
          'int add(a, b) { return a + b; }',
          'int add(a, b) => a + b;',
          'int add(a, b) -> a + b;',
          'int add(a, b) = a + b;',
        ],
        correctAnswer: 1,
        explanation: 'The => arrow syntax is shorthand for single-expression functions.',
      ),
      QuizQuestion(
        question: 'How do you specify a default value for a named parameter?',
        options: [
          'void func({int x = 10})',
          'void func({int x: 10})',
          'void func({int x || 10})',
          'void func({default int x = 10})',
        ],
        correctAnswer: 0,
        explanation: 'Use = to specify default values for named parameters.',
      ),
      QuizQuestion(
        question: 'Can functions be assigned to variables in Dart?',
        options: ['Yes', 'No', 'Only arrow functions', 'Only named functions'],
        correctAnswer: 0,
        explanation: 'Dart treats functions as first-class objects, so they can be assigned to variables.',
      ),
      QuizQuestion(
        question: 'What is a closure in Dart?',
        options: [
          'A function that closes the program',
          'A function that captures variables from its scope',
          'A sealed class',
          'A private function',
        ],
        correctAnswer: 1,
        explanation: 'A closure is a function that can access variables from its enclosing scope.',
      ),
    ],
    passingScore: 80,
    timeLimit: 300,
  ),

  // Classes Quiz
  Quiz(
    topicId: 'classes',
    questions: [
      QuizQuestion(
        question: 'How do you create a constructor in Dart?',
        options: [
          'constructor ClassName() {}',
          'ClassName() {}',
          'init() {}',
          'new ClassName() {}',
        ],
        correctAnswer: 1,
        explanation: 'Constructors in Dart have the same name as the class.',
      ),
      QuizQuestion(
        question: 'What is a named constructor?',
        options: [
          'A constructor with a name',
          'A constructor with parameters',
          'An additional constructor with a custom name',
          'A private constructor',
        ],
        correctAnswer: 2,
        explanation: 'Named constructors allow you to create multiple constructors: ClassName.namedConstructor()',
      ),
      QuizQuestion(
        question: 'How do you make a class property private in Dart?',
        options: [
          'private int _value;',
          'int _value;',
          'int #value;',
          'int -value;',
        ],
        correctAnswer: 1,
        explanation: 'In Dart, identifiers starting with underscore _ are private to the library.',
      ),
      QuizQuestion(
        question: 'What does the @override annotation do?',
        options: [
          'Makes a method required',
          'Indicates a method overrides a parent method',
          'Makes a method private',
          'Makes a method static',
        ],
        correctAnswer: 1,
        explanation: '@override helps catch errors when you intend to override a superclass method.',
      ),
      QuizQuestion(
        question: 'What is the purpose of the factory keyword?',
        options: [
          'Creates multiple instances',
          'Creates design patterns',
          'Returns a cached instance or subclass',
          'Makes a class abstract',
        ],
        correctAnswer: 2,
        explanation: 'Factory constructors can return cached instances or instances of subclasses.',
      ),
    ],
    passingScore: 80,
    timeLimit: 300,
  ),
];

// Helper function to get quiz by topic ID
Quiz? getQuizByTopicId(String topicId) {
  try {
    return quizzesData.firstWhere((quiz) => quiz.topicId == topicId);
  } catch (e) {
    return null;
  }
}

// Helper function to get topics by chapter
List<Topic> getTopicsByChapter(String chapterId) {
  return topicsData.where((topic) => topic.chapterId == chapterId).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
}
