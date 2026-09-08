import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'path_selection_screen.dart';
import '../widgets/auth_dialogs.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final hasActiveDungeon = gameProvider.dungeonRun?.active ?? false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Dark gothic gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0806), // Very dark brown
              Color(0xFF1a1410), // Dark parchment
              Color(0xFF0a0806),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Vignette effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with Sign In/Sign Up (Gothic style)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'HOME',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: const Color(0xFFd4af37), // Gold
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!gameProvider.isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF8b6f47), width: 2),
                              color:
                                  const Color(0xFF1e1410).withValues(alpha: 0.8),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AuthDialog(),
                                );
                              },
                              child: const Text(
                                'LOGIN / SIGN UP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFf5f5dc),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFd4af37), width: 2),
                              color:
                                  const Color(0xFF1e1410).withValues(alpha: 0.8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  gameProvider.displayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFd4af37),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => gameProvider.logout(),
                                  child: const Text(
                                    'LOGOUT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Spacer and Title
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          // Main title
                          Text(
                            'SLAY THE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Color(0xFFd4af37),
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 8,
                                ),
                                Shadow(
                                  color: Color(0xFFd4af37),
                                  offset: Offset(0, 0),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'ROADMAP',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              color: Color(0xFFfbbf24), // Brighter gold
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: Color(0xFFfbbf24),
                                  offset: Offset(0, 0),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Main menu buttons
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MenuButton(
                            label: 'CONTINUE',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _MenuButton(
                            label: 'NEW RUN',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PathSelectionScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _MenuButton(
                            label: 'SETTINGS',
                            onPressed: () {
                              _showSettingsDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom decorative elements
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Conquer the Knowledge',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8b6f47),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      builder: (context) {
        // read (non watch): il dialog non deve risottoscriversi al provider
        // e ricostruirsi su ogni notify (es. resetProgress prima del pop).
        final gameProvider = context.read<GameProvider>();
        return Dialog(
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

                      // Hub Connection Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0a0806).withValues(alpha: 0.6),
                          border: Border.all(
                            color:
                                const Color(0xFF8b6f47).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_done,
                                color: gameProvider.isLoggedIn
                                    ? Colors.green
                                    : Colors.grey,
                                size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gamification Hub',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFf5f5dc),
                                    ),
                                  ),
                                  Text(
                                    gameProvider.isLoggedIn
                                        ? 'GamerTag: ${gameProvider.displayName}'
                                        : 'Non sei autenticato. Fai il Sign In.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: gameProvider.isLoggedIn
                                          ? const Color(0xFFd4af37)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Options
                      const _SettingsOption(
                        icon: Icons.volume_up,
                        label: 'Sound',
                        trailing: Icons.toggle_on,
                      ),
                      const SizedBox(height: 12),
                      const _SettingsOption(
                        icon: Icons.dark_mode,
                        label: 'Dark Mode',
                        trailing: Icons.toggle_off,
                      ),
                      const SizedBox(height: 12),
                      // Reset Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            gameProvider.resetProgress();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.2),
                              border: Border.all(
                                color:
                                    Colors.red.shade700.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.delete_forever,
                                    color: Colors.red, size: 24),
                                SizedBox(width: 16),
                                Text(
                                  'Wipe Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
        );
      },
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 320,
        height: 70,
        decoration: BoxDecoration(
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: const Color(0xFFd4af37).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            child: Container(
              decoration: BoxDecoration(
                // Dark parchment background
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isHovering
                      ? [
                          const Color(0xFF2d1f1a),
                          const Color(0xFF1a1410),
                        ]
                      : [
                          const Color(0xFF1a1410),
                          const Color(0xFF2d1f1a),
                        ],
                ),
                // Ornate golden border
                border: Border.all(
                  color: _isHovering
                      ? const Color(0xFFfbbf24) // Brighter gold on hover
                      : const Color(0xFFd4af37),
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  // Inner border
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF8b6f47).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Text
                  Center(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _isHovering
                            ? const Color(0xFFfbbf24)
                            : const Color(0xFFf5f5dc),
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData trailing;

  const _SettingsOption({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(trailing, color: const Color(0xFF8b6f47), size: 28),
        ],
      ),
    );
  }
}
