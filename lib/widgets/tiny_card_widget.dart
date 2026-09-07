import 'package:flutter/material.dart';
import '../models/types.dart';
import '../utils/app_theme.dart';

// Tiny card widget (8 columns) - EMOJI graphics, readable text
class TinyCardWidget extends StatelessWidget {
  final CardModel card;
  final bool isInDeck;
  final int countInDeck;
  final bool showCount;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap; // Right-click support

  final bool useLargeRarityGem;
  final bool scaleDescription; // For larger description text

  const TinyCardWidget({
    super.key,
    required this.card,
    this.isInDeck = false,
    this.countInDeck = 0,
    this.showCount = false,
    this.onTap,
    this.onSecondaryTap,
    this.useLargeRarityGem = false,
    this.scaleDescription = false,
    this.iconData,
  });

  final IconData? iconData;

  Color _getRarityColor() {
    switch (card.rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.orange;
    }
  }

  Color _getClassColor() {
    // Hearthstone-ish class colors based on card type for now
    switch (card.type) {
      case CardType.attack:
        return const Color(0xFF8B0000); // Dark Red
      case CardType.defense:
        return const Color(0xFF00008B); // Dark Blue
      case CardType.utility:
        return const Color(0xFF006400); // Dark Green
      case CardType.knowledge:
        return const Color(0xFF8B5CF6); // Purple for knowledge cards
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final classColor = _getClassColor();

    // Determine image asset based on card type
    String imageAsset = card.imageAsset ?? 
        (card.type == CardType.attack ? 'assets/images/attack.png' : 
         card.type == CardType.defense ? 'assets/images/defense.png' : 
         'assets/images/utility.png');

    return LayoutBuilder(
      builder: (context, constraints) {
        double totalHeight = constraints.maxHeight;
        if (totalHeight.isInfinite) {
            totalHeight = 120.0; // Default height if unconstrained
        }
        final double imageHeight = totalHeight * 0.5; // 50% image height
        final double bannerHeight = 22.0; // Slightly taller for larger text

        return GestureDetector(
          onTap: onTap,
          onSecondaryTap: onSecondaryTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Main Card Shape (The "Backing")
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C), // Dark grey backing
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: isInDeck
                      ? [
                          BoxShadow(
                            color: rarityColor.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : [
                          const BoxShadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                ),
              ),

              // 2. Inner Frame (Class Color)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.3), // Subtle tint
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                ),
              ),

              // 3. Card Image (Top Half - 50%)
              Positioned(
                top: 3,
                left: 3,
                right: 3,
                height: imageHeight - 3, // Subtract top margin
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    border: Border.all(color: Colors.grey[900]!, width: 1),
                    image: iconData == null 
                        ? DecorationImage(
                            image: AssetImage(imageAsset),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: iconData != null 
                      ? Center(
                          child: Icon(
                            iconData,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                      : null,
                ),
              ),

              // 4. Name Banner (Middle) with Rarity Gem
              Positioned(
                top: imageHeight, 
                left: 1,
                right: 1,
                height: bannerHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[900]!, Colors.grey[800]!, Colors.grey[900]!],
                    ),
                    border: Border.symmetric(horizontal: BorderSide(color: Colors.grey[600]!, width: 1)),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rarity Gem (Diamond)
                      Transform.rotate(
                        angle: 0.785398, // 45 degrees
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: rarityColor,
                            shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.black, width: 1),
                            boxShadow: [BoxShadow(color: rarityColor, blurRadius: 2)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Card Name
                      Flexible(
                        child: Text(
                          card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5, // Increased from 9
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 1)],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Description Box (Bottom)
              Positioned(
                top: imageHeight + bannerHeight,
                left: 3,
                right: 3,
                bottom: 3,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    // Dark gothic gradient for knowledge cards (Darkest Dungeon style)
                    gradient: card.type == CardType.knowledge
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF1A0B2E), // Very dark purple (almost black)
                              Color(0xFF2D1B3D), // Dark purple
                              Color(0xFF3D2352), // Medium dark purple
                              Color(0xFF2D1B3D), // Back to dark (vignette effect)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.3, 0.7, 1.0],
                          )
                        : null,
                    color: card.type != CardType.knowledge
                        ? const Color(0xFF2A2A2A).withOpacity(0.9)
                        : null,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                    border: Border.all(
                      color: card.type == CardType.knowledge
                          ? const Color(0xFF7C3AED) // Deep purple border
                          : Colors.grey[800]!,
                      width: 1.5,
                    ),
                    // Dramatic inner shadow (Darkest Dungeon style)
                    boxShadow: card.type == CardType.knowledge
                        ? [
                            const BoxShadow(
                              color: Color(0xFF000000),
                              blurRadius: 4,
                              spreadRadius: -2,
                              offset: Offset(0, 2),
                            ),
                            const BoxShadow(
                              color: Color(0xFF5B21B6),
                              blurRadius: 2,
                              spreadRadius: -1,
                              offset: Offset(0, -1),
                            ),
                          ]
                        : null,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Description
                        Text(
                          card.description,
                          style: TextStyle(
                            fontSize: scaleDescription ? 10.0 : 7.5,
                            color: card.type == CardType.knowledge
                                ? const Color(0xFFE9D5FF) // Light purple tint
                                : Colors.white70,
                            height: 1.1,
                            fontWeight: card.type == CardType.knowledge
                                ? FontWeight.w600
                                : FontWeight.normal,
                            shadows: card.type == CardType.knowledge
                                ? [
                                    const Shadow(
                                      color: Color(0xFF000000),
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: card.flavourText != null ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Flavour text at bottom
                        if (card.flavourText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            card.flavourText!,
                            style: TextStyle(
                              fontSize: scaleDescription ? 8.5 : 6.0,
                              color: const Color(0xFFFFD700), // Brighter gold
                              fontStyle: FontStyle.italic,
                              height: 1.0,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF000000),
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 6. Mana Cost (Top Left) - Larger
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF205080),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[400]!, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 3)],
                  ),
                  child: Center(
                    child: Text(
                      '${card.manaCost}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1)],
                      ),
                    ),
                  ),
                ),
              ),

              // 8. Stats/Effect (Bottom Right)
              if (card.effects != null && card.effects!.isNotEmpty)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: _buildEffectBadge(card.effects!.first),
                ),

              // 9. Count Badge (Top Right)
              if (showCount && countInDeck > 1)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '$countInDeck',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              else if (isInDeck && !showCount)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEffectBadge(CardEffect effect) {
    Color badgeColor;
    IconData icon;
    String text = '${effect.value ?? ""}';

    switch (effect.type) {
      case 'damage':
        badgeColor = Colors.orange[800]!; // Attack color
        icon = Icons.flash_on; // Sword-ish
        break;
      case 'defense':
      case 'armor':
      case 'block':
        badgeColor = Colors.grey[700]!; // Armor color
        icon = Icons.shield;
        break;
      case 'draw':
        badgeColor = Colors.purple[700]!;
        icon = Icons.style;
        break;
      default:
        badgeColor = Colors.teal[700]!;
        icon = Icons.star;
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 1)],
          ),
        ),
      ),
    );
  }
}
