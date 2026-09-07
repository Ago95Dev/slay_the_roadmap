import 'package:flutter/material.dart';
import '../models/types.dart';

class TopicNode extends StatelessWidget {
  final Topic topic;
  final int depth;
  final Function(Topic) onTopicTap;
  final Function(String) onToggleExpansion;

  const TopicNode({
    super.key,
    required this.topic,
    required this.depth,
    required this.onTopicTap,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtopics = topic.subtopics.isNotEmpty;
    final indent = depth * 21.0; // Golden ratio: 21

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: indent, bottom: 8), // 8 is approx 13/1.618
          child: InkWell(
            onTap: () => onTopicTap(topic),
            borderRadius: BorderRadius.circular(13), // Golden ratio: 13
            child: Container(
              padding: const EdgeInsets.all(13), // Golden ratio: 13
              decoration: BoxDecoration(
                color: _getCardColor(topic.status),
                borderRadius: BorderRadius.circular(13), // Golden ratio: 13
                border: Border.all(
                  color: _getBorderColor(topic.status),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5, // 5 is approx 8/1.618
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Status Icon
                  _buildStatusIcon(topic.status),
                  const SizedBox(width: 13), // Golden ratio: 13
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                topic.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getTitleColor(topic.status),
                                  fontSize: 21, // Golden ratio: 21 (was 16)
                                ),
                              ),
                            ),
                            if (topic.type == TopicType.core)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                                ),
                                child: const Text(
                                  'CORE',
                                  style: TextStyle(
                                    fontSize: 8, // Golden ratio: 8
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (topic.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            topic.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _getSubtitleColor(topic.status),
                              fontSize: 13, // Golden ratio: 13 (was 12)
                            ),
                          ),
                        ],
                        // Rewards badge (mocked as x1 card)
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.style, size: 13, color: Colors.black54), // Golden ratio: 13
                              const SizedBox(width: 5),
                              Text(
                                'x1',
                                style: TextStyle(
                                  fontSize: 13, // Golden ratio: 13
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse button
                  if (hasSubtopics)
                    IconButton(
                      icon: Icon(
                        topic.isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _getIconColor(topic.status),
                        size: 21, // Golden ratio: 21
                      ),
                      onPressed: () => onToggleExpansion(topic.id),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Subtopics
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
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
      case TopicStatus.inProgress:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
        );
      case TopicStatus.locked:
        return const Icon(Icons.lock, color: Colors.grey, size: 20);
      case TopicStatus.skipped:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fast_forward, color: Colors.white, size: 16),
        );
    }
  }

  Color _getTitleColor(TopicStatus status) {
    return status == TopicStatus.locked ? Colors.grey : Colors.black87;
  }

  Color _getSubtitleColor(TopicStatus status) {
    return status == TopicStatus.locked ? Colors.grey[400]! : Colors.grey[600]!;
  }

  Color _getIconColor(TopicStatus status) {
    return status == TopicStatus.locked ? Colors.grey : Colors.black54;
  }

  Color _getCardColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green.shade50;
      case TopicStatus.inProgress:
        return Colors.orange.shade50;
      case TopicStatus.locked:
        return Colors.grey.shade100;
      case TopicStatus.skipped:
        return Colors.grey.shade200;
    }
  }

  Color _getBorderColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.completed:
        return Colors.green.shade200;
      case TopicStatus.inProgress:
        return Colors.orange.shade200;
      case TopicStatus.locked:
        return Colors.grey.shade300;
      case TopicStatus.skipped:
        return Colors.grey.shade400;
    }
  }
}
