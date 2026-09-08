import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/player_progress.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import '../widgets/active_deck_widget.dart';
import '../widgets/tiny_card_widget.dart';
import '../widgets/tiny_skills_bar.dart';
import '../widgets/hub_profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildMiniStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final stats = gameProvider.playerStats;
    final deck = gameProvider.activeDeck;

    return Scaffold(
      backgroundColor: const Color(0xFFf0f2f5), // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Section: Silhouette & Stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Silhouette
                  Container(
                    width: 240,
                    height: 240, // Square portrait
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage('assets/images/${stats.playerClass.toLowerCase()}.png'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                           // Fallback if image not found
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: 20),
                
                // Stats & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameProvider.isLoggedIn
                            ? gameProvider.displayName
                            : stats.playerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (gameProvider.hasTitle)
                        Text(
                          gameProvider.activeTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.amber,
                          ),
                        ),
                      Text(
                        'Lvl ${stats.level} ${stats.playerClass}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // HP Bar
                      _buildStatBar(
                        label: 'HP',
                        current: stats.currentHp,
                        max: stats.maxHp,
                        color: Colors.red,
                        icon: Icons.favorite,
                      ),
                      const SizedBox(height: 8),
                      
                      // Energy Bar
                      _buildStatBar(
                        label: 'ENERGY',
                        current: stats.currentEnergy,
                        max: stats.maxEnergy,
                        color: Colors.orange,
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(height: 8),
                      
                      // XP Bar (Fase 2: soglie levelForXp, non 100*level)
                      _buildStatBar(
                        label: 'XP',
                        current: stats.experience,
                        max: PlayerProgress.levelForXp(stats.experience) >=
                                PlayerProgress.maxLevel
                            ? stats.experience
                            : (PlayerProgress.levelForXp(stats.experience) == 1
                                ? PlayerProgress.level2Threshold
                                : PlayerProgress.level3Threshold),
                        color: Colors.purple,
                        icon: Icons.star,
                      ),
                      const SizedBox(height: 16),

                      // Extra Stats (Armor, Draw)
                      Row(
                        children: [
                          _buildMiniStat(Icons.shield, 'Armor', '${stats.armor}', Colors.blueGrey),
                          const SizedBox(width: 16),
                          _buildMiniStat(Icons.filter_none, 'Draw', '${stats.drawSize}', Colors.teal),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Active Deck Section
            _buildSectionHeader('DECK'),
            const SizedBox(height: 16),
            const HubProfileCard(),
            const SizedBox(height: 16),
            const ActiveDeckWidget(showClearButton: false, isEditable: false),
            
            const SizedBox(height: 32),
            
            // Skills Section
            _buildSectionHeader('SKILLS'),
            const SizedBox(height: 16),
            const TinySkillsBar(),

            const SizedBox(height: 32),

            // Badges Section (Fase 2, US-02/US-04: collection locale
            // topic/boss; l'Hub resta specchio best-effort offline-first).
            _buildSectionHeader('BADGES'),
            const SizedBox(height: 16),
            _buildBadges(gameProvider.badges),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(List<String> badges) {
    if (badges.isEmpty) {
      return const Text(
        'Nessun badge: passa un quiz o sconfiggi un boss.',
        style: TextStyle(color: Colors.black54),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final badge in badges)
          Chip(
            avatar: Icon(
              badge.startsWith('boss:') ? Icons.emoji_events : Icons.verified,
              size: 18,
              color: Colors.amber.shade800,
            ),
            label: Text(badge),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          height: 1,
          width: 100,
          color: Colors.black12,
        ),
      ],
    );
  }

  Widget _buildStatBar({
    required String label,
    required int current,
    required int max,
    required Color color,
    required IconData icon,
  }) {
    double percent = 0.0;
    if (max > 0) {
      percent = (current / max).clamp(0.0, 1.0);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              '$current/$max',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(String cardId) {
    // Mock card visual based on ID
    Color cardColor = Colors.blueGrey;
    if (cardId.contains('attack')) cardColor = Colors.red.shade900;
    if (cardId.contains('defense')) cardColor = Colors.blue.shade900;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style, color: Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            cardId.split('_').last.toUpperCase(), // Simple name extraction
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: const Center(
        child: Icon(Icons.lock_outline, color: Colors.black26),
      ),
    );
  }

  Widget _buildSkillItem(int index) {
    // Mock Skill as a Card for visual consistency
    final isUnlocked = index == 0;
    
    final mockSkillCard = CardModel(
      id: 'skill_$index',
      name: isUnlocked ? 'Dart Master' : 'Locked Skill',
      type: CardType.utility,
      rarity: isUnlocked ? CardRarity.legendary : CardRarity.common,
      manaCost: 0,
      effect: 0,
      description: isUnlocked ? 'Passive: +1 Energy per turn.' : 'Complete Chapter ${index + 1} to unlock.',
      icon: isUnlocked ? '⚡' : '🔒',
      effects: [],
    );

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: TinyCardWidget(
        card: mockSkillCard,
        isInDeck: isUnlocked, // Highlight if unlocked
        showCount: false,
        onTap: () {
          // Show skill details
        },
      ),
    );
  }
}
