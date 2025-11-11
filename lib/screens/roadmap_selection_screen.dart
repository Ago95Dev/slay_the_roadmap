import 'package:flutter/material.dart';
import 'roadmap_screen.dart';

class RoadmapSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Roadmap'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
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
                MaterialPageRoute(builder: (context) => RoadmapScreen()),
              );
            },
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 16),
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
          SizedBox(height: 16),
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

  Widget _buildRoadmapCard(BuildContext context, String title, String description, Color color, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
        title: Text('Coming Soon!'),
        content: Text('This roadmap will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
