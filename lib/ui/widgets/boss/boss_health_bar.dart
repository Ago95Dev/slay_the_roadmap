import 'package:flutter/material.dart';

class BossHealthBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final String bossName;

  const BossHealthBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    required this.bossName,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = currentHp / maxHp;
    final Color barColor = _getHealthColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Boss name and HP text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bossName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentHp / $maxHp HP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // HP bar container
        Container(
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background
                Container(
                  color: Colors.grey[800],
                ),
                
                // HP fill with animation
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Phase markers (75%, 50%, 25%)
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(flex: 25, child: Container()),
                      Container(width: 2, color: Colors.white.withValues(alpha: 0.3)),
                      Expanded(flex: 25, child: Container()),
                      Container(width: 2, color: Colors.white.withValues(alpha: 0.3)),
                      Expanded(flex: 25, child: Container()),
                      Container(width: 2, color: Colors.white.withValues(alpha: 0.3)),
                      Expanded(flex: 25, child: Container()),
                    ],
                  ),
                ),
                
                // Percentage text overlay
                Center(
                  child: Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Phase indicator
        const SizedBox(height: 4),
        Text(
          _getPhaseText(percentage),
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: barColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.75) {
      return Colors.green;
    } else if (percentage > 0.5) {
      return Colors.lime;
    } else if (percentage > 0.25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getPhaseText(double percentage) {
    if (percentage > 0.75) {
      return '🛡️ Normal Phase';
    } else if (percentage > 0.5) {
      return '⚠️ Aggressive Phase';
    } else if (percentage > 0.25) {
      return '⚡ Enraged Phase';
    } else {
      return '💀 Desperate Phase - DANGER!';
    }
  }
}
