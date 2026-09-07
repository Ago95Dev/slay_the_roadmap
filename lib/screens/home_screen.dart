import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../domain/models/player_progress.dart';
import '../widgets/gothic_profile_dialog.dart';
import 'roadmap_screen.dart';
import 'deck_builder_screen.dart';
import 'skill_tree_screen.dart';
import 'stats_screen.dart';
import 'dungeon_run_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RoadmapScreen(),
    const DeckBuilderScreen(),
    const SkillTreeScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final hasActiveDungeon = gameProvider.dungeonRun?.active ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0806),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0806),
              Color(0xFF1a1410),
              Color(0xFF0a0806),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Gothic AppBar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1a1410),
                    const Color(0xFF0a0806).withValues(alpha: 0.0),
                  ],
                ),
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0xFF8b6f47),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Actions and Settings only
                  // Actions
                  Row(
                    children: [
                      if (gameProvider.isDailyRewardAvailable)
                        _GothicIconButton(
                          icon: Icons.card_giftcard,
                          tooltip: 'Daily Reward',
                          color: const Color(0xFFfbbf24),
                          onPressed: () {
                            if (gameProvider.claimDailyReward()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✨ Hai ricevuto ${GameProvider.dailyRewardXp} XP!'),
                                  backgroundColor: const Color(0xFF2d1f1a),
                                ),
                              );
                            }
                          },
                        ),
                      const SizedBox(width: 8),
                      if (hasActiveDungeon)
                        _GothicIconButton(
                          icon: Icons.play_arrow,
                          tooltip: 'Resume Dungeon Run',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DungeonRunScreen(),
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 8),
                      _GothicIconButton(
                        icon: Icons.settings,
                        tooltip: 'Settings',
                        onPressed: () {
                          _showSettingsDialog(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: _screens[_selectedIndex],
            ),
            
            // Gothic Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0xFF1a1410),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF8b6f47),
                    width: 2,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _GothicNavButton(
                        icon: Icons.map,
                        label: 'Roadmap',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _GothicNavButton(
                        icon: Icons.style,
                        label: 'Deck',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _GothicNavButton(
                        icon: Icons.account_tree,
                        label: 'Skills',
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _GothicNavButton(
                        icon: Icons.bar_chart,
                        label: 'Stats',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1410),
                Color(0xFF2d1f1a),
                Color(0xFF1a1410),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFd4af37),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.9),
                offset: const Offset(0, 8),
                blurRadius: 32,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner border
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF8b6f47).withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Color(0xFFd4af37),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Divider
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFd4af37).withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Options
                    _SettingsOption(
                      icon: Icons.delete_forever,
                      label: 'Reset Progress',
                      onTap: () {
                        Navigator.pop(context);
                        _showResetConfirmation(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingsOption(
                      icon: Icons.info,
                      label: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e1410),
                              border: Border.all(
                                color: const Color(0xFF8b6f47),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'CLOSE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFf5f5dc),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1a1410),
                Color(0xFF2d1f1a),
              ],
            ),
            border: Border.all(color: const Color(0xFFef4444), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.9),
                blurRadius: 32,
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RESET PROGRESS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFef4444),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to reset all progress? This action cannot be undone.',
                style: TextStyle(
                  color: Color(0xFFf5f5dc),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e1410),
                              border: Border.all(color: const Color(0xFF8b6f47), width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Color(0xFFf5f5dc),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.read<GameProvider>().resetProgress();
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF7f1d1d),
                              border: Border.all(color: const Color(0xFFef4444), width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'RESET',
                                style: TextStyle(
                                  color: Color(0xFFfca5a5),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1a1410),
                Color(0xFF2d1f1a),
              ],
            ),
            border: Border.all(color: const Color(0xFFd4af37), width: 4),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SLAY THE ROADMAP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFd4af37),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Color(0xFF8b6f47),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'A gamified Dart learning application with deck-building mechanics inspired by Slay the Spire. Conquer the roadmap, defeat bosses, and collect powerful cards with special effects!',
                style: TextStyle(
                  color: Color(0xFFf5f5dc),
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e1410),
                        border: Border.all(color: const Color(0xFF8b6f47), width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'CLOSE',
                          style: TextStyle(
                            color: Color(0xFFf5f5dc),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gothic Icon Button Widget
class _GothicIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _GothicIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  State<_GothicIconButton> createState() => _GothicIconButtonState();
}

class _GothicIconButtonState extends State<_GothicIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1e1410).withValues(alpha: 0.6),
                border: Border.all(
                  color: _isHovering ? const Color(0xFFfbbf24) : const Color(0xFF8b6f47),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                widget.icon,
                color: widget.color ?? (_isHovering ? const Color(0xFFfbbf24) : const Color(0xFFd4af37)),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Gothic Navigation Button Widget
class _GothicNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GothicNavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFFd4af37),
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFfbbf24)
                    : const Color(0xFF8b6f47),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 1,
                  color: isSelected
                      ? const Color(0xFFd4af37)
                      : const Color(0xFF8b6f47),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Settings Option Widget
class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0a0806).withValues(alpha: 0.6),
            border: Border.all(
              color: const Color(0xFF8b6f47).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFd4af37), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFf5f5dc),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8b6f47), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
