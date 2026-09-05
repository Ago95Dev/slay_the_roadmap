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
    );
  }

  bool get canStart => status == TopicStatus.inProgress;
  bool get isCompleted => status == TopicStatus.completed;
  bool get isLocked => status == TopicStatus.locked;
  bool get hasDetail => detail != null;

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
  ];
}
