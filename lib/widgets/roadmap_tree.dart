import 'package:flutter/material.dart';
import '../models/roadmap_models.dart';
import 'topic_node.dart';

/// Roadmap tree helper widget.
/// Alternative or shared roadmap tree widget used outside the UI/widgets folder.
class RoadmapTree extends StatelessWidget {
  final List<Topic> topics;
  final Function(String) onTopicTap;
  final Function(String) onTopicExpand;

  const RoadmapTree({
    super.key,
    required this.topics,
    required this.onTopicTap,
    required this.onTopicExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicNode(
          topic: topics[index],
          depth: 0,
          onTopicTap: (topic) => onTopicTap(topic.id),
          onToggleExpansion: onTopicExpand,
        );
      },
    );
  }
}
