import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import '../utils/app_theme.dart';
import 'tiny_card_widget.dart';

class CardDetailDialog extends StatelessWidget {
  final String uniqueId;
  final bool isOwned;

  const CardDetailDialog({
    super.key,
    required this.uniqueId,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final card = gameProvider.getCardInstance(uniqueId);

    if (card == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF444444), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CARD DETAILS',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Card Display
            SizedBox(
              height: 350,
              width: 240,
              child: TinyCardWidget(
                card: card,
                isInDeck: false,
                showCount: false,
                useLargeRarityGem: true,
                scaleDescription: true, // Use larger font for description
              ),
            ),

            const SizedBox(height: 24),

            // Upgrade Options (Only if owned)
            if (isOwned) ...[
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'UPGRADES (Gold: ${gameProvider.gold})',
                style: const TextStyle(
                  color: Color(0xFFd4af37),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Upgrade Damage
              if (card.type == CardType.attack)
                _UpgradeButton(
                  label: 'Upgrade Damage (+2)',
                  cost: 50,
                  icon: Icons.flash_on,
                  color: Colors.red[700]!,
                  onTap: () {
                    if (gameProvider.spendGold(50)) {
                      gameProvider.upgradeCard(uniqueId, 'damage');
                    } else {
                      _showInsufficientGold(context);
                    }
                  },
                ),

              // Upgrade Block
              if (card.type == CardType.defense || card.effects?.any((e) => e.type == 'block') == true)
                _UpgradeButton(
                  label: 'Upgrade Block (+2)',
                  cost: 50,
                  icon: Icons.shield,
                  color: Colors.blue[700]!,
                  onTap: () {
                    if (gameProvider.spendGold(50)) {
                      gameProvider.upgradeCard(uniqueId, 'block');
                    } else {
                      _showInsufficientGold(context);
                    }
                  },
                ),

              // Promote Rarity
              if (card.rarity != CardRarity.legendary)
                _UpgradeButton(
                  label: 'Promote Rarity',
                  cost: 150,
                  icon: Icons.auto_awesome,
                  color: Colors.purple[700]!,
                  onTap: () {
                    if (gameProvider.spendGold(150)) {
                      gameProvider.upgradeCard(uniqueId, 'rarity');
                    } else {
                      _showInsufficientGold(context);
                    }
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInsufficientGold(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not enough Gold!'),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  final String label;
  final int cost;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _UpgradeButton({
    required this.label,
    required this.cost,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('$cost', style: const TextStyle(fontSize: 12, color: Color(0xFFd4af37))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
