import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../domain/models/player_progress.dart';

class GothicProfileDialog extends StatefulWidget {
  const GothicProfileDialog({super.key});

  @override
  State<GothicProfileDialog> createState() => _GothicProfileDialogState();
}

class _GothicProfileDialogState extends State<GothicProfileDialog> {
  int _selectedIconIndex = -1;
  int _selectedFrameIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedIconIndex == -1) {
      final provider = context.read<GameProvider>();
      _selectedIconIndex = provider.avatarIconIndex;
      _selectedFrameIndex = provider.avatarFrameIndex;
    }
  }

  void _save(BuildContext context) {
    context.read<GameProvider>().setAvatar(
      iconIndex: _selectedIconIndex,
      frameIndex: _selectedFrameIndex,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final stats = gameProvider.playerStats;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFFd4af37),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                            color: Color(PlayerProgress.avatarFrameColorValues[_selectedFrameIndex.clamp(0, PlayerProgress.avatarFrameColorValues.length - 1)]),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            PlayerProgress.avatarIcons[_selectedIconIndex.clamp(0, PlayerProgress.avatarIcons.length - 1)],
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.playerName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFf5f5dc),
                              ),
                            ),
                            if (gameProvider.hasTitle)
                              Text(
                                gameProvider.activeTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFd4af37),
                                ),
                              ),
                            Text(
                              'Lvl ${stats.level} ${stats.playerClass}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8b6f47),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AVATAR ICON',
                      style: TextStyle(color: Color(0xFF8b6f47), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(PlayerProgress.avatarIcons.length, (index) {
                      final isSelected = index == _selectedIconIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIconIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? const Color(0xFFd4af37) : Colors.transparent,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            PlayerProgress.avatarIcons[index],
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AVATAR FRAME',
                      style: TextStyle(color: Color(0xFF8b6f47), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(PlayerProgress.avatarFrameColorValues.length, (index) {
                      final isSelected = index == _selectedFrameIndex;
                      final color = Color(PlayerProgress.avatarFrameColorValues[index]);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFrameIndex = index),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.black,
                              width: isSelected ? 3 : 1,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFf5f5dc),
                          ),
                          child: const Text('CANCEL', style: TextStyle(letterSpacing: 2)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _save(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFd4af37),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('SAVE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
