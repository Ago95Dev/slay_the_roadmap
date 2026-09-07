import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  String? _selectedClass;

  final List<Map<String, dynamic>> _classes = [
    {
      'id': 'warrior',
      'name': 'WARRIOR',
      'image': 'assets/images/warrior.png',
      'description': 'Strong defense and heavy attacks.',
      'starterCards': ['Strike', 'Strike', 'Strike', 'Defend', 'Defend', 'Defend', 'Bash'],
      'color': Colors.red.shade700,
    },
    {
      'id': 'hunter',
      'name': 'HUNTER',
      'image': 'assets/images/hunter.png',
      'description': 'Agile, uses utility and precision.',
      'starterCards': ['Strike', 'Strike', 'Strike', 'Defend', 'Defend', 'Defend', 'Quick Shot'],
      'color': Colors.green.shade700,
    },
    {
      'id': 'mage',
      'name': 'MAGE',
      'image': 'assets/images/mage.png',
      'description': 'High burst damage and spells.',
      'starterCards': ['Strike', 'Strike', 'Strike', 'Defend', 'Defend', 'Defend', 'Fireball'],
      'color': Colors.blue.shade700,
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
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CHOOSE YOUR CLASS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Class Options
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classData = _classes[index];
                    final isSelected = _selectedClass == classData['id'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedClass = classData['id'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? classData['color'] : Colors.black,
                              width: isSelected ? 4 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: classData['color'].withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Class Portrait
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? classData['color'] : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(classData['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Class Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      classData['name'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      classData['description'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Starter Cards Preview
                                    Row(
                                      children: [
                                        Icon(Icons.style, size: 12, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Starter: ${classData['starterCards'].join(", ")}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: classData['color'],
                                  size: 32,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Start Button Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  border: const Border(top: const BorderSide(color: Colors.black, width: 2)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedClass != null
                        ? () {
                            gameProvider.selectClass(_selectedClass!);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedClass != null
                          ? _classes.firstWhere((c) => c['id'] == _selectedClass)['color']
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _selectedClass != null ? 4 : 0,
                    ),
                    child: const Text(
                      'BEGIN ADVENTURE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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
