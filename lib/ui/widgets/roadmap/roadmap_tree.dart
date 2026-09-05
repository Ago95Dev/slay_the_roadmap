import 'package:flutter/material.dart';
import '../../../domain/models/topic.dart';
import 'topic_tile.dart'; // Import necessario

class RoadmapTree extends StatelessWidget {
  final List<Topic> topics;
  final Function(String) onTopicTap;
  final Function(String) onTopicExpand;
  final int level;

  const RoadmapTree({
    super.key,
    required this.topics,
    required this.onTopicTap,
    required this.onTopicExpand,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final topic in topics)
          TopicTile(
            topic: topic,
            level: level,
            onTap: onTopicTap,
            onExpand: onTopicExpand,
          ),
      ],
    );
  }
}
