import '../../domain/models/topic.dart';

abstract class RoadmapRepository {
  Future<List<Topic>> getDartRoadmap();
  Future<void> updateTopicStatus(String topicId, TopicStatus status);
  Future<void> expandCollapseTopic(String topicId, bool isExpanded);
}

class LocalRoadmapRepository implements RoadmapRepository {
  @override
  Future<List<Topic>> getDartRoadmap() async {
    // Dati mock per la roadmap di Dart con TopicType
    return [
      Topic(
        id: 'dart_basics',
        title: 'Dart Basics',
        description: 'Fundamentals of Dart programming language',
        type: TopicType.core,
        status: TopicStatus.inProgress,
        subtopics: [
          Topic(
            id: 'variables',
            title: 'Variables and Data Types',
            description: 'Learn about variables and data types in Dart',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'functions',
            title: 'Functions',
            description: 'Learn how to write functions in Dart',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'oop',
            title: 'Object Oriented Programming',
            description: 'OOP concepts in Dart',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'advanced_patterns',
            title: 'Advanced Patterns',
            description: 'Advanced programming patterns in Dart',
            type: TopicType.optional,
            status: TopicStatus.locked,
          ),
        ],
      ),
      Topic(
        id: 'flutter_fundamentals',
        title: 'Flutter Fundamentals',
        description: 'Basic Flutter concepts and widgets',
        type: TopicType.core,
        status: TopicStatus.locked,
        subtopics: [
          Topic(
            id: 'widgets',
            title: 'Widgets',
            description: 'Understanding Flutter widgets and their lifecycle',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'state_management',
            title: 'State Management',
            description: 'Managing state in Flutter apps',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'animations',
            title: 'Animations',
            description: 'Creating beautiful animations in Flutter',
            type: TopicType.optional,
            status: TopicStatus.locked,
          ),
        ],
      ),
      Topic(
        id: 'advanced_topics',
        title: 'Advanced Topics',
        description: 'Advanced Flutter and Dart concepts',
        type: TopicType.optional,
        status: TopicStatus.locked,
        subtopics: [
          Topic(
            id: 'testing',
            title: 'Testing',
            description: 'Writing tests for Flutter applications',
            type: TopicType.core,
            status: TopicStatus.locked,
          ),
          Topic(
            id: 'performance',
            title: 'Performance Optimization',
            description: 'Optimizing Flutter app performance',
            type: TopicType.optional,
            status: TopicStatus.locked,
          ),
        ],
      ),
    ];
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    // In un'implementazione reale, qui salveresti sul database locale
    print('Updating topic $topicId to status: $status');
  }

  @override
  Future<void> expandCollapseTopic(String topicId, bool isExpanded) async {
    print('Setting topic $topicId expanded: $isExpanded');
  }
}
