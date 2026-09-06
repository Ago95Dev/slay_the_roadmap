import 'package:flutter/material.dart';
import '../../../domain/models/topic.dart';
import 'boss_tile.dart';
import 'topic_tile.dart'; // Import necessario

class RoadmapTree extends StatelessWidget {
  final List<Topic> topics;
  final Function(String) onTopicTap;
  final Function(String) onTopicExpand;
  final int level;

  /// Campagna US-04: true se il boss [bossId] è sconfitto (per il badge
  /// "Sconfitto" sul nodo boss). Se null, nessun boss risulta sconfitto.
  final bool Function(String bossId)? isBossDefeated;

  /// Tap sul nodo boss (solo capitoli root con `bossId`): la schermata
  /// chiamante apre `BossFightActiveScreen` diretto.
  final void Function(String bossId, String chapterId)? onBossTap;

  const RoadmapTree({
    super.key,
    required this.topics,
    required this.onTopicTap,
    required this.onTopicExpand,
    this.level = 0,
    this.isBossDefeated,
    this.onBossTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final topic in topics) ...[
          TopicTile(
            topic: topic,
            level: level,
            onTap: onTopicTap,
            onExpand: onTopicExpand,
          ),
          // Nodo boss a fine capitolo: solo root con bossId, sbloccato
          // quando TUTTI i topic (non opzionali) del capitolo sono
          // completed. Niente tap handler → niente nodo (vecchi test ok).
          if (level == 0 && topic.bossId != null && onBossTap != null)
            BossTile(
              chapter: topic,
              level: level,
              isUnlocked: topic.isChapterComplete,
              isDefeated:
                  isBossDefeated?.call(topic.bossId!) ?? false,
              onTap: onBossTap!,
            ),
        ],
      ],
    );
  }
}
