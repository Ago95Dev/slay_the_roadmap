import 'package:flutter/material.dart';
import '../../domain/models/topic.dart';
import '../../data/repositories/roadmap_repository.dart';

class RoadmapViewModel with ChangeNotifier {
  final RoadmapRepository _repository;
  List<Topic> _topics = [];
  bool _isLoading = false;

  RoadmapViewModel(this._repository);

  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;

  Future<void> loadRoadmap() async {
    _isLoading = true;
    notifyListeners();

    try {
      _topics = await _repository.getDartRoadmap();
    } catch (error) {
      print('Error loading roadmap: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTopicExpansion(String topicId) {
    _updateTopic(topicId, (topic) => topic.copyWith(
      isExpanded: !topic.isExpanded
    ));
    _repository.expandCollapseTopic(topicId, findTopic(topicId)?.isExpanded ?? false);
  }

  void updateTopicStatus(String topicId, TopicStatus status) {
    _updateTopic(topicId, (topic) => topic.copyWith(status: status));
    _repository.updateTopicStatus(topicId, status);
    
    // Se il topic è completato, sblocca i prerequisiti
    if (status == TopicStatus.completed) {
      _unlockPrerequisites(topicId);
    }
  }

  Topic? findTopic(String topicId) {
    return _findTopicRecursive(_topics, topicId);
  }

  void _unlockPrerequisites(String completedTopicId) {
    // Trova tutti i topic che hanno completedTopicId come prerequisito
    _topics = _unlockPrerequisitesRecursive(_topics, completedTopicId);
    notifyListeners();
  }

  List<Topic> _unlockPrerequisitesRecursive(List<Topic> topics, String completedTopicId) {
    return topics.map((topic) {
      if (topic.prerequisites.contains(completedTopicId) && topic.status == TopicStatus.locked) {
        // Sblocca il topic se tutti i prerequisiti sono soddisfatti
        final allPrerequisitesMet = topic.prerequisites.every((prereqId) {
          final prereqTopic = findTopic(prereqId);
          return prereqTopic?.status == TopicStatus.completed;
        });
        
        if (allPrerequisitesMet) {
          return topic.copyWith(status: TopicStatus.inProgress);
        }
      }
      
      if (topic.subtopics.isNotEmpty) {
        return topic.copyWith(
          subtopics: _unlockPrerequisitesRecursive(topic.subtopics, completedTopicId)
        );
      }
      
      return topic;
    }).toList();
  }

  void _updateTopic(String topicId, Topic Function(Topic) update) {
    _topics = _updateTopicsRecursive(_topics, topicId, update);
    notifyListeners();
  }

  List<Topic> _updateTopicsRecursive(
    List<Topic> topics, 
    String topicId, 
    Topic Function(Topic) update
  ) {
    return topics.map((topic) {
      if (topic.id == topicId) {
        return update(topic);
      } else if (topic.subtopics.isNotEmpty) {
        return topic.copyWith(
          subtopics: _updateTopicsRecursive(topic.subtopics, topicId, update)
        );
      }
      return topic;
    }).toList();
  }

  Topic? _findTopicRecursive(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) {
        return topic;
      }
      if (topic.subtopics.isNotEmpty) {
        final found = _findTopicRecursive(topic.subtopics, topicId);
        if (found != null) return found;
      }
    }
    return null;
  }
}
