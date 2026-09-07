import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/engine_client.dart';
import '../view_models/player_view_model.dart';

/// Classifica XP dell'Hub (Fase 1B-D, CD5/Toda).
///
/// Stati: caricamento (spinner), vuota ("Nessun punteggio — gioca un quiz!"),
/// offline ("Classifica non disponibile offline"). Top 3 con medaglie
/// 🥇🥈🥉; la riga del proprio [hubPlayerId] è evidenziata ("Tu").
/// Pull-to-refresh ricarica la board.
class LeaderboardScreen extends StatefulWidget {
  /// Override per i test: se null, letti da [PlayerViewModel].
  final EngineClient? engine;
  final String? playerId;
  final bool? offlineOverride;

  const LeaderboardScreen({
    super.key,
    this.engine,
    this.playerId,
    this.offlineOverride,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  EngineClient? _effectiveEngine(BuildContext context) =>
      widget.engine ?? context.read<PlayerViewModel>().engine;

  String _effectivePlayerId(BuildContext context) =>
      widget.playerId ?? context.read<PlayerViewModel>().hubPlayerId;

  bool _isOffline(BuildContext context) {
    if (widget.offlineOverride != null) return widget.offlineOverride!;
    final engine = _effectiveEngine(context);
    if (engine == null) return true;
    if (engine is HttpEngineClient) return engine.isOffline;
    return false;
  }

  Future<List<LeaderboardEntry>> _load() async {
    final engine = widget.engine;
    if (engine != null) return engine.getLeaderboard();
    if (!mounted) return const <LeaderboardEntry>[];
    return context.read<PlayerViewModel>().fetchLeaderboard();
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
  }

  /// Medaglia per il podio, numero di posizione altrimenti.
  static String medalFor(int position) => switch (position) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '#$position',
      };

  @override
  Widget build(BuildContext context) {
    if (_isOffline(context)) {
      return Scaffold(
        appBar: AppBar(title: const Text('🏆 Classifica')),
        body: const Center(
          child: Text(
            'Classifica non disponibile offline',
            key: Key('leaderboard_offline'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final ownId = _effectivePlayerId(context);
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Classifica')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<LeaderboardEntry>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  key: Key('leaderboard_loading'),
                ),
              );
            }
            final entries = snapshot.data ?? const <LeaderboardEntry>[];
            if (entries.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Nessun punteggio — gioca un quiz!',
                      key: Key('leaderboard_empty'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isOwn = entry.playerId == ownId;
                return ListTile(
                  key: Key('leaderboard_row_${entry.position}'),
                  leading: Text(
                    medalFor(entry.position),
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(
                    isOwn ? '${entry.playerId} • Tu' : entry.playerId,
                    style: isOwn
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                  trailing: Text(
                    '${entry.score} XP',
                    style: isOwn
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                  tileColor: isOwn
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.4)
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
