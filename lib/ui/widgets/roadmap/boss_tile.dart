import 'package:flutter/material.dart';
import '../../../domain/models/topic.dart';
import '../../animations/dungeon_motion.dart';

/// Nodo boss a fine capitolo (campagna US-04): stile coerente coi
/// [TopicTile] (stesso ListTile + margine di livello), icona boss e
/// lucentezza rossa quando sfidabile, lucchetto grigio quando il capitolo
/// non è ancora interamente completato.
class BossTile extends StatelessWidget {
  final Topic chapter;
  final int level;
  final bool isUnlocked;
  final bool isDefeated;
  final void Function(String bossId, String chapterId) onTap;

  const BossTile({
    super.key,
    required this.chapter,
    required this.level,
    required this.isUnlocked,
    required this.isDefeated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bossName = chapter.bossName ?? 'Boss';
    // Lo sfondo vive sul Material (non su un DecoratedBox intermedio)
    // così gli ink splash del ListTile restano visibili.
    return PressableScale(
      child: Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: Material(
          color: isUnlocked
              ? Colors.red.withValues(alpha: 0.08)
              : Colors.transparent,
          shape: isUnlocked
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.4),
                  ),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
          child: ListTile(
            key: Key('boss_tile_${chapter.bossId}'),
            leading: Icon(
              isDefeated
                  ? Icons.check_circle
                  : isUnlocked
                      ? Icons.sports_martial_arts
                      : Icons.lock,
              color: isDefeated
                  ? Colors.green
                  : isUnlocked
                      ? Colors.red
                      : Colors.grey,
              size: 24,
            ),
            title: Text(
              '👹 $bossName',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.red[800] : Colors.grey,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              isDefeated
                  ? 'Sconfitto! Capitolo completato'
                  : isUnlocked
                      ? 'Boss finale — sconfiggilo per aprire il capitolo dopo'
                      : 'Completa tutti i topic del capitolo per sfidarlo',
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isDefeated
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.red : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BOSS',
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.grey[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            onTap: () => onTap(chapter.bossId!, chapter.id),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
      ),
    );
  }
}
