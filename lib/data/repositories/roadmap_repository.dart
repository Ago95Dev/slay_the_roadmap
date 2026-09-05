import '../../domain/models/topic.dart';
import 'topic_detail_repository.dart';

abstract class RoadmapRepository {
  Future<List<Topic>> getDartRoadmap();
  Future<void> updateTopicStatus(String topicId, TopicStatus status);
  Future<void> expandCollapseTopic(String topicId, bool isExpanded);
  Future<void> unlockNextTopic(String completedTopicId);
  Future<Topic?> getTopicWithDetail(String topicId);
}

class LocalRoadmapRepository implements RoadmapRepository {
  final TopicDetailRepository _detailRepository = LocalTopicDetailRepository();
  
  final List<Topic> _dartRoadmap = [
    Topic(
      id: 'dart_basics',
      title: 'Dart Basics',
      description: 'Learn the fundamentals of Dart programming language',
      isOptional: false,
      status: TopicStatus.inProgress,
      isExpanded: true,
      quizId: 'quiz_dart_basics',
      subtopics: [
        Topic(
          id: 'variables',
          title: 'Variables and Data Types',
          description: 'Understanding variables, constants and data types in Dart',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['dart_basics'],
          quizId: 'quiz_variables',
        ),
        Topic(
          id: 'functions',
          title: 'Functions',
          description: 'Learn how to write and use functions in Dart',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['variables'],
          quizId: 'quiz_functions',
        ),
        Topic(
          id: 'control_flow',
          title: 'Control Flow',
          description: 'If statements, loops and conditional expressions',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['variables'],
          quizId: 'quiz_control_flow',
        ),
      ],
    ),
    Topic(
      id: 'oop_dart',
      title: 'Object-Oriented Programming',
      description: 'Master OOP concepts in Dart',
      isOptional: false,
      status: TopicStatus.locked,
      prerequisites: ['dart_basics'],
      quizId: 'quiz_oop',
      subtopics: [
        Topic(
          id: 'classes',
          title: 'Classes and Objects',
          description: 'Creating classes and objects in Dart',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['oop_dart'],
          quizId: 'quiz_classes',
        ),
        Topic(
          id: 'inheritance',
          title: 'Inheritance',
          description: 'Understanding class inheritance and polymorphism',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['classes'],
          quizId: 'quiz_inheritance',
        ),
        Topic(
          id: 'mixins',
          title: 'Mixins',
          description: 'Using mixins for code reuse (Optional)',
          isOptional: true,
          status: TopicStatus.locked,
          prerequisites: ['inheritance'],
          quizId: 'quiz_mixins',
        ),
      ],
    ),
    Topic(
      id: 'advanced_dart',
      title: 'Advanced Dart',
      description: 'Advanced Dart concepts and features',
      isOptional: false,
      status: TopicStatus.locked,
      prerequisites: ['oop_dart'],
      quizId: 'quiz_advanced_dart',
      subtopics: [
        Topic(
          id: 'async_programming',
          title: 'Asynchronous Programming',
          description: 'Futures, async/await and streams',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['advanced_dart'],
          quizId: 'quiz_async',
        ),
        Topic(
          id: 'generics',
          title: 'Generics',
          description: 'Type-safe collections and generic functions',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['advanced_dart'],
          quizId: 'quiz_generics',
        ),
        Topic(
          id: 'null_safety',
          title: 'Null Safety',
          description: 'Dart\'s null safety features',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['advanced_dart'],
          quizId: 'quiz_null_safety',
        ),
      ],
    ),
  ];

  @override
  Future<List<Topic>> getDartRoadmap() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dartRoadmap;
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    print('Updating topic $topicId to status: $status');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> expandCollapseTopic(String topicId, bool isExpanded) async {
    print('Setting topic $topicId expanded: $isExpanded');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> unlockNextTopic(String completedTopicId) async {
    print('Unlocking next topics after completing: $completedTopicId');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<Topic?> getTopicWithDetail(String topicId) async {
    final topic = _findTopic(_dartRoadmap, topicId);
    if (topic != null) {
      final detail = await _detailRepository.getTopicDetail(topicId);
      return topic.copyWith(detail: detail);
    }
    return null;
  }

  Topic? _findTopic(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
      final found = _findTopicInSubtopic(topic.subtopics, topicId);
      if (found != null) return found;
    }
    return null;
  }

  Topic? _findTopicInSubtopic(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
      final found = _findTopicInSubtopic(topic.subtopics, topicId);
      if (found != null) return found;
    }
    return null;
  }
}
