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
        Question(
          text: "How do you run a Dart program from the command line?",
          options: [
            "dart run <file.dart>",
            "dart execute <file.dart>",
            "dart start <file.dart>",
            "dart compile <file.dart>"
          ],
          correctAnswerIndex: 0,
          explanation: "'dart run <file.dart>' executes a Dart program directly.",
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
        Question(
          text: "What is the difference between 'final' and 'const'?",
          options: [
            "There is no difference",
            "'const' is compile-time, 'final' is set once at run-time",
            "'final' is compile-time, 'const' is set once at run-time",
            "Both must be initialized at compile time"
          ],
          correctAnswerIndex: 1,
          explanation: "'const' values must be known at compile time; 'final' values are assigned once at run-time.",
        ),
        Question(
          text: "Which of these is a valid 'double' literal in Dart?",
          options: [
            "42",
            "'42.0'",
            "42.0",
            "Double(42)"
          ],
          correctAnswerIndex: 2,
          explanation: "42.0 is a double literal; 42 alone is inferred as int.",
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
        Question(
          text: "How do you declare an optional positional parameter?",
          options: [
            "{int? x}",
            "[int? x]",
            "(int? x)?",
            "<int? x>"
          ],
          correctAnswerIndex: 1,
          explanation: "Optional positional parameters are wrapped in square brackets: void f([int? x]) {}.",
        ),
      ],
    ),
    'quiz_control_flow': Quiz(
      id: 'quiz_control_flow',
      topicId: 'control_flow',
      passingThreshold: 80,
      questions: [
        Question(
          text: "Which statement executes a block only when a condition is true?",
          options: [
            "for",
            "if",
            "switch",
            "while"
          ],
          correctAnswerIndex: 1,
          explanation: "'if' executes its block only when the condition evaluates to true.",
        ),
        Question(
          text: "What does the '??' operator do in Dart?",
          options: [
            "Null-aware: returns the left side unless it is null",
            "Compares two values for equality",
            "Declares a nullable variable",
            "Throws if the value is null"
          ],
          correctAnswerIndex: 0,
          explanation: "'a ?? b' evaluates to 'a' unless 'a' is null, in which case it evaluates to 'b'.",
        ),
        Question(
          text: "Which loop always executes its body at least once?",
          options: [
            "for",
            "while",
            "do-while",
            "for-in"
          ],
          correctAnswerIndex: 2,
          explanation: "do-while checks the condition after the body, so it runs at least once.",
        ),
        Question(
          text: "How do you skip to the next iteration of a loop?",
          options: [
            "break",
            "continue",
            "return",
            "skip"
          ],
          correctAnswerIndex: 1,
          explanation: "'continue' jumps to the next iteration; 'break' exits the loop entirely.",
        ),
        Question(
          text: "What is a collection-for in Dart?",
          options: [
            "A for loop that iterates collections only",
            "A for element inside a list/set/map literal",
            "A foreach method on Iterable",
            "A deprecated loop syntax"
          ],
          correctAnswerIndex: 1,
          explanation: "Collection-for lets you build collections with for elements: [for (var i in list) i * 2].",
        ),
      ],
    ),
    'quiz_oop': Quiz(
      id: 'quiz_oop',
      topicId: 'oop_dart',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What are the four pillars of OOP?",
          options: [
            "Classes, objects, methods, fields",
            "Encapsulation, inheritance, polymorphism, abstraction",
            "Variables, functions, loops, conditions",
            "Public, private, protected, static"
          ],
          correctAnswerIndex: 1,
          explanation: "The four pillars are encapsulation, inheritance, polymorphism, and abstraction.",
        ),
        Question(
          text: "How do you make a field private to its library in Dart?",
          options: [
            "With the 'private' keyword",
            "By prefixing the name with an underscore (_)",
            "By declaring it inside the constructor",
            "Dart has no privacy mechanism"
          ],
          correctAnswerIndex: 1,
          explanation: "Identifiers starting with '_' are library-private in Dart.",
        ),
        Question(
          text: "What is a constructor in Dart?",
          options: [
            "A method that destroys objects",
            "A special method that creates and initializes instances",
            "A static utility function",
            "An async callback"
          ],
          correctAnswerIndex: 1,
          explanation: "Constructors create and initialize new instances of a class.",
        ),
        Question(
          text: "What does 'extends' do in a class declaration?",
          options: [
            "Implements an interface",
            "Creates a subclass that inherits from a superclass",
            "Adds a mixin",
            "Marks the class as abstract"
          ],
          correctAnswerIndex: 1,
          explanation: "'class B extends A' makes B inherit members from A.",
        ),
        Question(
          text: "What is polymorphism?",
          options: [
            "Having many constructors",
            "Objects of different classes responding to the same interface",
            "Using many libraries",
            "Writing code without classes"
          ],
          correctAnswerIndex: 1,
          explanation: "Polymorphism lets subclasses be treated through a common interface with specialized behavior.",
        ),
      ],
    ),
    'quiz_classes': Quiz(
      id: 'quiz_classes',
      topicId: 'classes',
      passingThreshold: 80,
      questions: [
        Question(
          text: "How do you create an instance of 'class Point { Point(this.x, this.y); }'?",
          options: [
            "Point.new(1, 2)",
            "new Point(1, 2) or Point(1, 2)",
            "Point.create(1, 2)",
            "Point{1, 2}"
          ],
          correctAnswerIndex: 1,
          explanation: "Instances are created with 'Point(1, 2)'; 'new' is optional in modern Dart.",
        ),
        Question(
          text: "What is a named constructor?",
          options: [
            "A constructor with a name like 'Point.origin()'",
            "A constructor assigned to a variable",
            "A factory that returns null",
            "A private constructor"
          ],
          correctAnswerIndex: 0,
          explanation: "Named constructors like 'Point.origin()' give additional ways to create instances.",
        ),
        Question(
          text: "What does a 'factory' constructor allow?",
          options: [
            "Only const instances",
            "Returning an existing instance or a subtype instead of always creating new",
            "Async initialization",
            "Private fields only"
          ],
          correctAnswerIndex: 1,
          explanation: "Factory constructors can return cached instances or subtype instances.",
        ),
        Question(
          text: "How do you declare a getter in Dart?",
          options: [
            "get area => width * height;",
            "getter area() {}",
            "property area => ...;",
            "func get area() {}"
          ],
          correctAnswerIndex: 0,
          explanation: "Getters use the 'get' keyword: 'double get area => width * height;'.",
        ),
        Question(
          text: "What does 'static' mean for a class member?",
          options: [
            "It cannot be changed",
            "It belongs to the class itself, not to instances",
            "It is private",
            "It is initialized lazily"
          ],
          correctAnswerIndex: 1,
          explanation: "Static members are accessed on the class (ClassName.member), not on instances.",
        ),
      ],
    ),
    'quiz_inheritance': Quiz(
      id: 'quiz_inheritance',
      topicId: 'inheritance',
      passingThreshold: 80,
      questions: [
        Question(
          text: "Which keyword is used to inherit from a class in Dart?",
          options: [
            "implements",
            "extends",
            "with",
            "inherits"
          ],
          correctAnswerIndex: 1,
          explanation: "'extends' creates a subclass inheriting from a superclass.",
        ),
        Question(
          text: "What does '@override' indicate?",
          options: [
            "The method is deprecated",
            "The method redefines a superclass member intentionally",
            "The method is static",
            "The method is async"
          ],
          correctAnswerIndex: 1,
          explanation: "'@override' marks a member that replaces a superclass declaration.",
        ),
        Question(
          text: "What is an abstract class?",
          options: [
            "A class that cannot be instantiated and may declare abstract methods",
            "A class with only static members",
            "A class without constructors",
            "A class that cannot be extended"
          ],
          correctAnswerIndex: 0,
          explanation: "Abstract classes cannot be instantiated; they define interfaces for subclasses.",
        ),
        Question(
          text: "How do you call the superclass constructor?",
          options: [
            "With 'super(...)' in the initializer list",
            "With 'this.super()'",
            "Automatically, always",
            "With 'base()'"
          ],
          correctAnswerIndex: 0,
          explanation: "Use ': super(args)' to forward arguments to the superclass constructor.",
        ),
        Question(
          text: "What does 'implements' do?",
          options: [
            "Inherits implementation from a superclass",
            "Requires the class to provide its own implementation of the interface",
            "Mixes in reusable code",
            "Marks the class final"
          ],
          correctAnswerIndex: 1,
          explanation: "'implements' adopts the interface without inheriting any implementation.",
        ),
      ],
    ),
    'quiz_mixins': Quiz(
      id: 'quiz_mixins',
      topicId: 'mixins',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What is a mixin in Dart?",
          options: [
            "A way to reuse code across class hierarchies without inheritance",
            "A type of constructor",
            "A collection literal",
            "An async primitive"
          ],
          correctAnswerIndex: 0,
          explanation: "Mixins let you reuse methods across unrelated classes.",
        ),
        Question(
          text: "Which keyword applies a mixin to a class?",
          options: [
            "extends",
            "implements",
            "with",
            "mixin"
          ],
          correctAnswerIndex: 2,
          explanation: "'class C extends B with M' applies mixin M to C.",
        ),
        Question(
          text: "How is a mixin declared?",
          options: [
            "class M {}",
            "mixin M {}",
            "abstract M {}",
            "extension M {}"
          ],
          correctAnswerIndex: 1,
          explanation: "Mixins are declared with the 'mixin' keyword.",
        ),
        Question(
          text: "What is 'mixin class' in Dart 3?",
          options: [
            "A mixin that can also be used as a regular class",
            "A deprecated syntax",
            "A mixin with no members",
            "A final class"
          ],
          correctAnswerIndex: 0,
          explanation: "'mixin class' can be used both as a mixin and as a superclass.",
        ),
        Question(
          text: "What does 'on' mean in a mixin declaration ('mixin M on C')?",
          options: [
            "The mixin runs on startup",
            "The mixin can only be applied to subclasses of C",
            "The mixin is enabled conditionally",
            "The mixin overrides C"
          ],
          correctAnswerIndex: 1,
          explanation: "'on' constrains a mixin to classes extending/implementing the given type.",
        ),
      ],
    ),
    'quiz_advanced_dart': Quiz(
      id: 'quiz_advanced_dart',
      topicId: 'advanced_dart',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What does 'async' mark on a function?",
          options: [
            "That it runs on another isolate",
            "That it returns a Future and can use 'await'",
            "That it is a generator",
            "That it never completes"
          ],
          correctAnswerIndex: 1,
          explanation: "'async' functions return Futures and may use 'await' for asynchronous operations.",
        ),
        Question(
          text: "What is sound null safety?",
          options: [
            "A linter rule",
            "A guarantee that no non-nullable variable is ever null at run-time",
            "Automatic null checks in the IDE only",
            "Disabling null entirely"
          ],
          correctAnswerIndex: 1,
          explanation: "Sound null safety guarantees non-nullable variables can never hold null.",
        ),
        Question(
          text: "What are generics used for?",
          options: [
            "Generating code automatically",
            "Writing type-safe code that works with multiple types",
            "Creating generic error messages",
            "Speeding up compilation"
          ],
          correctAnswerIndex: 1,
          explanation: "Generics like 'List<T>' provide compile-time type safety for many types.",
        ),
        Question(
          text: "What is an Isolate in Dart?",
          options: [
            "A quarantined package",
            "An independent unit of execution with its own memory",
            "A test sandbox",
            "A UI widget"
          ],
          correctAnswerIndex: 1,
          explanation: "Isolates are Dart's threads: independent workers with separate memory communicating via messages.",
        ),
        Question(
          text: "What does the 'late' keyword do?",
          options: [
            "Delays compilation",
            "Declares a non-nullable variable initialized after declaration",
            "Marks deprecated code",
            "Makes a variable nullable"
          ],
          correctAnswerIndex: 1,
          explanation: "'late' promises Dart the variable will be assigned before it is read.",
        ),
      ],
    ),
    'quiz_async': Quiz(
      id: 'quiz_async',
      topicId: 'async_programming',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What does 'await' do?",
          options: [
            "Blocks the whole thread",
            "Suspends the async function until the Future completes",
            "Cancels the Future",
            "Runs code in parallel"
          ],
          correctAnswerIndex: 1,
          explanation: "'await' suspends execution of the async function without blocking the event loop.",
        ),
        Question(
          text: "What is a Future in Dart?",
          options: [
            "A value available immediately",
            "An object representing a value available at some point",
            "A scheduled timer",
            "A stream of events"
          ],
          correctAnswerIndex: 1,
          explanation: "A Future represents a computation whose result will be available later.",
        ),
        Question(
          text: "What is a Stream?",
          options: [
            "A single async value",
            "A sequence of asynchronous events",
            "A file reader only",
            "A synchronous list"
          ],
          correctAnswerIndex: 1,
          explanation: "Streams deliver multiple async events over time; listen with 'await for' or 'listen()'.",
        ),
        Question(
          text: "How do you handle errors in an async function?",
          options: [
            "With try/catch around 'await'",
            "Errors cannot be caught",
            "With if/else on the Future",
            "With switch on error codes"
          ],
          correctAnswerIndex: 0,
          explanation: "try/catch works with awaited Futures just like synchronous code.",
        ),
        Question(
          text: "What does 'Future.wait' do?",
          options: [
            "Waits forever",
            "Runs multiple futures concurrently and completes with all results",
            "Runs futures one after another",
            "Cancels all futures"
          ],
          correctAnswerIndex: 1,
          explanation: "'Future.wait([f1, f2])' completes when all given futures complete.",
        ),
      ],
    ),
    'quiz_generics': Quiz(
      id: 'quiz_generics',
      topicId: 'generics',
      passingThreshold: 80,
      questions: [
        Question(
          text: "What does 'List<String>' mean?",
          options: [
            "A list that only holds Strings, checked at compile time",
            "A list of any type",
            "A list of characters",
            "A nullable list"
          ],
          correctAnswerIndex: 0,
          explanation: "The type argument restricts elements to String with compile-time checking.",
        ),
        Question(
          text: "How do you declare a generic function?",
          options: [
            "T first<T>(List<T> items) => items.first;",
            "generic first(items) => items.first;",
            "first<T>(items) => items.first;",
            "T first(items<T>) => items.first;"
          ],
          correctAnswerIndex: 0,
          explanation: "Type parameters go after the function name: 'T first<T>(List<T> items)'.",
        ),
        Question(
          text: "What is a type bound like 'T extends num'?",
          options: [
            "T must be num or a subtype of num",
            "T cannot be num",
            "T is always num",
            "num extends T"
          ],
          correctAnswerIndex: 0,
          explanation: "Bounds restrict which types can be used as type arguments.",
        ),
        Question(
          text: "What is 'Map<String, int>'?",
          options: [
            "A list of strings",
            "A map from String keys to int values",
            "A set of pairs",
            "A function type"
          ],
          correctAnswerIndex: 1,
          explanation: "Map<K, V> maps keys of type K to values of type V.",
        ),
        Question(
          text: "Why use generics instead of 'dynamic'?",
          options: [
            "Generics are faster to write",
            "Generics catch type errors at compile time instead of run-time",
            "dynamic is deprecated",
            "There is no difference"
          ],
          correctAnswerIndex: 1,
          explanation: "Generics preserve type information so mistakes are caught by the analyzer.",
        ),
      ],
    ),
    'quiz_null_safety': Quiz(
      id: 'quiz_null_safety',
      topicId: 'null_safety',
      passingThreshold: 80,
      questions: [
        Question(
          text: "How do you declare a nullable String?",
          options: [
            "String s;",
            "String? s;",
            "nullable String s;",
            "String! s;"
          ],
          correctAnswerIndex: 1,
          explanation: "The '?' suffix marks a type as nullable: 'String?'.",
        ),
        Question(
          text: "What does '!' (bang operator) do?",
          options: [
            "Declares a nullable type",
            "Asserts a nullable value is non-null, throwing if it is null",
            "Compares for inequality",
            "Marks async code"
          ],
          correctAnswerIndex: 1,
          explanation: "The null-assertion operator casts away nullability and throws on null.",
        ),
        Question(
          text: "What does '?.' do?",
          options: [
            "Unconditional member access",
            "Null-aware access: short-circuits to null if the receiver is null",
            "Optional function call",
            "Declares a nullable variable"
          ],
          correctAnswerIndex: 1,
          explanation: "'obj?.method()' skips the call and evaluates to null when obj is null.",
        ),
        Question(
          text: "What is flow promotion (type promotion)?",
          options: [
            "Automatic UI updates",
            "The analyzer treating a nullable variable as non-nullable after a null check",
            "Promoting packages",
            "Upgrading the SDK"
          ],
          correctAnswerIndex: 1,
          explanation: "After 'if (s != null)', Dart promotes 's' to non-nullable within that scope.",
        ),
        Question(
          text: "What does 'required' do for null safety in constructors?",
          options: [
            "Nothing",
            "Forces callers to pass a named argument so non-nullable fields are initialized",
            "Makes the field nullable",
            "Generates a default value"
          ],
          correctAnswerIndex: 1,
          explanation: "'required' named parameters must be supplied, satisfying non-nullable initialization.",
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
