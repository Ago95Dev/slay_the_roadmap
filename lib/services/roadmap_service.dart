import '../models/roadmap_models.dart';

class RoadmapService {
  Future<List<Topic>> getDartRoadmap() async {
    // Simuliamo un delay di rete
    await Future.delayed(Duration(milliseconds: 500));
    
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
            description: 'Understanding Flutter widgets',
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
        ],
      ),
    ];
  }

  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    // In un'implementazione reale, qui salveresti sul database locale
    print('Updating topic $topicId to status: $status');
  }
}
