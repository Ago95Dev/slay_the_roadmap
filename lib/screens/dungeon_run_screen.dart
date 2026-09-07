import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/dungeon_map_widget.dart';

class DungeonRunScreen extends StatelessWidget {
  const DungeonRunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final dungeonRun = gameProvider.dungeonRun;

    if (dungeonRun == null || !dungeonRun.active) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dungeon Run')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No active dungeon run'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Start new dungeon run
                  Navigator.pop(context);
                },
                child: const Text('Return to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = dungeonRun.playerStats;
    final hpPercent = (stats.currentHp / stats.maxHp * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(
        title: Text('Floor ${dungeonRun.floor}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _showAbandonDialog(context, gameProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatBar(
                        icon: Icons.favorite,
                        label: 'HP',
                        value: '${stats.currentHp} / ${stats.maxHp}',
                        percent: hpPercent / 100,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.flash_on,
                      label: '${stats.currentEnergy}',
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.shield,
                      label: '${stats.armor}',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.emoji_events,
                      label: '${dungeonRun.reputation}',
                      color: Colors.purple,
                    ),
                  ],
                ),
                if (dungeonRun.relics.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: dungeonRun.relics
                        .take(3)
                        .map((id) => Chip(
                              label: Text(
                                id,
                                style: const TextStyle(fontSize: 10),
                              ),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // Dungeon Map
          Expanded(
            child: DungeonMapWidget(
              dungeonRun: dungeonRun,
              onRoomSelect: (roomId) {
                // Handle room selection
                _showRoomDialog(context, roomId);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAbandonDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Run?'),
        content: const Text(
          'Are you sure you want to abandon this dungeon run? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.completeDungeonRun(false);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }

  void _showRoomDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Room?'),
        content: const Text('Ready to face the challenge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to room challenge
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double percent;
  final Color color;

  const _StatBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$label: $value',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
