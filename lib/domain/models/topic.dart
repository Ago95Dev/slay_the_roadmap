class Topic {
  final String id;
  final String title;
  final String description;
  final TopicType type;
  final List<Topic> subtopics;
  final TopicStatus status;
  final bool isExpanded;
  final List<String> prerequisites;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    this.type = TopicType.core,
    this.subtopics = const [],
    this.status = TopicStatus.locked,
    this.isExpanded = false,
    this.prerequisites = const [],
  });

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    TopicType? type,
    List<Topic>? subtopics,
    TopicStatus? status,
    bool? isExpanded,
    List<String>? prerequisites,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      subtopics: subtopics ?? this.subtopics,
      status: status ?? this.status,
      isExpanded: isExpanded ?? this.isExpanded,
      prerequisites: prerequisites ?? this.prerequisites,
    );
  }
}

enum TopicStatus { locked, inProgress, completed }
enum TopicType { core, optional }
