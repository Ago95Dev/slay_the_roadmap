import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/engine_client.dart';

class GothicLeaderboardWidget extends StatefulWidget {
  const GothicLeaderboardWidget({super.key});

  @override
  State<GothicLeaderboardWidget> createState() => _GothicLeaderboardWidgetState();
}

class _GothicLeaderboardWidgetState extends State<GothicLeaderboardWidget> {
  Future<List<LeaderboardEntry>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future == null) {
      _future = _loadSafe();
    }
  }

  Future<List<LeaderboardEntry>> _loadSafe() async {
    try {
      final engine = context.read<GameProvider>().engine;
      return await engine.getLeaderboard();
    } catch (_) {
      return const <LeaderboardEntry>[];
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _future = _loadSafe();
    });
  }

  static String medalFor(int position) => switch (position) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '#$position',
      };

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final ownId = gameProvider.hubPlayerId;
    final isOffline = !gameProvider.isHubOnline;

    if (isOffline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Color(0xFF8b6f47)),
              const SizedBox(height: 16),
              const Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFd4af37),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Classifica non disponibile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFf5f5dc)),
              ),
              const SizedBox(height: 8),
              Text(
                "Avvia l'app con le credenziali Hub\nper vedere la classifica mondiale.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8b6f47), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFFd4af37),
      backgroundColor: const Color(0xFF1a1410),
      child: FutureBuilder<List<LeaderboardEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
              ),
            );
          }
          final entries = snapshot.hasError
              ? const <LeaderboardEntry>[]
              : (snapshot.data ?? const <LeaderboardEntry>[]);
              
          if (entries.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'Nessun punteggio.',
                    style: TextStyle(color: Color(0xFF8b6f47)),
                  ),
                ),
              ],
            );
          }
          
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isOwn = ownId.isNotEmpty && entry.playerId == ownId;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isOwn ? const Color(0xFFd4af37).withValues(alpha: 0.2) : const Color(0xFF1e1410).withValues(alpha: 0.6),
                  border: Border.all(
                    color: isOwn ? const Color(0xFFd4af37) : const Color(0xFF8b6f47).withValues(alpha: 0.5),
                    width: isOwn ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Text(
                    medalFor(entry.position),
                    style: TextStyle(
                      fontSize: 24,
                      color: isOwn ? const Color(0xFFf5f5dc) : const Color(0xFFd4af37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(
                    isOwn ? '${entry.playerId} (Tu)' : entry.playerId,
                    style: TextStyle(
                      fontWeight: isOwn ? FontWeight.w900 : FontWeight.w600,
                      color: isOwn ? const Color(0xFFfbbf24) : const Color(0xFFf5f5dc),
                    ),
                  ),
                  trailing: Text(
                    '${entry.score} XP',
                    style: TextStyle(
                      fontWeight: isOwn ? FontWeight.w900 : FontWeight.w600,
                      color: isOwn ? const Color(0xFFfbbf24) : const Color(0xFF8b6f47),
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
