import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import '../data/cards_data.dart';
import 'tiny_card_widget.dart';

class ActiveDeckWidget extends StatelessWidget {
  final bool showClearButton;
  final bool isEditable;

  const ActiveDeckWidget({
    super.key,
    this.showClearButton = true,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final activeDeck = gameProvider.activeDeck;

    List<CardModel> deckCards = activeDeck
        .map((id) => getCardById(id))
        .where((card) => card != null)
        .cast<CardModel>()
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE DECK (${deckCards.length} cards)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: activeDeck.length >= 12 ? Colors.green.shade300 : Colors.orange.shade300,
                  letterSpacing: 0.5,
                ),
              ),
              if (deckCards.isNotEmpty && showClearButton && isEditable)
                TextButton.icon(
                  onPressed: () {
                    gameProvider.updateActiveDeck([]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deck cleared'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_all, size: 14),
                  label: const Text('Clear All', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: deckCards.isEmpty
                ? Center(
                    child: Text(
                      'Tap cards below to add them to your deck (min 12)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: deckCards.length,
                    itemBuilder: (context, index) {
                      final card = deckCards[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 60,
                          child: TinyCardWidget(
                            card: card,
                            isInDeck: true,
                            countInDeck: 1,
                            showCount: false,
                            onTap: () {
                              if (!isEditable) return;
                              
                              // Remove this specific instance from deck
                              final newDeck = List<String>.from(activeDeck);
                              newDeck.removeAt(index);
                              gameProvider.updateActiveDeck(newDeck);
                              
                              if (newDeck.length < 12) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('⚠️ Deck needs min 12 cards (${newDeck.length}/12)'),
                                    duration: const Duration(milliseconds: 1000),
                                    backgroundColor: Colors.orange.shade700,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
