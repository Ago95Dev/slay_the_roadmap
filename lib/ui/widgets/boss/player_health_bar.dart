import 'package:flutter/material.dart';

class PlayerHealthBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;

  const PlayerHealthBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = currentHp / maxHp;
    final Color barColor = _getHealthColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Player label and HP text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 4),
                Text(
                  'Your HP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '$currentHp / $maxHp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // HP bar
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Background
                Container(
                  color: Colors.grey[300],
                ),
                
                // HP fill
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // HP text overlay
                Center(
                  child: Text(
                    '$currentHp HP',
                    style: TextStyle(
                      color: percentage > 0.3 ? Colors.white : barColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      shadows: percentage > 0.3
                          ? [
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) {
      return Colors.green;
    } else if (percentage > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
