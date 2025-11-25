import 'package:flutter/material.dart';
import 'roadmap_selection_screen.dart';
import 'boss_fight_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

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
                _buildMenuColumn(context, cardWidth),
                
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

  Widget _buildMenuColumn(BuildContext context, double cardWidth) {
    return Column(
      children: [
        _buildMenuCard(
          context,
          '🗺️ CHOOSE ROADMAP',
          'Select your learning path and begin your coding journey',
          Icons.map,
          [Colors.blue, Colors.lightBlue],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RoadmapSelectionScreen(),
              ),
            );
          },
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
          '📊 PROFILE & STATS',
          'Track your progress, statistics, and learning achievements',
          Icons.person,
          [Colors.green, Colors.lightGreen],
          () {
            _showComingSoon(context);
          },
          cardWidth,
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '🏆 ACHIEVEMENTS',
          'Unlock badges, rewards, and special accomplishments',
          Icons.emoji_events,
          [Colors.orange, Colors.amber],
          () {
            _showComingSoon(context);
          },
          cardWidth,
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '⚙️ SETTINGS',
          'Customize your app experience and preferences',
          Icons.settings,
          [Colors.purple, Colors.pink],
          () {
            _showComingSoon(context);
          },
          cardWidth,
        ),
      ],
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

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          '🚧 Coming Soon!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This awesome feature is currently in development and will be available in the next update!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'EXPLORE MORE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
