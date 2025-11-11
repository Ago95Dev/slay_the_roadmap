import 'package:equatable/equatable.dart';

class TopicDetail extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<LearningLink> links;
  final String? quizId;

  const TopicDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.links,
    this.quizId,
  });

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    return TopicDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      quizId: json['quizId'],
      links: (json['links'] as List)
          .map((link) => LearningLink.fromJson(link))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quizId': quizId,
      'links': links.map((link) => link.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, description, links, quizId];
}

class LearningLink extends Equatable {
  final String title;
  final String url;
  final LinkType type;

  const LearningLink({
    required this.title,
    required this.url,
    required this.type,
  });

  factory LearningLink.fromJson(Map<String, dynamic> json) {
    return LearningLink(
      title: json['title'],
      url: json['url'],
      type: LinkType.values.firstWhere(
        (e) => e.toString() == 'LinkType.${json['type']}',
        orElse: () => LinkType.article,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type.toString().split('.').last,
    };
  }

  String get icon {
    switch (type) {
      case LinkType.article:
        return '📚';
      case LinkType.video:
        return '🎥';
      case LinkType.documentation:
        return '📄';
      case LinkType.interactive:
        return '🎮';
      case LinkType.exercise:
        return '💪';
    }
  }

  @override
  List<Object?> get props => [title, url, type];
}

enum LinkType {
  article,
  video,
  documentation,
  interactive,
  exercise,
}
