import 'package:flutter/material.dart';

/// HP bar del giocatore con danno/cura animati: il riempimento passa dal
/// vecchio al nuovo valore con Tween (300ms, one-shot). Rispetta
/// `MediaQuery.disableAnimations`.
class PlayerHealthBar extends StatefulWidget {
  final int currentHp;
  final int maxHp;

  const PlayerHealthBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  State<PlayerHealthBar> createState() => _PlayerHealthBarState();
}

class _PlayerHealthBarState extends State<PlayerHealthBar> {
  late double _fromFraction;

  double _fractionOf(int current, int max) {
    if (max <= 0) return 0;
    return (current / max).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _fromFraction = _fractionOf(widget.currentHp, widget.maxHp);
  }

  @override
  void didUpdateWidget(PlayerHealthBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fromFraction = _fractionOf(oldWidget.currentHp, oldWidget.maxHp);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _fractionOf(widget.currentHp, widget.maxHp);
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
              '${widget.currentHp} / ${widget.maxHp}',
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

                // HP fill with animation
                if (MediaQuery.disableAnimationsOf(context))
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: _fill(barColor),
                  )
                else
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _fromFraction,
                      end: percentage,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: _fill(barColor),
                    ),
                  ),

                // HP text overlay
                Center(
                  child: Text(
                    '${widget.currentHp} HP',
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

  Widget _fill(Color barColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            barColor,
            barColor.withValues(alpha: 0.8),
          ],
        ),
      ),
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
