import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import 'skill_node_widget.dart';
import 'skill_detail_dialog.dart';
import 'skill_tree_painter.dart';

class SkillGraphWidget extends StatelessWidget {
  final List<SkillNode> skills;
  final double nodeSize = 64.0;
  final double verticalSpacing = 120.0;
  final double horizontalSpacing = 100.0;

  const SkillGraphWidget({
    super.key,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final playerClass = gameProvider.playerStats.playerClass;

    // Filter skills by class
    final visibleSkills = skills.where((s) => 
      s.requiredClass == null || 
      s.requiredClass!.toLowerCase() == playerClass.toLowerCase()
    ).toList();
    
    // 1. Calculate Positions based on Tier (Auto-Layout)
    // Group by Tier
    final Map<int, List<SkillNode>> skillsByTier = {};
    for (var skill in visibleSkills) {
      if (!skillsByTier.containsKey(skill.tier)) {
        skillsByTier[skill.tier] = [];
      }
      skillsByTier[skill.tier]!.add(skill);
    }

    // Determine max width (max nodes in a tier) to center everything
    int maxNodesInTier = 0;
    skillsByTier.forEach((_, list) {
      if (list.length > maxNodesInTier) maxNodesInTier = list.length;
    });

    final Map<String, Offset> nodePositions = {};
    double totalHeight = 0;
    double totalWidth = 0;

    // Calculate layout
    final sortedTiers = skillsByTier.keys.toList()..sort();
    
    if (sortedTiers.isNotEmpty) {
      totalHeight = (sortedTiers.last * verticalSpacing) + nodeSize + 40; // Padding
      totalWidth = (maxNodesInTier * horizontalSpacing) + nodeSize;
    }

    // Center alignment
    final double screenWidth = MediaQuery.of(context).size.width;
    // Ensure totalWidth is at least screen width for centering logic
    final double effectiveTotalWidth = totalWidth < screenWidth ? screenWidth : totalWidth;
    final double centerX = effectiveTotalWidth / 2;

    for (var tier in sortedTiers) {
      final tierSkills = skillsByTier[tier]!;
      final count = tierSkills.length;
      
      for (int i = 0; i < count; i++) {
        final skill = tierSkills[i];
        // Calculate X offset to center the group of nodes
        final xOffset = (i - (count - 1) / 2) * horizontalSpacing;
        final x = centerX + xOffset;
        final y = (tier - 1) * verticalSpacing + 60.0; // Start with some top padding
        
        nodePositions[skill.id] = Offset(x, y);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: effectiveTotalWidth,
          height: totalHeight < 500 ? 500 : totalHeight,
          child: Stack(
            children: [
              // 1. Painter Layer (Lines)
              CustomPaint(
                size: Size.infinite,
                painter: SkillTreePainter(
                  skills: visibleSkills,
                  nodePositions: nodePositions,
                ),
              ),
              
              // 2. Nodes Layer
              ...visibleSkills.map((skill) {
                final pos = nodePositions[skill.id];
                if (pos == null) return const SizedBox.shrink();
                
                final canUnlock = _canUnlock(skill, gameProvider);

                return Positioned(
                  left: pos.dx - (nodeSize / 2),
                  top: pos.dy - (nodeSize / 2),
                  child: SkillNodeWidget(
                    skill: skill,
                    canUnlock: canUnlock,
                    size: nodeSize,
                    onTap: () {
                      if (canUnlock) {
                        gameProvider.unlockSkill(skill.id);
                      }
                    },
                    onSecondaryTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => SkillDetailDialog(
                          skill: skill,
                          canUnlock: canUnlock,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  bool _canUnlock(SkillNode skill, GameProvider provider) {
    if (skill.unlocked) return false;
    if (provider.availableSkillPoints < skill.cost) return false;
    if (skill.prerequisite != null) {
      final prereq = provider.skillTree.firstWhere((s) => s.id == skill.prerequisite);
      return prereq.unlocked;
    }
    return true;
  }
}
