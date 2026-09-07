import { Topic, Quiz, Reward, Chapter, BossQuestion } from '../types';

export const topics: Topic[] = [
  {
    id: 'dart-basics',
    title: 'Dart Basics',
    description: 'Introduction to Dart programming language',
    detailedDescription: 'Dart is a modern, object-oriented programming language developed by Google. In this topic, you\'ll learn the fundamentals of Dart including its syntax, core concepts, and why it\'s the perfect language for Flutter development.\n\nKey concepts covered:\n• Dart language overview\n• Development environment setup\n• Basic syntax and structure\n• Running your first Dart program',
    type: 'required',
    parentId: null,
    children: ['variables', 'data-types'],
    chapterId: 'chapter-1',
    resources: [
      { title: 'Official Dart Documentation', url: 'https://dart.dev/guides', type: 'documentation' },
      { title: 'Dart Introduction Video', url: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q', type: 'video' }
    ]
  },
  {
    id: 'variables',
    title: 'Variables & Constants',
    description: 'Learn about var, final, and const',
    detailedDescription: 'Variables are containers for storing data values. In Dart, you have several ways to declare variables, each with different properties and use cases.\n\nYou\'ll learn:\n• Using var for type inference\n• final for runtime constants\n• const for compile-time constants\n• When to use each type\n• Best practices for variable naming',
    type: 'required',
    parentId: 'dart-basics',
    children: [],
    chapterId: 'chapter-1',
    resources: [
      { title: 'Variables in Dart', url: 'https://dart.dev/language/variables', type: 'documentation' },
      { title: 'Understanding final vs const', url: 'https://dart.dev/effective-dart/usage#prefer-final-over-const', type: 'article' }
    ]
  },
  {
    id: 'data-types',
    title: 'Data Types',
    description: 'Numbers, Strings, Booleans, Lists, Maps',
    detailedDescription: 'Dart has a rich set of built-in data types that you\'ll use constantly. Understanding these types is crucial for writing effective Dart code.\n\nTopics covered:\n• Numeric types (int, double)\n• String manipulation\n• Boolean logic\n• Lists and their operations\n• Maps (key-value pairs)\n• Type checking and conversion',
    type: 'required',
    parentId: 'dart-basics',
    children: ['collections'],
    chapterId: 'chapter-1',
    resources: [
      { title: 'Built-in Types', url: 'https://dart.dev/language/built-in-types', type: 'documentation' },
      { title: 'Working with Strings', url: 'https://dart.dev/language/strings', type: 'article' }
    ]
  },
  {
    id: 'collections',
    title: 'Collections Deep Dive',
    description: 'Advanced list and map operations',
    detailedDescription: 'Master advanced collection operations to write more efficient and elegant code. Learn about functional programming concepts applied to collections.\n\nAdvanced topics:\n• Collection methods (map, where, reduce)\n• Spread operators\n• Collection if and for\n• Sets and their use cases\n• Performance considerations',
    type: 'optional',
    parentId: 'data-types',
    children: [],
    chapterId: 'chapter-1',
    resources: [
      { title: 'Collections Guide', url: 'https://dart.dev/guides/libraries/library-tour#collections', type: 'documentation' }
    ]
  },
  {
    id: 'control-flow',
    title: 'Control Flow',
    description: 'If, else, switch, loops',
    detailedDescription: 'Control flow statements allow you to control the execution path of your program. Master these to write dynamic, responsive code.\n\nYou\'ll master:\n• Conditional statements (if, else, else if)\n• Switch statements and pattern matching\n• For loops and iterations\n• While and do-while loops\n• Break and continue keywords',
    type: 'required',
    parentId: null,
    children: ['functions'],
    chapterId: 'chapter-2',
    resources: [
      { title: 'Control Flow Statements', url: 'https://dart.dev/language/branches', type: 'documentation' }
    ]
  },
  {
    id: 'functions',
    title: 'Functions',
    description: 'Function declaration, parameters, return values',
    detailedDescription: 'Functions are the building blocks of Dart programs. Learn how to write clean, reusable code using functions effectively.\n\nKey concepts:\n• Function declaration and syntax\n• Parameters (positional, named, optional)\n• Return values and types\n• Function as first-class objects\n• Anonymous functions',
    type: 'required',
    parentId: 'control-flow',
    children: ['arrow-functions'],
    chapterId: 'chapter-2',
    resources: [
      { title: 'Functions Guide', url: 'https://dart.dev/language/functions', type: 'documentation' },
      { title: 'Function Parameters Explained', url: 'https://dart.dev/effective-dart/usage#prefer-using-named-parameters-for-boolean-parameters', type: 'article' }
    ]
  },
  {
    id: 'arrow-functions',
    title: 'Arrow Functions',
    description: 'Shorthand function syntax',
    detailedDescription: 'Arrow functions provide a concise syntax for simple functions. Perfect for callbacks and functional programming patterns.\n\nLearn about:\n• Arrow function syntax (=>)\n• When to use arrow functions\n• Limitations vs regular functions\n• Best practices',
    type: 'optional',
    parentId: 'functions',
    children: [],
    chapterId: 'chapter-2',
    resources: []
  },
  {
    id: 'oop',
    title: 'Object-Oriented Programming',
    description: 'Classes, objects, inheritance',
    detailedDescription: 'Object-Oriented Programming (OOP) is a programming paradigm based on objects and classes. Dart is a fully object-oriented language.\n\nCore OOP concepts:\n• Classes and objects\n• Encapsulation\n• Inheritance\n• Polymorphism\n• Abstract classes\n• Interfaces',
    type: 'required',
    parentId: null,
    children: ['classes', 'inheritance'],
    chapterId: 'chapter-3',
    resources: [
      { title: 'Classes in Dart', url: 'https://dart.dev/language/classes', type: 'documentation' }
    ]
  },
  {
    id: 'classes',
    title: 'Classes & Objects',
    description: 'Creating and using classes',
    detailedDescription: 'Classes are blueprints for creating objects. Learn how to design and implement classes effectively in Dart.\n\nTopics:\n• Class declaration\n• Constructors (default, named, factory)\n• Instance variables and methods\n• Getters and setters\n• Private members\n• Static members',
    type: 'required',
    parentId: 'oop',
    children: [],
    chapterId: 'chapter-3',
    resources: [
      { title: 'Constructors', url: 'https://dart.dev/language/constructors', type: 'documentation' }
    ]
  },
  {
    id: 'inheritance',
    title: 'Inheritance & Mixins',
    description: 'Code reuse through inheritance',
    detailedDescription: 'Inheritance allows you to create new classes based on existing ones. Mixins provide a way to reuse code across multiple class hierarchies.\n\nYou\'ll learn:\n• Extending classes\n• Overriding methods\n• super keyword\n• Mixins and with keyword\n• When to use inheritance vs composition',
    type: 'required',
    parentId: 'oop',
    children: [],
    chapterId: 'chapter-3',
    resources: [
      { title: 'Extend a class', url: 'https://dart.dev/language/extend', type: 'documentation' },
      { title: 'Mixins', url: 'https://dart.dev/language/mixins', type: 'documentation' }
    ]
  }
];

export const quizzes: Quiz[] = [
  {
    topicId: 'dart-basics',
    questions: [
      {
        id: 'db-1',
        question: 'What is Dart primarily used for?',
        options: ['Web development only', 'Mobile development with Flutter', 'Game development', 'Database management'],
        correctAnswer: 1,
        explanation: 'Dart is primarily used for mobile development with Flutter framework.',
        difficulty: 'easy'
      },
      {
        id: 'db-2',
        question: 'Is Dart a statically typed or dynamically typed language?',
        options: ['Dynamically typed', 'Statically typed', 'Both', 'Neither'],
        correctAnswer: 1,
        explanation: 'Dart is a statically typed language with type inference.',
        difficulty: 'easy'
      },
      {
        id: 'db-3',
        question: 'What is the entry point of a Dart application?',
        options: ['start()', 'main()', 'run()', 'execute()'],
        correctAnswer: 1,
        explanation: 'The main() function is the entry point of every Dart application.',
        difficulty: 'easy'
      }
    ]
  },
  {
    topicId: 'variables',
    questions: [
      {
        id: 'v-1',
        question: 'Which keyword creates a compile-time constant in Dart?',
        options: ['var', 'final', 'const', 'let'],
        correctAnswer: 2,
        explanation: 'const creates compile-time constants in Dart.',
        difficulty: 'medium'
      },
      {
        id: 'v-2',
        question: 'Can you reassign a variable declared with final?',
        options: ['Yes, always', 'No, never', 'Only once', 'Only if it\'s null'],
        correctAnswer: 1,
        explanation: 'Variables declared with final can only be set once and cannot be reassigned.',
        difficulty: 'easy'
      },
      {
        id: 'v-3',
        question: 'What happens if you use var without initialization?',
        options: ['Compilation error', 'Runtime error', 'Type is inferred as dynamic', 'Type is inferred as null'],
        correctAnswer: 2,
        explanation: 'Without initialization, var creates a variable of type dynamic.',
        difficulty: 'medium'
      }
    ]
  },
  {
    topicId: 'data-types',
    questions: [
      {
        id: 'dt-1',
        question: 'What is the correct way to declare a list in Dart?',
        options: ['array[] nums', 'List<int> nums', 'int[] nums', 'nums: List'],
        correctAnswer: 1,
        explanation: 'List<int> nums is the correct syntax for declaring a typed list in Dart.',
        difficulty: 'easy'
      },
      {
        id: 'dt-2',
        question: 'Which of these is NOT a primitive type in Dart?',
        options: ['int', 'String', 'bool', 'char'],
        correctAnswer: 3,
        explanation: 'Dart does not have a char type. Strings are used for characters.',
        difficulty: 'medium'
      },
      {
        id: 'dt-3',
        question: 'What does the Map data type represent?',
        options: ['An array', 'A key-value pair collection', 'A function', 'A class'],
        correctAnswer: 1,
        explanation: 'Map represents a collection of key-value pairs in Dart.',
        difficulty: 'easy'
      }
    ]
  },
  {
    topicId: 'collections',
    questions: [
      {
        id: 'c-1',
        question: 'What method adds an element to the end of a list?',
        options: ['push()', 'add()', 'append()', 'insert()'],
        correctAnswer: 1,
        explanation: 'The add() method adds an element to the end of a list.',
        difficulty: 'easy'
      },
      {
        id: 'c-2',
        question: 'How do you create an empty set in Dart?',
        options: ['Set()', '{}', 'Set<int>{}', '<int>{}'],
        correctAnswer: 2,
        explanation: 'Set<Type>{} creates an empty set with a specific type.',
        difficulty: 'hard'
      },
      {
        id: 'c-3',
        question: 'What does the spread operator (...) do?',
        options: ['Multiplies values', 'Divides values', 'Inserts multiple elements', 'Removes elements'],
        correctAnswer: 2,
        explanation: 'The spread operator inserts all elements of a collection into another collection.',
        difficulty: 'medium'
      }
    ]
  },
  {
    topicId: 'control-flow',
    questions: [
      {
        id: 'cf-1',
        question: 'Which loop is best for iterating over a collection?',
        options: ['while', 'do-while', 'for-in', 'goto'],
        correctAnswer: 2,
        explanation: 'The for-in loop is specifically designed for iterating over collections.',
        difficulty: 'easy'
      },
      {
        id: 'cf-2',
        question: 'What is the difference between if and switch?',
        options: ['No difference', 'switch is for multiple conditions on one variable', 'if is faster', 'switch can\'t use break'],
        correctAnswer: 1,
        explanation: 'switch is optimized for checking multiple possible values of a single variable.',
        difficulty: 'medium'
      },
      {
        id: 'cf-3',
        question: 'What does break do in a loop?',
        options: ['Pauses the loop', 'Exits the loop', 'Skips to next iteration', 'Crashes the program'],
        correctAnswer: 1,
        explanation: 'break exits the loop immediately.',
        difficulty: 'easy'
      }
    ]
  },
  {
    topicId: 'functions',
    questions: [
      {
        id: 'f-1',
        question: 'How do you specify an optional parameter in Dart?',
        options: ['Use []', 'Use {}', 'Use ()', 'Use <>'],
        correctAnswer: 0,
        explanation: 'Square brackets [] denote optional positional parameters.',
        difficulty: 'medium'
      },
      {
        id: 'f-2',
        question: 'What is a named parameter?',
        options: ['A parameter with a name', 'A parameter in curly braces', 'A required parameter', 'A return value'],
        correctAnswer: 1,
        explanation: 'Named parameters are enclosed in curly braces and called by name.',
        difficulty: 'easy'
      },
      {
        id: 'f-3',
        question: 'Can functions return multiple values in Dart?',
        options: ['Yes, using return x, y', 'No, but can return a collection or class', 'Yes, using return [x, y]', 'Only with async functions'],
        correctAnswer: 1,
        explanation: 'Functions can\'t directly return multiple values but can return a List, Map, or custom class.',
        difficulty: 'hard'
      }
    ]
  },
  {
    topicId: 'arrow-functions',
    questions: [
      {
        id: 'af-1',
        question: 'What is the syntax for an arrow function?',
        options: ['function => body', '() -> body', '() => expression', 'lambda body'],
        correctAnswer: 2,
        explanation: '() => expression is the arrow function syntax in Dart.',
        difficulty: 'easy'
      },
      {
        id: 'af-2',
        question: 'Can arrow functions contain multiple statements?',
        options: ['Yes, always', 'No, only single expressions', 'Yes, with curly braces', 'Only with return'],
        correctAnswer: 1,
        explanation: 'Arrow functions can only contain a single expression.',
        difficulty: 'medium'
      },
      {
        id: 'af-3',
        question: 'When should you use arrow functions?',
        options: ['Always', 'For simple one-line functions', 'Never', 'Only for callbacks'],
        correctAnswer: 1,
        explanation: 'Arrow functions are best for simple, one-line function expressions.',
        difficulty: 'easy'
      }
    ]
  },
  {
    topicId: 'oop',
    questions: [
      {
        id: 'oop-1',
        question: 'What is encapsulation?',
        options: ['Creating objects', 'Hiding implementation details', 'Inheriting code', 'Polymorphism'],
        correctAnswer: 1,
        explanation: 'Encapsulation is the bundling of data and methods that operate on that data within a single unit.',
        difficulty: 'medium'
      },
      {
        id: 'oop-2',
        question: 'What keyword is used to create a class in Dart?',
        options: ['object', 'class', 'type', 'struct'],
        correctAnswer: 1,
        explanation: 'The class keyword is used to define classes in Dart.',
        difficulty: 'easy'
      },
      {
        id: 'oop-3',
        question: 'What is a constructor?',
        options: ['A method to destroy objects', 'A method to initialize objects', 'A type of class', 'A variable'],
        correctAnswer: 1,
        explanation: 'A constructor is a special method used to initialize objects when they are created.',
        difficulty: 'easy'
      }
    ]
  },
  {
    topicId: 'classes',
    questions: [
      {
        id: 'cl-1',
        question: 'How do you make a property private in Dart?',
        options: ['Use private keyword', 'Prefix with _', 'Use # symbol', 'Declare inside constructor'],
        correctAnswer: 1,
        explanation: 'Prefixing with underscore (_) makes a property private to its library.',
        difficulty: 'medium'
      },
      {
        id: 'cl-2',
        question: 'What is a getter in Dart?',
        options: ['A function that retrieves data', 'A computed property', 'A constructor', 'A class method'],
        correctAnswer: 1,
        explanation: 'Getters are computed properties that can execute code when accessed.',
        difficulty: 'medium'
      },
      {
        id: 'cl-3',
        question: 'Can you have multiple constructors in a Dart class?',
        options: ['No', 'Yes, using named constructors', 'Yes, with different parameters', 'Only with inheritance'],
        correctAnswer: 1,
        explanation: 'Dart supports multiple constructors through named constructors.',
        difficulty: 'hard'
      }
    ]
  },
  {
    topicId: 'inheritance',
    questions: [
      {
        id: 'inh-1',
        question: 'What keyword is used for inheritance in Dart?',
        options: ['inherits', 'extends', 'implements', 'super'],
        correctAnswer: 1,
        explanation: 'The extends keyword is used for class inheritance in Dart.',
        difficulty: 'easy'
      },
      {
        id: 'inh-2',
        question: 'What is a mixin?',
        options: ['A type of class', 'A way to reuse code without inheritance', 'A function', 'A variable type'],
        correctAnswer: 1,
        explanation: 'Mixins allow you to reuse code across multiple class hierarchies.',
        difficulty: 'hard'
      },
      {
        id: 'inh-3',
        question: 'Can a class extend multiple classes in Dart?',
        options: ['Yes, unlimited', 'Yes, up to 3', 'No, single inheritance only', 'Only with interfaces'],
        correctAnswer: 2,
        explanation: 'Dart supports single inheritance but allows implementing multiple interfaces and using mixins.',
        difficulty: 'medium'
      }
    ]
  }
];

export const rewards: Reward[] = [
  // Attack cards
  {
    id: 'code-strike',
    name: 'Code Strike',
    type: 'attack',
    description: 'Deal 15 damage to the boss',
    effect: 15,
    manaCost: 2,
    rarity: 'common',
    icon: 'Sword',
    synergies: ['bug-smash']
  },
  {
    id: 'bug-smash',
    name: 'Bug Smash',
    type: 'attack',
    description: 'Deal 20 damage to the boss',
    effect: 20,
    manaCost: 3,
    rarity: 'rare',
    icon: 'Zap',
    synergies: ['code-strike']
  },
  {
    id: 'refactor-blast',
    name: 'Refactor Blast',
    type: 'attack',
    description: 'Deal 25 damage to the boss',
    effect: 25,
    manaCost: 4,
    rarity: 'epic',
    icon: 'Flame'
  },
  // Defense cards
  {
    id: 'syntax-shield',
    name: 'Syntax Shield',
    type: 'defense',
    description: 'Reduce incoming damage by 5',
    effect: 5,
    manaCost: 1,
    rarity: 'common',
    icon: 'Shield'
  },
  {
    id: 'type-safety',
    name: 'Type Safety',
    type: 'defense',
    description: 'Reduce incoming damage by 8',
    effect: 8,
    manaCost: 2,
    rarity: 'rare',
    icon: 'ShieldCheck'
  },
  {
    id: 'null-safety',
    name: 'Null Safety',
    type: 'defense',
    description: 'Reduce incoming damage by 10',
    effect: 10,
    manaCost: 3,
    rarity: 'epic',
    icon: 'ShieldAlert'
  },
  // Utility cards (formerly heal)
  {
    id: 'debug-heal',
    name: 'Debug Heal',
    type: 'utility',
    description: 'Restore 20 HP',
    effect: 20,
    manaCost: 2,
    rarity: 'common',
    icon: 'Heart'
  },
  {
    id: 'optimization',
    name: 'Code Optimization',
    type: 'utility',
    description: 'Restore 30 HP',
    effect: 30,
    manaCost: 3,
    rarity: 'rare',
    icon: 'HeartPulse'
  },
  {
    id: 'full-restore',
    name: 'Full Restore',
    type: 'utility',
    description: 'Restore 50 HP',
    effect: 50,
    manaCost: 5,
    rarity: 'legendary',
    icon: 'HeartHandshake'
  }
];

export const chapters: Chapter[] = [
  {
    id: 'chapter-1',
    title: 'Chapter 1: Fundamentals',
    description: 'Master the basics of Dart',
    bossName: 'Syntax Serpent',
    bossHp: 100,
    topicIds: ['dart-basics', 'variables', 'data-types', 'collections']
  },
  {
    id: 'chapter-2',
    title: 'Chapter 2: Logic & Functions',
    description: 'Control the flow of your code',
    bossName: 'Logic Leviathan',
    bossHp: 150,
    topicIds: ['control-flow', 'functions', 'arrow-functions']
  },
  {
    id: 'chapter-3',
    title: 'Chapter 3: Object Mastery',
    description: 'Embrace object-oriented programming',
    bossName: 'OOP Overlord',
    bossHp: 200,
    topicIds: ['oop', 'classes', 'inheritance']
  }
];

export const bossQuestions: { [chapterId: string]: BossQuestion[] } = {
  'chapter-1': [
    {
      id: 'boss-1-1',
      question: 'What is the difference between final and const?',
      options: ['No difference', 'final is runtime, const is compile-time', 'const is runtime, final is compile-time', 'Both are the same'],
      correctAnswer: 1,
      damage: 15,
      explanation: 'final variables are set at runtime, while const are compile-time constants.',
      difficulty: 'hard'
    },
    {
      id: 'boss-1-2',
      question: 'Which collection allows duplicate values?',
      options: ['Set', 'List', 'Map', 'None'],
      correctAnswer: 1,
      damage: 12,
      explanation: 'Lists allow duplicate values, while Sets do not.',
      difficulty: 'medium'
    },
    {
      id: 'boss-1-3',
      question: 'How do you access a map value?',
      options: ['map.get(key)', 'map[key]', 'map(key)', 'map->key'],
      correctAnswer: 1,
      damage: 10,
      explanation: 'Use bracket notation map[key] to access map values.',
      difficulty: 'easy'
    }
  ],
  'chapter-2': [
    {
      id: 'boss-2-1',
      question: 'What is the output of: for(var i=0; i<3; i++) print(i);',
      options: ['0 1 2', '1 2 3', '0 1 2 3', 'Error'],
      correctAnswer: 0,
      damage: 18,
      explanation: 'The loop prints 0, 1, 2 as i starts at 0 and stops before 3.',
      difficulty: 'medium'
    },
    {
      id: 'boss-2-2',
      question: 'Can functions be passed as parameters in Dart?',
      options: ['No', 'Yes, they are first-class citizens', 'Only arrow functions', 'Only named functions'],
      correctAnswer: 1,
      damage: 15,
      explanation: 'Functions are first-class citizens in Dart and can be passed as parameters.',
      difficulty: 'hard'
    },
    {
      id: 'boss-2-3',
      question: 'What does the ?? operator do?',
      options: ['Division', 'Null-aware operator', 'Comparison', 'Assignment'],
      correctAnswer: 1,
      damage: 12,
      explanation: 'The ?? operator returns the left operand if it\'s not null, otherwise returns the right.',
      difficulty: 'hard'
    }
  ],
  'chapter-3': [
    {
      id: 'boss-3-1',
      question: 'What is polymorphism?',
      options: ['Many forms', 'Single form', 'No form', 'Data hiding'],
      correctAnswer: 0,
      damage: 20,
      explanation: 'Polymorphism means "many forms" - objects can take different forms through inheritance.',
      difficulty: 'hard'
    },
    {
      id: 'boss-3-2',
      question: 'What keyword prevents a class from being inherited?',
      options: ['final', 'sealed', 'private', 'static'],
      correctAnswer: 0,
      damage: 18,
      explanation: 'The final keyword prevents a class from being extended.',
      difficulty: 'medium'
    },
    {
      id: 'boss-3-3',
      question: 'How do you call a parent class method?',
      options: ['parent.method()', 'super.method()', 'base.method()', 'this.method()'],
      correctAnswer: 1,
      damage: 15,
      explanation: 'Use super.method() to call parent class methods.',
      difficulty: 'medium'
    }
  ]
};
