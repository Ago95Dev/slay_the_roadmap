import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/cards_data.dart';
import '../models/types.dart';
import '../utils/app_theme.dart';
import 'tiny_card_widget.dart';
import 'card_detail_dialog.dart';

class CardCompendiumWidget extends StatefulWidget {
  const CardCompendiumWidget({super.key});

  @override
  State<CardCompendiumWidget> createState() => _CardCompendiumWidgetState();
}

class _CardCompendiumWidgetState extends State<CardCompendiumWidget> {
  CardRarity? _filterRarity;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final inventory = gameProvider.inventory;
    
    // Extract base IDs from inventory to determine collection status
    final collectedBaseIds = inventory.map((id) => id.split(':')[0]).toSet();

    // Sort cards: Rarity -> Name
    final sortedCards = List<CardModel>.from(allCards);
    sortedCards.sort((a, b) {
      final rarityCompare = b.rarity.index.compareTo(a.rarity.index);
      if (rarityCompare != 0) return rarityCompare;
      return a.name.compareTo(b.name);
    });

    // Filter cards
    final filteredCards = sortedCards.where((card) {
      if (_filterRarity != null && card.rarity != _filterRarity) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Header / Stats
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CARD LIBRARY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${collectedBaseIds.length} / ${allCards.length} Discovered',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterRarity == null,
                  onTap: () => setState(() => _filterRarity = null),
                ),
                const SizedBox(width: 6),
                ...CardRarity.values.map((rarity) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: rarity.name.substring(0, 1).toUpperCase(),
                      color: AppTheme.getRarityColor(rarity.name),
                      isSelected: _filterRarity == rarity,
                      onTap: () => setState(() => _filterRarity = rarity),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        // Grid
        Expanded(
          child: filteredCards.isEmpty
              ? Center(
                  child: Text(
                    'No cards found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // 8 columns
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    final isCollected = collectedBaseIds.contains(card.id);

                    Widget cardWidget = TinyCardWidget(
                      card: card,
                      isInDeck: false,
                      showCount: false,
                      useLargeRarityGem: true,
                      scaleDescription: true, // Larger font for library
                      onSecondaryTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CardDetailDialog(
                            uniqueId: card.id, // Base ID
                            isOwned: false, // Library view doesn't allow upgrades
                          ),
                        );
                      },
                    );

                    if (!isCollected) {
                      // Grayscale filter for uncollected cards
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: Opacity(
                          opacity: 0.6,
                          child: cardWidget,
                        ),
                      );
                    }

                    return cardWidget;
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF666666);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
