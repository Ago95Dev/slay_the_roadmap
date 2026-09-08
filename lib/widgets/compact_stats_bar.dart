import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/player_progress.dart';
import '../providers/game_provider.dart';
import '../screens/deck_builder_screen.dart';
import '../screens/skill_tree_screen.dart';
import '../screens/profile_screen.dart';

class CompactStatsBar extends StatelessWidget {
  const CompactStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final completedCount = gameProvider.completedTopics.length;
    const totalTopics = 15; // Could be dynamic based on selected path
    final playerStats = gameProvider.playerStats;

    // Fase 2: HUD unica fonte PlayerProgress.levelForXp (soglie 0/100/500).
    // L1: xp/100; L2: (xp-100)/400; L3: piena. Numeri = XP locali.
    final hudLevel = PlayerProgress.levelForXp(playerStats.experience);
    final int? hudNext = hudLevel >= PlayerProgress.maxLevel
        ? null
        : (hudLevel == 1
            ? PlayerProgress.level2Threshold
            : PlayerProgress.level3Threshold);
    final double xpPercent = hudNext == null
        ? 1.0
        : hudLevel == 1
            ? (playerStats.experience / hudNext).clamp(0.0, 1.0)
            : ((playerStats.experience - PlayerProgress.level2Threshold) /
                    (PlayerProgress.level3Threshold -
                        PlayerProgress.level2Threshold))
                .clamp(0.0, 1.0);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Profile & Progress
          Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                      image: DecorationImage(
                        image: AssetImage('assets/images/${playerStats.playerClass.toLowerCase()}.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    playerStats.playerClass.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),

          const SizedBox(width: 8),

          // Gold Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
              color: Colors.amber.shade100,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${gameProvider.gold}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Center: XP Bar (Replacing Path Title)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LVL $hudLevel',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      hudNext == null
                          ? 'XP ${playerStats.experience} (MAX)'
                          : 'XP ${playerStats.experience}/$hudNext',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: Navigation Buttons (Roadmap, Deck, Skill)
          
          // Roadmap Button
          _IconButtonWithLabel(
            icon: Icons.map,
            label: 'ROADMAP',
            onTap: () {
              // Navigate to HomeScreen which holds the Roadmap
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          const SizedBox(width: 8),

          _IconButtonWithLabel(
            icon: Icons.style,
            label: 'DECK',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeckBuilderScreen()),
              );
            },
          ),

          const SizedBox(width: 8),

          _IconButtonWithLabel(
            icon: Icons.auto_awesome,
            label: 'SKILL',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillTreeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconButtonWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconButtonWithLabel({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// Custom painter for zigzag decoration
class _ZigzagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const zigzagWidth = 10.0;
    final count = (size.width / zigzagWidth).floor();

    path.moveTo(0, 0);
    for (int i = 0; i < count; i++) {
      final x = i * zigzagWidth;
      if (i.isEven) {
        path.lineTo(x + zigzagWidth / 2, size.height);
      } else {
        path.lineTo(x + zigzagWidth / 2, 0);
      }
    }
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
