import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/types.dart';
import '../widgets/compact_stats_bar.dart';
import '../widgets/tiny_skills_bar.dart';
import '../widgets/skill_graph_widget.dart';

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  SkillBranch _selectedBranch = SkillBranch.offensive;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final availablePoints = gameProvider.availableSkillPoints;

    final skillsByBranch = {
      SkillBranch.offensive:
          gameProvider.skillTree.where((s) => s.branch == SkillBranch.offensive).toList(),
      SkillBranch.defensive:
          gameProvider.skillTree.where((s) => s.branch == SkillBranch.defensive).toList(),
      SkillBranch.utility:
          gameProvider.skillTree.where((s) => s.branch == SkillBranch.utility).toList(),
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFF1a1410),
            Color(0xFF0a0806),
          ],
        ),
      ),
      child: Column(
        children: [
          // Compact Stats Bar
          const CompactStatsBar(),
          
          // Unlocked Skills Bar
          const TinySkillsBar(),

          // Skill Tree Title & Points
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF8b6f47),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SKILL CONSTELLATION',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Color(0xFFd4af37),
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ascend the tree of knowledge',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8b6f47),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                // Points Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1a1410),
                        Color(0xFF2d1f1a),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFd4af37),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFd4af37).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$availablePoints',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFfbbf24),
                          shadows: [
                            Shadow(
                              color: Color(0xFFfbbf24),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'POINTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8b6f47),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Branch Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _GothicBranchTab(
                  icon: Icons.flash_on,
                  label: 'OFFENSIVE',
                  branch: SkillBranch.offensive,
                  selectedBranch: _selectedBranch,
                  count: skillsByBranch[SkillBranch.offensive]!.where((s) => s.unlocked).length,
                  total: skillsByBranch[SkillBranch.offensive]!.length,
                  onTap: () => setState(() => _selectedBranch = SkillBranch.offensive),
                ),
                const SizedBox(width: 8),
                _GothicBranchTab(
                  icon: Icons.shield,
                  label: 'DEFENSIVE',
                  branch: SkillBranch.defensive,
                  selectedBranch: _selectedBranch,
                  count: skillsByBranch[SkillBranch.defensive]!.where((s) => s.unlocked).length,
                  total: skillsByBranch[SkillBranch.defensive]!.length,
                  onTap: () => setState(() => _selectedBranch = SkillBranch.defensive),
                ),
                const SizedBox(width: 8),
                _GothicBranchTab(
                  icon: Icons.auto_awesome,
                  label: 'UTILITY',
                  branch: SkillBranch.utility,
                  selectedBranch: _selectedBranch,
                  count: skillsByBranch[SkillBranch.utility]!.where((s) => s.unlocked).length,
                  total: skillsByBranch[SkillBranch.utility]!.length,
                  onTap: () => setState(() => _selectedBranch = SkillBranch.utility),
                ),
              ],
            ),
          ),
          
          // Skills Graph
          Expanded(
            child: SkillGraphWidget(
              skills: skillsByBranch[_selectedBranch]!,
            ),
          ),
        ],
      ),
    );
  }
}

class _GothicBranchTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final SkillBranch branch;
  final SkillBranch selectedBranch;
  final int count;
  final int total;
  final VoidCallback onTap;

  const _GothicBranchTab({
    required this.icon,
    required this.label,
    required this.branch,
    required this.selectedBranch,
    required this.count,
    required this.total,
    required this.onTap,
  });

  Color get _branchColor {
    switch (branch) {
      case SkillBranch.offensive:
        return const Color(0xFFef4444); // Red
      case SkillBranch.defensive:
        return const Color(0xFF3b82f6); // Blue
      case SkillBranch.utility:
        return const Color(0xFFa855f7); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = branch == selectedBranch;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        _branchColor.withOpacity(0.3),
                        const Color(0xFF1a1410),
                      ],
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFF1a1410),
                        Color(0xFF0a0806),
                      ],
                    ),
              border: Border.all(
                color: isSelected ? _branchColor : const Color(0xFF8b6f47),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _branchColor.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? _branchColor : const Color(0xFF8b6f47),
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 1,
                    color: isSelected ? _branchColor : const Color(0xFF8b6f47),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count/$total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? _branchColor.withOpacity(0.8)
                        : const Color(0xFF8b6f47).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
