import 'package:equatable/equatable.dart';
import 'topic_detail.dart';

enum TopicStatus { locked, inProgress, completed }

class Topic extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isOptional;
  final List<Topic> subtopics;
  final TopicStatus status;
  final bool isExpanded;
  final List<String> prerequisites;
  final String? quizId;
  final TopicDetail? detail;

  /// Boss finale di capitolo (campagna US-04): solo sui capitoli root.
  /// `bossId` referenzia il boss in [BossRepository], `bossName` è il
  /// nome mostrato nel nodo boss a fine capitolo.
  final String? bossId;
  final String? bossName;

  /// Boss che deve essere sconfitto prima di sbloccare questo topic
  /// (gate di campagna: il capitolo dopo si apre solo dopo la vittoria).
  final String? requiredBossId;

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    this.isOptional = false,
    this.subtopics = const [],
    this.status = TopicStatus.locked,
    this.isExpanded = false,
    this.prerequisites = const [],
    this.quizId,
    this.detail,
    this.bossId,
    this.bossName,
    this.requiredBossId,
  });

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    bool? isOptional,
    List<Topic>? subtopics,
    TopicStatus? status,
    bool? isExpanded,
    List<String>? prerequisites,
    String? quizId,
    TopicDetail? detail,
    String? bossId,
    String? bossName,
    String? requiredBossId,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isOptional: isOptional ?? this.isOptional,
      subtopics: subtopics ?? this.subtopics,
      status: status ?? this.status,
      isExpanded: isExpanded ?? this.isExpanded,
      prerequisites: prerequisites ?? this.prerequisites,
      quizId: quizId ?? this.quizId,
      detail: detail ?? this.detail,
      bossId: bossId ?? this.bossId,
      bossName: bossName ?? this.bossName,
      requiredBossId: requiredBossId ?? this.requiredBossId,
    );
  }

  bool get canStart => status == TopicStatus.inProgress;
  bool get isCompleted => status == TopicStatus.completed;
  bool get isLocked => status == TopicStatus.locked;
  bool get hasDetail => detail != null;

  /// True se il capitolo (root + sotto-topic non opzionali) è interamente
  /// completato: il boss finale diventa sfidabile.
  bool get isChapterComplete {
    if (!isCompleted) return false;
    return _allRequiredSubtopicsCompleted(subtopics);
  }

  static bool _allRequiredSubtopicsCompleted(List<Topic> topics) {
    for (final t in topics) {
      // I topic opzionali (e i loro sotto-alberi) non bloccano il boss.
      if (t.isOptional) continue;
      if (!t.isCompleted) return false;
      if (!_allRequiredSubtopicsCompleted(t.subtopics)) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isOptional,
    subtopics,
    status,
    isExpanded,
    prerequisites,
    quizId,
    detail,
    bossId,
    bossName,
    requiredBossId,
  ];
}
