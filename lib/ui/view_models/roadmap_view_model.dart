import 'package:flutter/material.dart';
import '../../domain/models/campaign_lore.dart';
import '../../domain/models/topic.dart';
import '../../data/repositories/roadmap_repository.dart';

class RoadmapViewModel with ChangeNotifier {
  final RoadmapRepository _repository;

  /// Campagna di cui caricare la roadmap (F11, default seed Web).
  final String? campaignId;

  /// Campagna US-04: true se il boss [bossId] è stato sconfitto.
  /// Opzionale (default: sempre false) così i vecchi test senza
  /// PlayerViewModel restano invariati. Cablata in `main.dart` da
  /// `PlayerViewModel.isBossDefeated`.
  final bool Function(String bossId) isBossDefeated;

  List<Topic> _topics = [];
  bool _isLoading = false;
  String? _error;

  RoadmapViewModel(
    this._repository, {
    this.campaignId,
    bool Function(String bossId)? isBossDefeated,
  }) : isBossDefeated = isBossDefeated ?? ((_) => false);

  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRoadmap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topics = await _repository.getDartRoadmap(campaignId: campaignId);
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
      return await _repository.getTopicWithDetail(topicId,
          campaignId: campaignId);
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
    if (_findTopic(topicId) == null) return;
    _updateTopic(topicId, (topic) => topic.copyWith(status: status));
    _repository.updateTopicStatus(topicId, status);

    if (status == TopicStatus.completed) {
      _repository.unlockNextTopic(topicId);
      _unlockDependentTopics(topicId);
    }
  }

  /// Applica i topic completati ripristinati dal save (F5, US-05):
  /// segna ciascuno come completato e ricalcola gli unlock a catena.
  /// Gli id sconosciuti vengono ignorati.
  void applyCompletedTopics(Iterable<String> completedTopicIds) {
    for (final topicId in completedTopicIds) {
      updateTopicStatus(topicId, TopicStatus.completed);
    }
  }

  /// Torna allo stato iniziale (Nuovo percorso / Reset): ricarica dal
  /// repository, i cui dati seed non vengono mai mutati dal ViewModel.
  Future<void> resetToInitial() => loadRoadmap();

  /// Finale campagna (Fase 1B-A): true se tutti i capitoli sono
  /// interamente completati E tutti i boss sono sconfitti. Di default
  /// usa il lookup [isBossDefeated] del ViewModel (le vittorie reali).
  bool isCampaignComplete([bool Function(String bossId)? defeated]) {
    final isDefeated = defeated ?? isBossDefeated;
    for (final chapterId in chapterIds) {
      final chapter = _findTopic(chapterId);
      if (chapter == null || !chapter.isChapterComplete) return false;
    }
    for (final bossId in campaignBossIds) {
      if (!isDefeated(bossId)) return false;
    }
    return true;
  }

  /// Ricalcola gli unlock su tutti i topic locked (gate di campagna):
  /// chiamato al rientro dalla vittoria contro un boss, quando i
  /// `requiredBossId` possono essersi sbloccati senza nuove completion.
  void reevaluateUnlocks() {
    var changed = false;
    _topics = _updateTopicsRecursive(_topics, (topic) {
      if (topic.status == TopicStatus.locked && _unlockConditionsMet(topic)) {
        changed = true;
        return topic.copyWith(status: TopicStatus.inProgress);
      }
      return topic;
    });
    if (changed) notifyListeners();
  }

  /// True se il topic locked può aprirsi: prerequisiti completati +
  /// eventuale boss richiesto sconfitto.
  bool _unlockConditionsMet(Topic topic) {
    final allPrerequisitesMet = topic.prerequisites.every((prereqId) {
      final prereq = _findTopic(prereqId);
      return prereq?.isCompleted ?? false;
    });
    if (!allPrerequisitesMet) return false;
    final requiredBoss = topic.requiredBossId;
    if (requiredBoss != null && !isBossDefeated(requiredBoss)) return false;
    return true;
  }

  void _unlockDependentTopics(String completedTopicId) {
    _topics = _updateTopicsRecursive(_topics, (topic) {
      if (topic.prerequisites.contains(completedTopicId) &&
          topic.status == TopicStatus.locked &&
          _unlockConditionsMet(topic)) {
        return topic.copyWith(status: TopicStatus.inProgress);
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
