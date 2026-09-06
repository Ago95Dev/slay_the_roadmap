import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import 'roadmap_screen.dart';
import 'boss_fight_screen.dart';
import 'settings_screen.dart';

/// Home (F5, US-05): CONTINUA solo se esiste un save con progressi,
/// NUOVO PERCORSO con conferma se esiste un save, Settings reale.
/// Profilo/achievements rimossi (§2 OUT).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;
    final hasProgress = context.watch<PlayerViewModel>().hasProgress;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '🎮 Slay the Roadmap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Subtitle Section
                _buildSubtitleSection(context),
                const SizedBox(height: 32),

                // Menu Cards Column
                _buildMenuColumn(context, cardWidth, hasProgress),

                // Footer
                const SizedBox(height: 30),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Learn Programming through Adventure',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuColumn(
    BuildContext context,
    double cardWidth,
    bool hasProgress,
  ) {
    return Column(
      children: [
        if (hasProgress) ...[
          _buildMenuCard(
            context,
            '▶ CONTINUA IL PERCORSO',
            'Riprendi da dove avevi lasciato',
            Icons.play_arrow,
            [Colors.green, Colors.teal],
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoadmapScreen(),
                ),
              );
            },
            cardWidth,
          ),
          const SizedBox(height: 16),
        ],
        _buildMenuCard(
          context,
          hasProgress ? '🗺️ NUOVO PERCORSO' : '🗺️ INIZIA IL PERCORSO',
          hasProgress
              ? 'Cancella il salvataggio e ricomincia da capo'
              : 'Select your learning path and begin your coding journey',
          Icons.map,
          [Colors.blue, Colors.lightBlue],
          () => _startNewRun(context, hasProgress),
          cardWidth,
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '⚔️ BOSS FIGHT',
          'Test your skills in epic coding battles against bosses',
          Icons.sports_martial_arts,
          [Colors.red, Colors.orange],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BossFightScreen(),
              ),
            );
          },
          cardWidth,
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '⚙️ SETTINGS',
          'Reset progressi e informazioni sull\u2019app',
          Icons.settings,
          [Colors.purple, Colors.pink],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          cardWidth,
        ),
      ],
    );
  }

  /// Nuovo percorso: se esiste un save chiede conferma, poi wipe + reset
  /// roadmap a iniziale e naviga alla roadmap.
  Future<void> _startNewRun(BuildContext context, bool hasProgress) async {
    if (hasProgress) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Nuovo percorso?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Hai già un percorso salvato: ricominciando perderai '
            'topic completati, XP, reward e boss sconfitti. Continuare?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ANNULLA'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('RICOMINCIA'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      await context.read<PlayerViewModel>().wipe();
      if (!context.mounted) return;
      await context.read<RoadmapViewModel>().resetToInitial();
      if (!context.mounted) return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoadmapScreen(),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            '🎯 Complete topics • Earn rewards • Defeat bosses',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Slay the Roadmap v1.0.0',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
