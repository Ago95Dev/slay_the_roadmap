import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import 'skill_node_widget.dart';
import 'skill_detail_dialog.dart';

class SkillLibraryWidget extends StatelessWidget {
  const SkillLibraryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final playerClass = gameProvider.playerStats.playerClass;
    final allSkills = gameProvider.skillTree;

    // Filter by class
    final visibleSkills = allSkills.where((s) => 
      s.requiredClass == null || 
      s.requiredClass!.toLowerCase() == playerClass.toLowerCase()
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'SKILL LIBRARY (${visibleSkills.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: visibleSkills.length,
            itemBuilder: (context, index) {
              final skill = visibleSkills[index];
              final isUnlocked = skill.unlocked;

              return ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: SkillNodeWidget(
                  skill: skill,
                  canUnlock: false, // Library view, no unlocking
                  onTap: () {
                     // Primary tap could also show details or do nothing
                     showDialog(
                      context: context,
                      builder: (context) => SkillDetailDialog(
                        skill: skill,
                        canUnlock: false,
                      ),
                    );
                  },
                  onSecondaryTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SkillDetailDialog(
                        skill: skill,
                        canUnlock: false,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
