import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/relics_data.dart';
import '../models/types.dart';

class RelicCollectionWidget extends StatelessWidget {
  const RelicCollectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final ownedRelics = gameProvider.relics;

    if (ownedRelics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Relics Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Defeat bosses and complete dungeon runs to collect powerful relics!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final groupedRelics = <CardRarity, List<Relic>>{
      CardRarity.legendary: relicsData.where((r) => r.rarity == CardRarity.legendary && ownedRelics.contains(r.id)).toList(),
      CardRarity.epic: relicsData.where((r) => r.rarity == CardRarity.epic && ownedRelics.contains(r.id)).toList(),
      CardRarity.rare: relicsData.where((r) => r.rarity == CardRarity.rare && ownedRelics.contains(r.id)).toList(),
      CardRarity.common: relicsData.where((r) => r.rarity == CardRarity.common && ownedRelics.contains(r.id)).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in groupedRelics.entries)
          if (entry.value.isNotEmpty) ...[
            _RaritySection(
              rarity: entry.key,
              relics: entry.value,
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}

class _RaritySection extends StatelessWidget {
  final CardRarity rarity;
  final List<Relic> relics;

  const _RaritySection({
    required this.rarity,
    required this.relics,
  });

  Color _getRarityColor() {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.amber;
    }
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'visibility': Icons.visibility,
      'menu_book': Icons.menu_book,
      'local_cafe': Icons.local_cafe,
      'verified_user': Icons.verified_user,
      'restore': Icons.restore,
      'storage': Icons.storage,
      'auto_awesome': Icons.auto_awesome,
      'flash_on': Icons.flash_on,
      'favorite': Icons.favorite,
      'layers': Icons.layers,
      'memory': Icons.memory,
    };
    return iconMap[iconName] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRarityColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${rarity.name.toUpperCase()} RELICS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${relics.length}'),
              visualDensity: VisualDensity.compact,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: relics.length,
          itemBuilder: (context, index) {
            final relic = relics[index];
            return _RelicCard(
              relic: relic,
              color: color,
              icon: _getIconData(relic.icon),
            );
          },
        ),
      ],
    );
  }
}

class _RelicCard extends StatelessWidget {
  final Relic relic;
  final Color color;
  final IconData icon;

  const _RelicCard({
    required this.relic,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    relic.rarity.name[0].toUpperCase(),
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
            Text(
              relic.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              relic.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
