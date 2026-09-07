import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import '../view_models/session_controller.dart';
import '../animations/dungeon_motion.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/daily_reward_banner.dart';
import '../widgets/player_hud.dart';
import 'roadmap_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';

/// Home (F5, US-05): CONTINUA solo se esiste un save con progressi,
/// NUOVO PERCORSO con conferma se esiste un save, Settings reale.
/// Profilo/achievements rimossi (§2 OUT).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;
    final hasProgress = context.watch<PlayerViewModel>().hasProgress;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '🎮 Slay the Roadmap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Subtitle Section
                _buildSubtitleSection(context),
                const SizedBox(height: 12),

                // Avatar (Fase 1B-B): badge + nome + titolo + cambia.
                _buildAvatarSection(context),
                const SizedBox(height: 12),

                // HUD globale (F6): XP bar + livello sotto il titolo.
                PlayerHud(
                  progress: context.watch<PlayerViewModel>().progress,
                ),
                const SizedBox(height: 12),

                // Ricompensa giornaliera (Fase 1B-E): solo se disponibile
                // (widget condiviso con l'Hub: stesso claim, niente duplicati).
                const DailyRewardBanner(),
                const SizedBox(height: 20),

                // Menu Cards Column
                _buildMenuColumn(context, cardWidth, hasProgress),

                // Footer
                const SizedBox(height: 30),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Learn Programming through Adventure',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final progress = context.watch<PlayerViewModel>().progress;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AvatarBadge(progress: progress, size: 56),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              progress.playerName,
              key: const Key('home_player_name'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (progress.activeTitle.isNotEmpty)
              Text(
                '🏅 ${progress.activeTitle}',
                key: const Key('home_player_title'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          key: const Key('home_avatar_edit'),
          onPressed: () => showAvatarPicker(context),
          child: const Text('Cambia'),
        ),
      ],
    );
  }

  /// Le route pushate sono sorelle dell'`home:` (non ne ereditano i
  /// provider): si inoltrano i ViewModel attivi esplicitamente, altrimenti
  /// Classifica/Settings/Roadmap vanno in ProviderNotFound sul device
  /// reale (BUG 2, BUG 3). Da chiamare col [context] della Home (che li ha).
  MultiProvider _withViewModels(BuildContext context, Widget child) {
    final player = context.read<PlayerViewModel>();
    final roadmap = context.read<RoadmapViewModel>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: player),
        ChangeNotifierProvider.value(value: roadmap),
      ],
      child: child,
    );
  }

  Widget _buildMenuColumn(
    BuildContext context,
    double cardWidth,
    bool hasProgress,
  ) {
    final session = SessionController.maybeOf(context);
    return Column(
      children: [
        if (hasProgress) ...[
          _buildMenuCard(
            context,
            '▶ CONTINUA IL PERCORSO',
            'Riprendi da dove avevi lasciato',
            Icons.play_arrow,
            [Colors.green, Colors.teal],
            () {
              Navigator.push(
                context,
                DungeonPageRoute(
                  builder: (_) =>
                      _withViewModels(context, const RoadmapScreen()),
                ),
              );
            },
            cardWidth,
          ),
          const SizedBox(height: 16),
        ],
        _buildMenuCard(
          context,
          hasProgress ? '🗺️ NUOVO PERCORSO' : '🗺️ INIZIA IL PERCORSO',
          hasProgress
              ? 'Cancella il salvataggio e ricomincia da capo'
              : 'Select your learning path and begin your coding journey',
          Icons.map,
          [Colors.blue, Colors.lightBlue],
          () => _startNewRun(context, hasProgress),
          cardWidth,
        ),
        // Cambio campagna (F11): solo con sessione attiva (nascosto nei
        // test che montano la Home senza SessionController).
        if (session != null) ...[
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            '🗺️ CAMPAGNE',
            'Cambia campagna o scopri le prossime',
            Icons.explore,
            [Colors.teal, Colors.cyan],
            () => session.backToCampaignSelection(),
            cardWidth,
          ),
        ],
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '🏆 CLASSIFICA',
          'I migliori punteggi XP',
          Icons.emoji_events,
          [Colors.amber, Colors.orange],
          () {
            // Override espliciti (BUG 2): la Classifica pushata non dipende
            // dallo scope dei provider (offline calcolato qui, mai throw).
            final playerVm = context.read<PlayerViewModel>();
            Navigator.push(
              context,
              DungeonPageRoute(
                builder: (_) => LeaderboardScreen(
                  engine: playerVm.engine,
                  playerId: playerVm.hubPlayerId,
                  offlineOverride: playerVm.isLeaderboardOffline,
                ),
              ),
            );
          },
          cardWidth,
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          context,
          '⚙️ SETTINGS',
          'Reset progressi e informazioni sull\u2019app',
          Icons.settings,
          [Colors.purple, Colors.pink],
          () {
            final session = SessionController.maybeOf(context);
            Navigator.push(
              context,
              DungeonPageRoute(
                builder: (_) => _withViewModels(
                  context,
                  SettingsScreen(
                    onLogout: session == null ? null : session.logout,
                  ),
                ),
              ),
            );
          },
          cardWidth,
        ),
      ],
    );
  }

  /// Nuovo percorso: se esiste un save chiede conferma, poi wipe + reset
  /// roadmap a iniziale e naviga alla roadmap.
  Future<void> _startNewRun(BuildContext context, bool hasProgress) async {
    if (hasProgress) {
      final confirmed = await showPopDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Nuovo percorso?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Hai già un percorso salvato: ricominciando perderai '
            'topic completati, XP, reward e boss sconfitti. Continuare?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ANNULLA'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('RICOMINCIA'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      await context.read<PlayerViewModel>().wipe();
      if (!context.mounted) return;
      await context.read<RoadmapViewModel>().resetToInitial();
      if (!context.mounted) return;
    }
    Navigator.push(
      context,
      DungeonPageRoute(
        builder: (_) => _withViewModels(context, const RoadmapScreen()),
      ),
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
    return SizedBox(
      width: width,
      child: PressableScale(
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                    const SizedBox(width: 8),
                    const Icon(
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
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            '🎯 Complete topics • Earn rewards • Defeat bosses',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Slay the Roadmap v1.0.0',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
