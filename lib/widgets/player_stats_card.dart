import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class PlayerStatsCard extends StatelessWidget {
  const PlayerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final stats = gameProvider.playerStats;
    final xpNeeded = 100 + (stats.level * 100);
    final xpProgress = stats.experience / xpNeeded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Level
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${stats.level}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // XP Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XP: ${stats.experience} / $xpNeeded',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.favorite,
                  label: 'HP',
                  value: '${stats.currentHp}/${stats.maxHp}',
                  color: Colors.red,
                ),
                _StatItem(
                  icon: Icons.flash_on,
                  label: 'Energy',
                  value: '${stats.maxEnergy}',
                  color: Colors.amber,
                ),
                _StatItem(
                  icon: Icons.shield,
                  label: 'Armor',
                  value: '${stats.armor}',
                  color: Colors.blue,
                ),
                _StatItem(
                  icon: Icons.style,
                  label: 'Cards',
                  value: '${gameProvider.inventory.length}',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
