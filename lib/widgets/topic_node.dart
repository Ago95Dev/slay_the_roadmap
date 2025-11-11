/// Topic node widget.
/// Visual representation of a single node in the roadmap tree (positioning, connectors).

import 'package:flutter/material.dart';
import '../models/roadmap_models.dart';

class TopicNode extends StatelessWidget {
  final Topic topic;
  final int depth;
  final Function(Topic) onTopicTap;
  final Function(String) onToggleExpansion;

  const TopicNode({
    Key? key,
    required this.topic,
    required this.depth,
    required this.onTopicTap,
    required this.onToggleExpansion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasSubtopics = topic.subtopics.isNotEmpty;
    final indent = depth * 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: indent),
          child: Card(
            color: _getCardColor(topic.status),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              leading: _buildStatusIcon(topic.status),
              title: Row(
                children: [
                  _buildTypeIndicator(topic.type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getTitleColor(topic.status),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: topic.description.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        topic.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _getSubtitleColor(topic.status),
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
              trailing: hasSubtopics
                  ? IconButton(
                      icon: Icon(
                        topic.isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _getIconColor(topic.status),
                      ),
                      onPressed: () => onToggleExpansion(topic.id),
                    )
                  : null,
              onTap: () => onTopicTap(topic),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (hasSubtopics && topic.isExpanded)
          Column(
            children: topic.subtopics.map((subtopic) {
              return TopicNode(
                topic: subtopic,
                depth: depth + 1,
                onTopicTap: onTopicTap,
                onToggleExpansion: onToggleExpansion,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TopicStatus.inProgress:
        return const Icon(Icons.play_circle_fill, color: Colors.orange);
      case TopicStatus.locked:
        return const Icon(Icons.lock, color: Colors.grey);
    }
  }

  Widget _buildTypeIndicator(TopicType type) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: type == TopicType.core ? Colors.blue : Colors.purple,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getTitleColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green[800]!;
      case TopicStatus.inProgress:
        return Colors.orange[800]!;
      case TopicStatus.locked:
        return Colors.grey[600]!;
    }
  }

  Color _getSubtitleColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green[600]!;
      case TopicStatus.inProgress:
        return Colors.orange[600]!;
      case TopicStatus.locked:
        return Colors.grey[500]!;
    }
  }

  Color _getIconColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green[800]!;
      case TopicStatus.inProgress:
        return Colors.orange[800]!;
      case TopicStatus.locked:
        return Colors.grey[600]!;
    }
  }

  Color _getCardColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green[50]!;
      case TopicStatus.inProgress:
        return Colors.orange[50]!;
      case TopicStatus.locked:
        return Colors.grey[100]!;
    }
  }
}
