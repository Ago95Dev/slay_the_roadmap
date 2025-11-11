#!/bin/bash

echo "🎨 HomeScreen alternativa con layout a colonna singola..."

cat > lib/screens/home_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'roadmap_selection_screen.dart';
import 'boss_fight_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Section
                _buildTitleSection(),
                SizedBox(height: 40),

                // Menu Cards Column
                _buildMenuColumn(context, cardWidth),
                
                // Footer
                SizedBox(height: 30),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                '🎮 SLAY THE ROADMAP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Learn Programming through Adventure',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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
              MaterialPageRoute(builder: (context) => RoadmapSelectionScreen()),
            );
          },
          cardWidth,
        ),
        SizedBox(height: 16),
        _buildMenuCard(
          context,
          '⚔️ BOSS FIGHT',
          'Test your skills in epic coding battles against bosses',
          Icons.sports_martial_arts,
          [Colors.red, Colors.orange],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BossFightScreen()),
            );
          },
          cardWidth,
        ),
        SizedBox(height: 16),
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
        SizedBox(height: 16),
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
        SizedBox(height: 16),
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
    return Container(
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
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
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
                  SizedBox(width: 8),
                  Icon(
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

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            '🎯 Complete topics • Earn rewards • Defeat bosses',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Slay the Roadmap v1.0.0',
          style: TextStyle(
            color: Colors.white60,
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
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          '🚧 Coming Soon!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This awesome feature is currently in development and will be available in the next update!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'EXPLORE MORE',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
EOF

echo "✅ HomeScreen alternativa implementata!"
echo ""
echo "🎨 Caratteristiche del design:"
echo "   📱 Layout a colonna singola responsive"
echo "   🌈 Gradient colors per ogni carta"
echo "   🎯 Dimensioni compatte e bilanciate"
echo "   💫 Design moderno con bordi arrotondati"
echo "   📝 Sottotitoli descrittivi"
echo "   🏷️ Footer informativo"
echo ""
echo "🔄 Esegui: flutter run -d linux"