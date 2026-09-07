import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_provider.dart';

class RunHistoryWidget extends StatelessWidget {
  const RunHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final runHistory = gameProvider.runHistory;

    if (runHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Runs Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first dungeon run to start building your history!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final stats = {
      'totalRuns': runHistory.length,
      'victories': runHistory.where((r) => r.victory).length,
      'defeats': runHistory.where((r) => !r.victory).length,
      'highestFloor': runHistory.map((r) => r.floor).reduce((a, b) => a > b ? a : b),
      'highestScore': runHistory.map((r) => r.finalScore).reduce((a, b) => a > b ? a : b),
    };

    final winRate = stats['totalRuns']! > 0
        ? ((stats['victories']! / stats['totalRuns']!) * 100).toStringAsFixed(1)
        : '0.0';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Stats
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _StatCard(
              icon: Icons.trending_up,
              label: 'Total Runs',
              value: '${stats['totalRuns']}',
              color: Colors.blue,
            ),
            _StatCard(
              icon: Icons.emoji_events,
              label: 'Win Rate',
              value: '$winRate%',
              color: Colors.amber,
            ),
            _StatCard(
              icon: Icons.elevator,
              label: 'Highest Floor',
              value: '${stats['highestFloor']}',
              color: Colors.purple,
            ),
            _StatCard(
              icon: Icons.star,
              label: 'High Score',
              value: '${stats['highestScore']}',
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Runs',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...runHistory.reversed.take(10).map((run) => _RunHistoryCard(run: run)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class _RunHistoryCard extends StatelessWidget {
  final run;

  const _RunHistoryCard({required this.run});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: run.victory ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: run.victory ? Colors.green : Colors.red),
                    image: DecorationImage(
                      image: AssetImage('assets/images/${run.playerClass.toLowerCase()}.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  run.victory ? 'Victory' : 'Defeat',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('Floor ${run.floor}'),
                  visualDensity: VisualDensity.compact,
                ),
                if (run.ascensionLevel > 0) ...[
                  const SizedBox(width: 4),
                  Chip(
                    label: Text('A${run.ascensionLevel}'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.red[100],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _RunStat(label: 'Score', value: '${run.finalScore}'),
                _RunStat(label: 'Cards', value: '${run.cardsCollected}'),
                _RunStat(label: 'Elites', value: '${run.elitesDefeated}'),
                _RunStat(label: 'Bosses', value: '${run.bossesDefeated}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(run.completedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunStat extends StatelessWidget {
  final String label;
  final String value;

  const _RunStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
