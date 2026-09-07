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
  Future<List<LeaderboardEntry>> _future =
      Future.value(const <LeaderboardEntry>[]);
  bool _started = false;

  // Niente `context.read` in initState (BUG 2): il load parte in
  // didChangeDependencies (dipendenze disponibili) con mounted implicito
  // (nessun setState post-completamento: il Future è già agganciato).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _future = _loadSafe();
    }
  }

  /// Engine effettivo: override del costruttore oppure quello del
  /// [PlayerViewModel]; null se non disponibile. Mai throw (la schermata
  /// è pushata come sorella dell'`home:`, i provider potrebbero mancare).
  EngineClient? _effectiveEngine() {
    if (widget.engine != null) return widget.engine;
    try {
      return context.read<PlayerViewModel>().engine;
    } catch (_) {
      return null;
    }
  }

  String _effectivePlayerId() {
    if (widget.playerId != null) return widget.playerId!;
    try {
      return context.read<PlayerViewModel>().hubPlayerId;
    } catch (_) {
      return '';
    }
  }

  bool _isOffline() {
    if (widget.offlineOverride != null) return widget.offlineOverride!;
    try {
      final engine = _effectiveEngine();
      if (engine == null) return true;
      if (engine is HttpEngineClient) return engine.isOffline;
      return false;
    } catch (_) {
      return true;
    }
  }

  /// Caricamento best-effort: lista vuota su qualsiasi errore (engine che
  /// lancia, provider assente, snapshot con errore), mai throw verso la UI.
  Future<List<LeaderboardEntry>> _loadSafe() async {
    try {
      final engine = _effectiveEngine();
      if (engine == null) return const <LeaderboardEntry>[];
      return await engine.getLeaderboard();
    } catch (_) {
      return const <LeaderboardEntry>[];
    }
  }

  /// Refresh con mounted guard: mai setState dopo dispose, mai throw
  /// verso [RefreshIndicator]/UI.
  Future<void> _refresh() async {
    if (!mounted) return;
    final next = _loadSafe();
    setState(() {
      _future = next;
    });
    try {
      await next;
    } catch (_) {
      // Best-effort: lo stato vuoto resta mostrato.
    }
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
    // Doppia guardia (BUG 2): nessun throw sincrono verso la UI in
    // nessun caso (provider assenti nella route pushata, engine nulli).
    bool offline = true;
    String ownId = '';
    try {
      offline = _isOffline();
      ownId = _effectivePlayerId();
    } catch (_) {
      offline = true;
      ownId = '';
    }
    if (offline) {
      return Scaffold(
        appBar: AppBar(title: const Text('🏆 Classifica')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Classifica non disponibile offline',
                  key: Key('leaderboard_offline'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Avvia l'app con le credenziali Hub "
                  '(--dart-define=HUB_USER/...) per vedere '
                  'la classifica mondiale.',
                  key: Key('leaderboard_offline_hint'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
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
            // snapshot con errore → stato vuoto esistente, mai throw.
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
