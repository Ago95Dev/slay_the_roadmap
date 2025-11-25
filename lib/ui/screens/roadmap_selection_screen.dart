import 'package:flutter/material.dart';
import 'roadmap_screen.dart';

class RoadmapSelectionScreen extends StatelessWidget {
  const RoadmapSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Roadmap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoadmapCard(
            context,
            'Dart Roadmap',
            'Master the Dart programming language',
            Colors.blue,
            Icons.code,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoadmapScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildRoadmapCard(
            context,
            'Flutter Roadmap',
            'Build cross-platform apps with Flutter',
            Colors.purple,
            Icons.phone_iphone,
            () {
              _showComingSoon(context);
            },
          ),
          const SizedBox(height: 16),
          _buildRoadmapCard(
            context,
            'Web Development',
            'Full-stack web development journey',
            Colors.green,
            Icons.web,
            () {
              _showComingSoon(context);
            },
          ),
          const SizedBox(height: 16),
          _buildRoadmapCard(
            context,
            'Data Structures',
            'Master algorithms and data structures',
            Colors.orange,
            Icons.architecture,
            () {
              _showComingSoon(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
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
          'This roadmap will be available in the next update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
