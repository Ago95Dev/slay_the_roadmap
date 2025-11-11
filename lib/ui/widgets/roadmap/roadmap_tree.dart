import 'package:flutter/material.dart';
import '../../../domain/models/topic.dart';
import 'topic_tile.dart';

/// Roadmap tree widget.
/// Renders a tree view of the roadmap topics for UI consumption.
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
        return TopicTile(
          topic: topics[index],
          depth: 0,
          onTap: onTopicTap,
          onExpand: onTopicExpand,
        );
      },
    );
  }
}
