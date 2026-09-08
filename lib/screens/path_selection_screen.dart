import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'class_selection_screen.dart';

class PathSelectionScreen extends StatefulWidget {
  const PathSelectionScreen({super.key});

  @override
  State<PathSelectionScreen> createState() => _PathSelectionScreenState();
}

class _PathSelectionScreenState extends State<PathSelectionScreen> {
  String? _selectedPath;

  final List<Map<String, dynamic>> _paths = [
    {
      'id': 'flutter',
      'name': 'FLUTTER',
      'icon': Icons.flutter_dash,
      'description': 'Build beautiful cross-platform apps',
    },
    {
      'id': 'dart',
      'name': 'DART',
      'icon': Icons.code,
      'description': 'Master the Dart programming language',
    },
    {
      'id': 'firebase',
      'name': 'FIREBASE',
      'icon': Icons.cloud,
      'description': 'Backend as a service',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with user icon
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NEW RUN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, size: 32),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // "Pick a PATH" heading
              const Text(
                'Pick a PATH',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // Path options
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  itemCount: _paths.length,
                  itemBuilder: (context, index) {
                    final path = _paths[index];
                    final isSelected = _selectedPath == path['id'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _PathCard(
                        name: path['name'],
                        icon: path['icon'],
                        description: path['description'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedPath = path['id'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom decorative banner area
              Container(
                height: 100,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                child: Center(
                  child: _selectedPath != null
                      ? FilledButton(
                          onPressed: () {
                            // Save selected path and navigate to class selection
                            gameProvider.selectPath(_selectedPath!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ClassSelectionScreen()),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          ),
                          child: const Text(
                            'START JOURNEY',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Text(
                          'Select a path to begin',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom decorative icon
              const Icon(Icons.auto_awesome, size: 48),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PathCard({
    required this.name,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
          ],
        ),
        ),
      ),
    );
  }
}
