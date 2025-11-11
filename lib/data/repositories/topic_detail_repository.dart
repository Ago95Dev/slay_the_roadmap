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
