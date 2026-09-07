import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import 'tiny_card_widget.dart';

class TinySkillsBar extends StatelessWidget {
  const TinySkillsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final unlockedSkills = gameProvider.skillTree.where((s) => s.unlocked).toList();

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
          Text(
            'UNLOCKED SKILLS (${unlockedSkills.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade300,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: unlockedSkills.isEmpty
                ? Center(
                    child: Text(
                      'No skills unlocked yet.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: unlockedSkills.length,
                    itemBuilder: (context, index) {
                      final skill = unlockedSkills[index];
                      final cardModel = _mapSkillToCard(skill);
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 60,
                          child: TinyCardWidget(
                            card: cardModel,
                            isInDeck: true, // Always show as "active/owned"
                            showCount: false,
                            iconData: _getSkillIcon(skill),
                            onTap: () {
                              // Optional: Show skill details dialog
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

  CardModel _mapSkillToCard(SkillNode skill) {
    // Map SkillBranch to CardType
    CardType type;
    switch (skill.branch) {
      case SkillBranch.offensive:
        type = CardType.attack;
        break;
      case SkillBranch.defensive:
        type = CardType.defense;
        break;
      case SkillBranch.utility:
        type = CardType.utility;
        break;
    }

    // Map Tier to Rarity
    CardRarity rarity;
    if (skill.tier == 1) {
      rarity = CardRarity.common;
    } else if (skill.tier == 2) rarity = CardRarity.rare;
    else if (skill.tier == 3) rarity = CardRarity.epic;
    else rarity = CardRarity.legendary;

    return CardModel(
      id: skill.id,
      name: skill.name,
      type: type,
      description: skill.description,
      effect: skill.effect.value,
      manaCost: skill.cost,
      rarity: rarity,
      icon: '⚡', // Default icon, will be replaced by image in widget
      effects: [], // Skills might not map directly to card effects list for now
    );
  }

  IconData _getSkillIcon(SkillNode skill) {
    if (skill.effect.type == 'maxHp') return Icons.favorite;
    if (skill.effect.type == 'maxEnergy') return Icons.flash_on;
    if (skill.effect.type == 'cardDamage') return Icons.whatshot;
    if (skill.effect.type == 'cardBlock') return Icons.shield;
    if (skill.effect.type == 'drawSize') return Icons.style;
    if (skill.effect.type == 'armor') return Icons.security;
    
    switch (skill.branch) {
      case SkillBranch.offensive: return Icons.flash_on;
      case SkillBranch.defensive: return Icons.shield_moon;
      case SkillBranch.utility: return Icons.auto_fix_high;
    }
  }
}
