import 'package:flutter/material.dart';
import '../../domain/models/topic.dart';
import '../../data/repositories/roadmap_repository.dart';

class RoadmapViewModel with ChangeNotifier {
  final RoadmapRepository _repository;
  List<Topic> _topics = [];
  bool _isLoading = false;
  String? _error;

  RoadmapViewModel(this._repository);

  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRoadmap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topics = await _repository.getDartRoadmap();
      _error = null;
    } catch (e) {
      _error = 'Failed to load roadmap: $e';
      print('Error loading roadmap: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Topic?> getTopicWithDetail(String topicId) async {
    try {
      return await _repository.getTopicWithDetail(topicId);
    } catch (e) {
      print('Error loading topic detail: $e');
      return null;
    }
  }

  void toggleTopicExpansion(String topicId) {
    _updateTopic(topicId, (topic) => topic.copyWith(
      isExpanded: !topic.isExpanded,
    ));
    _repository.expandCollapseTopic(topicId, _findTopic(topicId)?.isExpanded ?? false);
  }

  void updateTopicStatus(String topicId, TopicStatus status) {
    _updateTopic(topicId, (topic) => topic.copyWith(status: status));
    _repository.updateTopicStatus(topicId, status);
    
    if (status == TopicStatus.completed) {
      _repository.unlockNextTopic(topicId);
      _unlockDependentTopics(topicId);
    }
  }

  void _unlockDependentTopics(String completedTopicId) {
    _topics = _updateTopicsRecursive(_topics, (topic) {
      if (topic.prerequisites.contains(completedTopicId) && 
          topic.status == TopicStatus.locked) {
        final allPrerequisitesMet = topic.prerequisites.every((prereqId) {
          final prereq = _findTopic(prereqId);
          return prereq?.isCompleted ?? false;
        });
        
        if (allPrerequisitesMet) {
          return topic.copyWith(status: TopicStatus.inProgress);
        }
      }
      return topic;
    });
    notifyListeners();
  }

  Topic? _findTopic(String topicId) {
    for (final topic in _topics) {
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

  void _updateTopic(String topicId, Topic Function(Topic) update) {
    _topics = _updateTopicsRecursive(_topics, (topic) {
      if (topic.id == topicId) {
        return update(topic);
      }
      return topic;
    });
    notifyListeners();
  }

  List<Topic> _updateTopicsRecursive(List<Topic> topics, Topic Function(Topic) update) {
    return topics.map((topic) {
      final updatedTopic = update(topic);
      if (topic.subtopics.isNotEmpty) {
        return updatedTopic.copyWith(
          subtopics: _updateTopicsRecursive(topic.subtopics, update),
        );
      }
      return updatedTopic;
    }).toList();
  }

  void retryLoading() {
    loadRoadmap();
  }
}
