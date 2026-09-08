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
    // Offline = app non configurata per l'Hub (Fake, senza credenziali) o
    // utente non loggato: card nascosta (comportamento invariato H5).
    final isOffline =
        !gameProvider.isHubConfigured || gameProvider.hubPlayerId.isEmpty;

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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHubStat('LIVELLO', levelName, Icons.military_tech),
                        _buildHubStat(
                            'PUNTEGGIO', '${totalXp.toInt()} XP', Icons.bolt),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHubBadges(state),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Badge remoti (H5, chiave `badges` di `getPlayerState`): chip per badge,
  /// empty-state se assenti. Parsing tollerante (stringhe o mappe con `name`).
  Widget _buildHubBadges(Map<String, dynamic> state) {
    final badges = _parseHubBadges(state);
    if (badges.isEmpty) {
      return const Text(
        'Nessun badge Hub.',
        style: TextStyle(color: Color(0xFF8b6f47)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final badge in badges) Chip(label: Text(badge))],
    );
  }

  /// Estrae i badge in modo tollerante: lista assente o non-lista → vuota.
  static List<String> _parseHubBadges(Map<String, dynamic> state) {
    final raw = state['badges'];
    if (raw is! List) return const [];
    final badges = <String>[];
    for (final entry in raw) {
      if (entry is String && entry.isNotEmpty) {
        badges.add(entry);
      } else if (entry is Map && entry['name'] is String) {
        final name = entry['name'] as String;
        if (name.isNotEmpty) badges.add(name);
      }
    }
    return badges;
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
