import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import '../data/cards_data.dart';
import '../utils/app_theme.dart';
import '../widgets/compact_stats_bar.dart';
import '../widgets/tiny_card_widget.dart';
import '../widgets/active_deck_widget.dart';
import '../widgets/card_detail_dialog.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  CardRarity? _filterRarity;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final inventory = gameProvider.inventory;
    final activeDeck = gameProvider.activeDeck;

    // For demo purposes, populate inventory with starter cards if empty
    if (inventory.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addStarterDeck(gameProvider);
      });
    }

    // Get unique card types for display (group by ID but keep track of counts)
    Map<String, int> cardCounts = {};
    for (var id in inventory) {
      cardCounts[id] = (cardCounts[id] ?? 0) + 1;
    }
    
    List<CardModel> uniqueInventoryCards = cardCounts.keys
        .map((id) => getCardById(id))
        .where((card) => card != null)
        .cast<CardModel>()
        .toList();

    if (_filterRarity != null) {
      uniqueInventoryCards = uniqueInventoryCards
          .where((card) => card.rarity == _filterRarity)
          .toList();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0806),
            Color(0xFF1a1410),
          ],
        ),
      ),
      child: Column(
        children: [
          // Compact Stats Bar
          const CompactStatsBar(),
          
          // Deck Builder Title Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF2d1b00),
            child: const Center(
              child: Text(
                'DECK BUILDER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af37),
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),

          // ACTIVE DECK SECTION (Marvel Snap style)
          const ActiveDeckWidget(),

          // Filter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  'COLLECTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
              ],
            ),
          ),

          // Collection Grid - Show ALL cards individually
          Expanded(
            child: Builder(
              builder: (context) {
                // 1. Sort Inventory
                final sortedInventory = List<String>.from(inventory);
                sortedInventory.sort((a, b) {
                  final cardA = getCardById(a);
                  final cardB = getCardById(b);
                  if (cardA == null || cardB == null) return 0;
                  
                  // Sort by Rarity (descending)
                  final rarityCompare = cardB.rarity.index.compareTo(cardA.rarity.index);
                  if (rarityCompare != 0) return rarityCompare;
                  
                  // Then by Name
                  return cardA.name.compareTo(cardB.name);
                });

                // 2. Filter Inventory
                final filteredInventory = sortedInventory.where((uniqueId) {
                  final card = getCardById(uniqueId);
                  if (card == null) return false;
                  if (_filterRarity != null && card.rarity != _filterRarity) return false;
                  return true;
                }).toList();

                if (filteredInventory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style, size: 48, color: Colors.grey[700]),
                        const SizedBox(height: 12),
                        Text(
                          'No cards found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // 8 columns
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: filteredInventory.length,
                  itemBuilder: (context, index) {
                    final uniqueId = filteredInventory[index];
                    final card = gameProvider.getCardInstance(uniqueId); // Use getCardInstance
                    
                    if (card == null) return const SizedBox.shrink();

                    // Check if this specific card instance is in the deck
                    final isInDeck = activeDeck.contains(uniqueId);

                    return TinyCardWidget(
                      card: card,
                      isInDeck: isInDeck,
                      countInDeck: 1, // Always 1 for unique instances
                      showCount: false, // Don't show count badge
                      useLargeRarityGem: true,
                      scaleDescription: true, // Larger font for collection
                      onSecondaryTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CardDetailDialog(
                            uniqueId: uniqueId,
                            isOwned: true,
                          ),
                        );
                      },
                      onTap: () {
                        List<String> newDeck = List.from(activeDeck);
                        
                        if (isInDeck) {
                          // Remove this specific card
                          newDeck.remove(uniqueId);
                          gameProvider.updateActiveDeck(newDeck);
                        } else {
                          // Add this specific card
                          if (newDeck.length < 15) { // Max deck size check
                            newDeck.add(uniqueId);
                            gameProvider.updateActiveDeck(newDeck);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✓ ${card.name} added'),
                                duration: const Duration(milliseconds: 300),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Deck is full (Max 15)'),
                                duration: const Duration(milliseconds: 600),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  void _addStarterDeck(GameProvider gameProvider) {
    // Add some starter cards
    for (var i = 0; i < 5; i++) {
      gameProvider.addCardToInventory('strike');
    }
    for (var i = 0; i < 5; i++) {
      gameProvider.addCardToInventory('defend');
    }
    gameProvider.addCardToInventory('bash');
    gameProvider.addCardToInventory('poison_strike');
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
