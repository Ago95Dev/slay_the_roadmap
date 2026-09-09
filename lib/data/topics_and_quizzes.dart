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
    description: 'Dart supporta una vasta gamma di operatori per manipolare i dati. Gli operatori aritmetici (+, -, *, /) si usano per la matematica di base, quelli relazionali (==, !=, >, <) per confrontare valori, e quelli logici (&&, ||, !) per combinare condizioni. Inoltre, Dart offre operatori null-aware come "??" per gestire in modo elegante i valori nulli senza crash.',
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
    description: 'Con la Sound Null Safety, Dart protegge il tuo codice dalle eccezioni di tipo null reference. Di default, le variabili non possono contenere "null". Se hai bisogno che una variabile possa essere nulla, devi dichiararla esplicitamente con un punto interrogativo (es. String?). Questo permette al compilatore di avvisarti in anticipo se c\'è il rischio di un errore a runtime.',
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
    description: 'Le istruzioni condizionali permettono al tuo codice di prendere decisioni dinamiche. Usa "if" e "else" per eseguire blocchi di codice in base a condizioni vere o false. Per scelte multiple basate sul valore di una singola variabile, lo "switch" statement è estremamente leggibile ed efficiente. Ricorda: in Dart le condizioni devono sempre restituire un booleano (true o false).',
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
    description: 'I cicli ti permettono di eseguire ripetutamente un blocco di codice. Il classico ciclo "for" è ideale quando conosci a priori il numero esatto di iterazioni. I cicli "while" e "do-while" si usano invece quando la ripetizione dipende da una condizione valutata dinamicamente. Dart offre anche il "for-in", utilissimo per iterare con facilità su collezioni come array e set.',
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
    description: 'Le funzioni sono blocchi logici riutilizzabili. In Dart, puoi definire parametri posizionali obbligatori o parametri nominati opzionali (racchiusi tra graffe {}). Questo migliora enormemente la leggibilità del codice. Dart supporta anche le funzioni freccia (=>) per abbreviare operazioni di una sola riga e considera le funzioni come oggetti di prima classe passabili per argomento.',
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
    description: 'Le List, i Set e le Map sono il cuore dei dati aggregati. Le List sono array ordinati; i Set sono collezioni non ordinate di elementi garantiti unici; le Map memorizzano dati come coppie chiave-valore. Dart ha una sintassi modernissima per comporre collezioni: puoi usare lo spread operator (...) per fonderle e costrutti condizionali (collection-if, collection-for) direttamente al loro interno.',
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
    description: 'Dart è pienamente orientato agli oggetti. Una classe è un "progetto" per creare oggetti, in cui puoi definire dati (proprietà) e comportamenti (metodi). Dart supporta i classici costruttori e aggiunge l\'utile concetto di "costruttore nominato" (factory) per restituire istanze personalizzate senza vincoli rigorosi di allocazione di memoria. Quasi ogni cosa è un oggetto!',
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
    description: 'Tramite l\'ereditarietà (extends), puoi costruire una nuova classe espandendo le funzionalità di una già esistente. Sebbene Dart supporti solo l\'ereditarietà singola stretta, supera questo limite tramite i "mixin". Usando la parola chiave "with", un mixin ti permette di "iniettare" blocchi di funzionalità in diverse gerarchie di classi senza alcun problema di collisione.',
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
    description: 'La programmazione asincrona ti permette di eseguire operazioni lunghe (come query su database o richieste API) senza bloccare l\'intera interfaccia utente. In Dart, un "Future" rappresenta un valore non ancora disponibile. Grazie alle comodissime parole chiave "async" e "await", puoi scrivere il tuo codice asincrono come se fosse lineare, rendendolo estremamente leggibile e pulito.',
    chapterId: 'chapter-3',
    type: TopicType.elective,
    difficulty: 'hard',
    resources: [
      'https://dart.dev/codelabs/async-await',
    ],
    order: 3,
  ),

  // CHAPTER 4: Flutter Basics
  Topic(
    id: 'widgets',
    title: 'Widgets Basics',
    description: 'In Flutter, quasi tutto è un Widget! Un widget è la dichiarazione descrittiva di una porzione dell\'UI. Gli "StatelessWidget" sono leggeri e immutabili: una volta disegnati restano tali. Gli "StatefulWidget", invece, ospitano uno stato (veri e propri dati in memoria) in grado di evolversi. Chiamando "setState()", puoi dire a Flutter di ridisegnare quello specifico widget con i nuovi dati.',
    chapterId: 'chapter-4',
    type: TopicType.core,
    difficulty: 'medium',
    resources: [
      'https://docs.flutter.dev/ui/widgets/basics',
    ],
    order: 1,
  ),
  Topic(
    id: 'layouts',
    title: 'Layouts',
    description: 'Costruire un\'interfaccia in Flutter significa annidare sapientemente i widget di Layout. Usa "Row" per impilare orizzontalmente e "Column" verticalmente; puoi controllare come occupano lo spazio rimanente usando i widget "Expanded". Se devi posizionare elementi uno sopra l\'altro (es. un testo su un\'immagine), affidati a "Stack". Il "Container" è invece perfetto per sfondi, bordi e spaziature.',
    chapterId: 'chapter-4',
    type: TopicType.core,
    difficulty: 'medium',
    resources: [
      'https://docs.flutter.dev/ui/layout',
    ],
    order: 2,
  ),
  Topic(
    id: 'state-management',
    title: 'State Management Basics',
    description: 'Per app articolate, i dati devono spesso viaggiare tra schermi e componenti diversi. Inizierai imparando a sollevare lo stato ("lifting state up"): spostare una variabile comune dal widget figlio al widget genitore condiviso. Man mano che l\'albero cresce, passerai a soluzioni più solide (es. Provider, Riverpod o BLoC) che ti evitano di dover passare i parametri per decine di livelli d\'interfaccia.',
    chapterId: 'chapter-4',
    type: TopicType.core,
    difficulty: 'hard',
    resources: [
      'https://docs.flutter.dev/data-and-backend/state-mgmt/intro',
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

  // Null Safety Quiz (Chapter 1)
  Quiz(
    topicId: 'null-safety',
    questions: [
      QuizQuestion(
        question: 'Which symbol is used to indicate a nullable type in Dart?',
        options: ['!', '?', '*', '&'],
        correctAnswer: 1,
        explanation: 'Appending ? to a type indicates that a variable can be null (e.g., int?).',
      ),
      QuizQuestion(
        question: 'What does the ! operator do in null safety?',
        options: ['Casts to null', 'Checks if null', 'Asserts that a value is not null', 'Makes a variable nullable'],
        correctAnswer: 2,
        explanation: 'The ! operator (bang operator) casts away nullability, telling the compiler you are sure the value is not null.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
  ),

  // Conditionals Quiz (Chapter 2)
  Quiz(
    topicId: 'conditionals',
    questions: [
      QuizQuestion(
        question: 'Which statement is used to execute code if a condition is true?',
        options: ['for', 'if', 'switch', 'while'],
        correctAnswer: 1,
        explanation: 'The if statement evaluates a condition and executes the block if it is true.',
      ),
      QuizQuestion(
        question: 'What is the syntax for a ternary operator?',
        options: ['condition ? true_expr : false_expr', 'condition : true_expr ? false_expr', 'if condition ? true : false', 'condition => true : false'],
        correctAnswer: 0,
        explanation: 'The ternary operator takes the form condition ? exprIfTrue : exprIfFalse.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
  ),

  // Loops Quiz (Chapter 2)
  Quiz(
    topicId: 'loops',
    questions: [
      QuizQuestion(
        question: 'Which loop is guaranteed to execute at least once?',
        options: ['for loop', 'while loop', 'do-while loop', 'for-in loop'],
        correctAnswer: 2,
        explanation: 'A do-while loop executes the code block first, then checks the condition.',
      ),
      QuizQuestion(
        question: 'Which keyword stops the execution of a loop entirely?',
        options: ['continue', 'return', 'stop', 'break'],
        correctAnswer: 3,
        explanation: 'The break statement immediately terminates the loop it is in.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
  ),

  // Collections Quiz (Chapter 2)
  Quiz(
    topicId: 'collections',
    questions: [
      QuizQuestion(
        question: 'Which collection type stores key-value pairs?',
        options: ['List', 'Set', 'Map', 'Array'],
        correctAnswer: 2,
        explanation: 'A Map in Dart is an object that associates keys and values.',
      ),
      QuizQuestion(
        question: 'Which collection guarantees that all elements are unique?',
        options: ['List', 'Set', 'Map', 'Iterable'],
        correctAnswer: 1,
        explanation: 'A Set is an unordered collection of unique items.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
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

  // Widgets Basics Quiz (Chapter 4)
  Quiz(
    topicId: 'widgets',
    questions: [
      QuizQuestion(
        question: 'Which widget is used when the UI does not change dynamically?',
        options: ['StatefulWidget', 'StatelessWidget', 'InheritedWidget', 'DynamicWidget'],
        correctAnswer: 1,
        explanation: 'StatelessWidgets are immutable and their UI cannot change dynamically once built.',
      ),
      QuizQuestion(
        question: 'What method must be overridden in a StatelessWidget?',
        options: ['createState()', 'build()', 'init()', 'render()'],
        correctAnswer: 1,
        explanation: 'The build() method describes the part of the user interface represented by the widget.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
  ),

  // Layouts Quiz (Chapter 4)
  Quiz(
    topicId: 'layouts',
    questions: [
      QuizQuestion(
        question: 'Which widget arranges its children in a vertical array?',
        options: ['Row', 'Stack', 'Column', 'Wrap'],
        correctAnswer: 2,
        explanation: 'A Column widget displays its children in a vertical array.',
      ),
      QuizQuestion(
        question: 'How do you overlap widgets in Flutter?',
        options: ['Using a Stack', 'Using a Column with negative margins', 'Using a Row', 'Using a GridView'],
        correctAnswer: 0,
        explanation: 'The Stack widget allows you to overlap several children in a simple way.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
  ),

  // State Management Quiz (Chapter 4)
  Quiz(
    topicId: 'state-management',
    questions: [
      QuizQuestion(
        question: 'Which method tells the framework to redraw a StatefulWidget?',
        options: ['refresh()', 'update()', 'setState()', 'redraw()'],
        correctAnswer: 2,
        explanation: 'Calling setState() notifies the framework that the internal state of the widget has changed.',
      ),
      QuizQuestion(
        question: 'Where should you hold the state that is shared across multiple widgets?',
        options: ['In a global variable', 'In the lowest common parent widget', 'In a StatelessWidget', 'In the runApp method'],
        correctAnswer: 1,
        explanation: 'Lifting state up to the lowest common parent is a fundamental state management pattern.',
      ),
    ],
    passingScore: 80,
    timeLimit: 120,
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
