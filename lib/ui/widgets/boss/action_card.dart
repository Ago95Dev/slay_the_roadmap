import 'package:flutter/material.dart';
import '../../../domain/models/reward.dart';

class ActionCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback onTap;
  final bool isEnabled;

  const ActionCard({
    super.key,
    required this.reward,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Card(
        elevation: isEnabled ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getRarityColor(),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getRarityColor().withValues(alpha: 0.1),
                  _getRarityColor().withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Rarity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reward.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRarityText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Card name
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Card description
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (reward.rarity) {
      case RewardRarity.common:
        return Colors.grey;
      case RewardRarity.rare:
        return Colors.blue;
      case RewardRarity.epic:
        return Colors.purple;
      case RewardRarity.legendary:
        return Colors.amber;
    }
  }

  String _getRarityText() {
    switch (reward.rarity) {
      case RewardRarity.common:
        return 'COMMON';
      case RewardRarity.rare:
        return 'RARE';
      case RewardRarity.epic:
        return 'EPIC';
      case RewardRarity.legendary:
        return 'LEGENDARY';
    }
  }

  Color _getTypeColor() {
    switch (reward.type) {
      case RewardType.attack:
        return Colors.red;
      case RewardType.defense:
        return Colors.blue;
      case RewardType.utility:
        return Colors.green;
      case RewardType.special:
        return Colors.purple;
    }
  }

  String _getTypeText() {
    switch (reward.type) {
      case RewardType.attack:
        return '⚔️ ATTACK';
      case RewardType.defense:
        return '🛡️ DEFENSE';
      case RewardType.utility:
        return '🔧 UTILITY';
      case RewardType.special:
        return '✨ SPECIAL';
    }
  }
}
