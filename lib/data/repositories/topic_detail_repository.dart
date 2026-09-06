import '../../domain/models/topic_detail.dart';

abstract class TopicDetailRepository {
  Future<TopicDetail?> getTopicDetail(String topicId);
  Future<Map<String, TopicDetail>> getAllTopicDetails();
}

class LocalTopicDetailRepository implements TopicDetailRepository {
  final Map<String, TopicDetail> _topicDetails = {
    'dart_basics': TopicDetail(
      id: 'dart_basics',
      title: 'Basics of Dart',
      description: 'Dart is an open-source, general-purpose, object-oriented programming language with C-style syntax developed by Google in 2011. The purpose of Dart programming is to create a frontend user interfaces for the web and mobile apps. It can also be used to build server and desktop applications.\\n\\nVisit the following resources to learn more:',
      quizId: 'quiz_dart_basics',
      links: [
        LearningLink(
          title: 'Dart Overview',
          url: 'https://dart.dev/overview',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Explore top posts about Dart',
          url: 'https://app.daily.dev/tags/dart?ref=roadmapsh',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'What is Dart?',
          url: 'https://www.youtube.com/watch?v=sOSd6G1qXoY',
          type: LinkType.video,
        ),
        LearningLink(
          title: 'Dart in 100 Seconds',
          url: 'https://www.youtube.com/watch?v=NrO0CJCbYLA',
          type: LinkType.video,
        ),
      ],
    ),
    'variables': TopicDetail(
      id: 'variables',
      title: 'Variables and Data Types',
      description: 'Understanding variables, constants and data types in Dart. Learn about var, final, const, and the different data types available in Dart including int, double, String, bool, List, Map, and more.\\n\\nVisit the following resources to learn more:',
      quizId: 'quiz_variables',
      links: [
        LearningLink(
          title: 'Dart Variables',
          url: 'https://dart.dev/language/variables',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Dart Data Types',
          url: 'https://dart.dev/language/variables',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Variables Tutorial',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'functions': TopicDetail(
      id: 'functions',
      title: 'Functions',
      description: 'Learn how to write and use functions in Dart. Understand function parameters, return types, arrow functions, and function expressions. Explore optional parameters, named parameters, and default values.\\n\\nVisit the following resources to learn more:',
      quizId: 'quiz_functions',
      links: [
        LearningLink(
          title: 'Dart Functions',
          url: 'https://dart.dev/language/functions',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Functions in Dart',
          url: 'https://dart.dev/guides/language/language-tour#functions',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Functions Tutorial',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'control_flow': TopicDetail(
      id: 'control_flow',
      title: 'Control Flow',
      description: 'Master control flow statements in Dart including if-else, for loops, while loops, do-while loops, switch statements, and break/continue. Learn how to control the execution flow of your Dart programs.\\n\\nVisit the following resources to learn more:',
      quizId: 'quiz_control_flow',
      links: [
        LearningLink(
          title: 'Control Flow in Dart',
          url: 'https://dart.dev/language/control-flow',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Dart Control Flow Tutorial',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'oop_dart': TopicDetail(
      id: 'oop_dart',
      title: 'Object-Oriented Programming',
      description: 'Master OOP concepts in Dart including classes, objects, inheritance, polymorphism, encapsulation, and abstraction. Learn about constructors, methods, properties, and access modifiers.\\n\\nVisit the following resources to learn more:',
      quizId: 'quiz_oop',
      links: [
        LearningLink(
          title: 'Dart Classes',
          url: 'https://dart.dev/language/classes',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Object-Oriented Programming in Dart',
          url: 'https://dart.dev/guides/language/language-tour#classes',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart OOP Tutorial',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'classes': TopicDetail(
      id: 'classes',
      title: 'Classi e Oggetti',
      description: 'Le classi sono i mattoni della programmazione a oggetti in Dart: raggruppano dati (campi) e comportamento (metodi) in un unico tipo. Imparerai costruttori generativi e named, membri statici, getter/setter e costruttori factory e const per istanze immutabili.\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_classes',
      links: [
        LearningLink(
          title: 'Classi in Dart',
          url: 'https://dart.dev/language/classes',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Costruttori: guida alla sintassi',
          url: 'https://dart.dev/language/constructors',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Classes Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'inheritance': TopicDetail(
      id: 'inheritance',
      title: 'Ereditarietà',
      description: 'Con extends crei una sottoclasse che riusa ed estende il comportamento della superclasse, ridefinendo i membri con @override. Le classi astratte definiscono contratti non istanziabili, mentre implements adotta solo l\u2019interfaccia senza ereditare l\u2019implementazione. Il costruttore della superclasse si richiama con super(...).\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_inheritance',
      links: [
        LearningLink(
          title: 'Extend a class (ereditarietà)',
          url: 'https://dart.dev/language/extend',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Class modifiers: abstract, interface, final',
          url: 'https://dart.dev/language/class-modifiers',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Inheritance Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'mixins': TopicDetail(
      id: 'mixins',
      title: 'Mixin',
      description: 'I mixin permettono di riusare codice tra gerarchie di classi diverse senza ereditarietà multipla: si dichiarano con mixin e si applicano con with. Con on puoi vincolare un mixin alle sole sottoclassi di un tipo, e con mixin class (Dart 3) lo stesso tipo funziona sia come mixin sia come classe.\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_mixins',
      links: [
        LearningLink(
          title: 'Mixins in Dart',
          url: 'https://dart.dev/language/mixins',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Dart: cosa sono i mixin',
          url: 'https://dart.dev/guides/language/language-tour#adding-features-to-a-class-mixins',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Mixins Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'advanced_dart': TopicDetail(
      id: 'advanced_dart',
      title: 'Dart Avanzato',
      description: 'Panoramica dei temi avanzati di Dart: programmazione asincrona con Future e Stream, null safety sound, generics per codice type-safe, late per inizializzazione differita e Isolate per esecuzione concorrente senza memoria condivisa. È il ponte verso i tre sotto-topic dedicati.\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_advanced_dart',
      links: [
        LearningLink(
          title: 'Dart: tour del linguaggio',
          url: 'https://dart.dev/language',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Effective Dart: design e buone pratiche',
          url: 'https://dart.dev/effective-dart/design',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart in 100 Seconds (video)',
          url: 'https://www.youtube.com/watch?v=NrO0CJCbYLA',
          type: LinkType.video,
        ),
      ],
    ),
    'async_programming': TopicDetail(
      id: 'async_programming',
      title: 'Programmazione Asincrona',
      description: 'In Dart il codice asincrono usa Future per valori futuri singoli e Stream per sequenze di eventi nel tempo. Una funzione async restituisce un Future e può sospendersi con await senza bloccare l\u2019event loop; gli errori si gestiscono con try/catch e più Future si attendono insieme con Future.wait.\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_async',
      links: [
        LearningLink(
          title: 'Asincronia in Dart: Future e async/await',
          url: 'https://dart.dev/libraries/async/async-await',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Stream: sequenze di eventi asincroni',
          url: 'https://dart.dev/libraries/async/using-streams',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Async Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'generics': TopicDetail(
      id: 'generics',
      title: 'Generics',
      description: 'I generics rendono il codice type-safe e riusabile su più tipi: List<String> o Map<String, int> vengono controllati a compile time dall\u2019analyzer. Imparerai a dichiarare funzioni e classi generiche (T first<T>(...)), a vincolare i parametri con extends (T extends num) e a preferirli a dynamic per trovare gli errori prima del run.\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_generics',
      links: [
        LearningLink(
          title: 'Generics in Dart',
          url: 'https://dart.dev/language/generics',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Tour del linguaggio: tipi generici',
          url: 'https://dart.dev/guides/language/language-tour#generics',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Generics Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
    'null_safety': TopicDetail(
      id: 'null_safety',
      title: 'Null Safety',
      description: 'La sound null safety garantisce che nessuna variabile non-nullable contenga mai null a run time. Dichiarerai i tipi annullabili con ? (String?), accederai in sicurezza con ?. e ??, forzerai con ! solo quando sei certo, e sfrutterai la promotion dell\u2019analyzer dopo un controllo if (x != null).\\n\\nConsulta le seguenti risorse per approfondire:',
      quizId: 'quiz_null_safety',
      links: [
        LearningLink(
          title: 'Sound null safety in Dart',
          url: 'https://dart.dev/null-safety',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Capire la null safety',
          url: 'https://dart.dev/null-safety/understanding-null-safety',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Dart Null Safety Tutorial (video)',
          url: 'https://www.youtube.com/watch?v=0CTaksOIDeI',
          type: LinkType.video,
        ),
      ],
    ),
  };

  @override
  Future<TopicDetail?> getTopicDetail(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _topicDetails[topicId];
  }

  @override
  Future<Map<String, TopicDetail>> getAllTopicDetails() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _topicDetails;
  }
}
