import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';

class SkillDetailDialog extends StatelessWidget {
  final SkillNode skill;
  final bool canUnlock;

  const SkillDetailDialog({
    super.key,
    required this.skill,
    required this.canUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final isUnlocked = skill.unlocked;
    final branchColor = _getBranchColor(skill.branch);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: branchColor.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: branchColor.withValues(alpha: 0.2),
                border: Border.all(color: branchColor, width: 2),
              ),
              child: Icon(
                _getSkillIcon(skill),
                size: 40,
                color: branchColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              skill.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Tier Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tier ${skill.tier} • ${_getBranchName(skill.branch)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            Text(
              skill.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Effect
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: branchColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: branchColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: branchColor),
                  const SizedBox(width: 8),
                  Text(
                    'Effect: +${skill.effect.value} ${skill.effect.type}',
                    style: TextStyle(
                      color: branchColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Button
            if (isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'UNLOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canUnlock
                      ? () {
                          gameProvider.unlockSkill(skill.id);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: branchColor,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (canUnlock) ...[
                        const Text(
                          'UNLOCK FOR ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${skill.cost} PTS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.lock, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          skill.prerequisite != null 
                              ? 'LOCKED (Prerequisite Required)' 
                              : 'LOCKED (Not Enough Points)',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBranchColor(SkillBranch branch) {
    switch (branch) {
      case SkillBranch.offensive: return Colors.red[700]!;
      case SkillBranch.defensive: return Colors.blue[700]!;
      case SkillBranch.utility: return Colors.purple[700]!;
    }
  }

  String _getBranchName(SkillBranch branch) {
    switch (branch) {
      case SkillBranch.offensive: return 'Offensive';
      case SkillBranch.defensive: return 'Defensive';
      case SkillBranch.utility: return 'Utility';
    }
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
