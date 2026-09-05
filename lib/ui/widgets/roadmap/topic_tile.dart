import 'package:flutter/material.dart';
import '../../../domain/models/topic.dart';
import 'roadmap_tree.dart'; // Import per RoadmapTree

class TopicTile extends StatelessWidget {
  final Topic topic;
  final int level;
  final Function(String) onTap;
  final Function(String) onExpand;

  const TopicTile({
    super.key,
    required this.topic,
    required this.level,
    required this.onTap,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: level * 20.0),
          child: ListTile(
            leading: _buildStatusIcon(),
            title: Row(
              children: [
                if (topic.subtopics.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      topic.isExpanded 
                          ? Icons.expand_less 
                          : Icons.expand_more,
                      color: Colors.blue,
                    ),
                    onPressed: () => onExpand(topic.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                Expanded(
                  child: Text(
                    topic.title,
                    style: TextStyle(
                      fontWeight: topic.isOptional 
                          ? FontWeight.normal 
                          : FontWeight.w600,
                      color: _getTitleColor(),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: topic.description.isNotEmpty 
                ? Text(
                    topic.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: _buildTrailing(),
            onTap: () => onTap(topic.id),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        if (topic.isExpanded && topic.subtopics.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: (level + 1) * 20.0),
            child: RoadmapTree(
              topics: topic.subtopics,
              onTopicTap: onTap,
              onTopicExpand: onExpand,
              level: level + 1,
            ),
          ),
      ],
    );
  }

  Color _getTitleColor() {
    switch (topic.status) {
      case TopicStatus.completed:
        return Colors.green;
      case TopicStatus.inProgress:
        return Colors.orange;
      case TopicStatus.locked:
        return Colors.grey;
    }
  }

  Widget _buildStatusIcon() {
    switch (topic.status) {
      case TopicStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case TopicStatus.inProgress:
        return const Icon(Icons.play_circle_fill, color: Colors.orange, size: 24);
      case TopicStatus.locked:
        return const Icon(Icons.lock, color: Colors.grey, size: 24);
    }
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topic.isOptional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'OPZIONALE',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (topic.quizId != null)
          Icon(
            Icons.quiz,
            color: Colors.purple[300],
            size: 20,
          ),
      ],
    );
  }
}
