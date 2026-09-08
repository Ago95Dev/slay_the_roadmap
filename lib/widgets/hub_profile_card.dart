import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HubProfileCard extends StatefulWidget {
  const HubProfileCard({super.key});

  @override
  State<HubProfileCard> createState() => _HubProfileCardState();
}

class _HubProfileCardState extends State<HubProfileCard> {
  Future<Map<String, dynamic>?>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future == null) {
      _future = _loadSafe();
    }
  }

  Future<Map<String, dynamic>?> _loadSafe() async {
    final gameProvider = context.read<GameProvider>();
    final ownId = gameProvider.hubPlayerId;
    if (ownId.isEmpty) return null;
    return await gameProvider.engine.getPlayerState(ownId);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final isOffline = !gameProvider.isHubOnline || gameProvider.hubPlayerId.isEmpty;

    if (isOffline) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF1a1410),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFd4af37), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hub, color: Color(0xFFd4af37)),
                SizedBox(width: 8),
                Text(
                  'GAMIFICATION HUB CARD',
                  style: TextStyle(
                    color: Color(0xFFfbbf24),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF8b6f47)),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                    ),
                  );
                }
                
                final state = snapshot.data;
                if (state == null) {
                  return const Text(
                    'Dati non disponibili dal server Hub.',
                    style: TextStyle(color: Color(0xFF8b6f47)),
                  );
                }

                // Parse state
                double totalXp = 0;
                if (state['pointConcepts'] != null) {
                  for (var pc in state['pointConcepts']) {
                    if (pc['name'] == 'xp') {
                      totalXp = (pc['score'] as num).toDouble();
                    }
                  }
                }
                
                String levelName = 'Novice';
                if (state['levels'] != null && (state['levels'] as List).isNotEmpty) {
                  final lvls = state['levels'] as List;
                  if (lvls.isNotEmpty) {
                    levelName = lvls[0]['levelValue'] ?? 'Novice';
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHubStat('LIVELLO', levelName, Icons.military_tech),
                    _buildHubStat('PUNTEGGIO', '${totalXp.toInt()} XP', Icons.bolt),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFf5f5dc), size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFd4af37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8b6f47),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
