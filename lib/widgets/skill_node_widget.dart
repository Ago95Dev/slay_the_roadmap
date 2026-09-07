import 'package:flutter/material.dart';
import '../models/types.dart';

class SkillNodeWidget extends StatelessWidget {
  final SkillNode skill;
  final bool canUnlock;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final double size;

  const SkillNodeWidget({
    super.key,
    required this.skill,
    required this.canUnlock,
    required this.onTap,
    this.onSecondaryTap,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = skill.unlocked;
    final isLocked = !isUnlocked && !canUnlock;
    
    // Colors based on state
    final Color baseColor = _getBranchColor(skill.branch);
    final Color borderColor = isUnlocked 
        ? baseColor 
        : (canUnlock ? Colors.white : Colors.grey[800]!);
    final Color iconColor = isUnlocked 
        ? Colors.white 
        : (canUnlock ? Colors.white70 : Colors.grey[700]!);
    final Color backgroundColor = isUnlocked 
        ? baseColor 
        : (canUnlock ? baseColor.withOpacity(0.3) : const Color(0xFF1E1E1E));

    return GestureDetector(
      onTap: onTap,
      onSecondaryTap: onSecondaryTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node Circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: isUnlocked || canUnlock ? 3 : 2,
              ),
              boxShadow: isUnlocked || canUnlock
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                _getSkillIcon(skill),
                color: iconColor,
                size: size * 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Skill Name
          SizedBox(
            width: size * 1.5,
            child: Text(
              skill.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked ? Colors.white : Colors.grey,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBranchColor(SkillBranch branch) {
    switch (branch) {
      case SkillBranch.offensive:
        return Colors.red[700]!;
      case SkillBranch.defensive:
        return Colors.blue[700]!;
      case SkillBranch.utility:
        return Colors.purple[700]!;
    }
  }

  IconData _getSkillIcon(SkillNode skill) {
    // Map specific IDs or types to icons
    if (skill.effect.type == 'maxHp') return Icons.favorite;
    if (skill.effect.type == 'maxEnergy') return Icons.flash_on;
    if (skill.effect.type == 'cardDamage') return Icons.whatshot;
    if (skill.effect.type == 'cardBlock') return Icons.shield;
    if (skill.effect.type == 'drawSize') return Icons.style;
    if (skill.effect.type == 'armor') return Icons.security;
    
    // Fallback based on branch
    switch (skill.branch) {
      case SkillBranch.offensive: return Icons.flash_on; // Placeholder
      case SkillBranch.defensive: return Icons.shield_moon; // Placeholder
      case SkillBranch.utility: return Icons.auto_fix_high;
    }
  }
}
