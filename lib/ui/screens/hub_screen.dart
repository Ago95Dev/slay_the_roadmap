import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../animations/dungeon_motion.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import '../view_models/session_controller.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/daily_reward_banner.dart';
import '../widgets/player_hud.dart';
import 'campaign_selection_screen.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'my_numbers_screen.dart';
import 'settings_screen.dart';

/// Hub personale (centro post-login): profilo + voci di navigazione.
///
/// Gerarchia: Login/Registrazione → Hub → Campagna (Home di gioco) /
/// Roadmap / ... La root monta sempre l'Hub dopo il login (mai più la
/// selezione campagna forzata): la campagna si sceglie da qui.
///
/// - Profilo: [AvatarBadge] + nome + titolo attivo + "Cambia".
/// - Stato: [PlayerHud] (Livello + XP bar + serie/vite) + banner
///   giornaliero condiviso ([DailyRewardBanner]).
/// - Voci: CONTINUA (solo se una campagna è già stata scelta, con
///   sottotitolo dell'ultima campagna), CAMPAGNE, CLASSIFICA,
///   I MIEI NUMERI, IMPOSTAZIONI.
/// - Prima campagna mai scelta: CONTINUA nascosto + invito a scegliere.
class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  /// Le route pushate sono sorelle dell'`home:` (non ne ereditano i
  /// provider): si inoltrano i ViewModel attivi esplicitamente, come in
  /// [HomeScreen] (BUG 2, BUG 3). Da chiamare col [context] dell'Hub.
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

  void _openContinue(BuildContext context) {
    final session = SessionController.maybeOf(context);
    Navigator.push(
      context,
      DungeonPageRoute(
        builder: (_) => _withViewModels(
          context,
          HomeScreen(
            key: ValueKey(
              '${session?.activeProfile?.userId}_${session?.activeCampaignId}',
            ),
          ),
        ),
      ),
    );
  }

  void _openCampaigns(BuildContext context) {
    final session = SessionController.maybeOf(context);
    if (session == null) return;
    Navigator.push(
      context,
      DungeonPageRoute(
        builder: (_) => CampaignSelectionScreen(session: session),
      ),
    );
  }

  void _openLeaderboard(BuildContext context) {
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
  }

  void _openNumbers(BuildContext context) {
    Navigator.push(
      context,
      DungeonPageRoute(
        builder: (_) => _withViewModels(context, const MyNumbersScreen()),
      ),
    );
  }

  void _openSettings(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final playerVm = context.watch<PlayerViewModel>();
    final progress = playerVm.progress;
    final hasCampaign = session.hasSelectedCampaign;
    final lastCampaignTitle =
        session.activeCampaign?.title ?? session.activeCampaignId;

    return Scaffold(
      key: const Key('hub_screen'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '🏠 Hub personale',
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
                // Profilo: avatar + nome + titolo + cambia.
                Row(
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
                          key: const Key('hub_player_name'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (progress.activeTitle.isNotEmpty)
                          Text(
                            '🏅 ${progress.activeTitle}',
                            key: const Key('hub_player_title'),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      key: const Key('hub_avatar_edit'),
                      onPressed: () => showAvatarPicker(context),
                      child: const Text('Cambia'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // HUD globale (F6): XP bar + livello sotto il titolo.
                PlayerHud(progress: progress),
                const SizedBox(height: 12),

                // Ricompensa giornaliera (Fase 1B-E): solo se disponibile.
                const DailyRewardBanner(
                  cardKey: Key('hub_daily_reward'),
                  tapKey: Key('hub_daily_reward_tap'),
                ),
                const SizedBox(height: 20),

                // Prima campagna mai scelta: invito invece di CONTINUA.
                if (!hasCampaign)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Scegli la tua prima campagna per iniziare l\u2019avventura!',
                      key: const Key('hub_invite'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Voci di navigazione.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasCampaign) ...[
                        _HubEntry(
                          entryKey: const Key('hub_continue'),
                          icon: Icons.play_arrow,
                          title: '▶ CONTINUA',
                          subtitle: 'Riprendi: $lastCampaignTitle',
                          onTap: () => _openContinue(context),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _HubEntry(
                        entryKey: const Key('hub_campaigns'),
                        icon: Icons.explore,
                        title: '🗺️ CAMPAGNE',
                        subtitle: hasCampaign
                            ? 'Cambia campagna o scopri le prossime'
                            : 'Scegli dove avventurarti',
                        onTap: () => _openCampaigns(context),
                      ),
                      const SizedBox(height: 12),
                      _HubEntry(
                        entryKey: const Key('hub_leaderboard'),
                        icon: Icons.emoji_events,
                        title: '🏆 CLASSIFICA',
                        subtitle: 'I migliori punteggi XP',
                        onTap: () => _openLeaderboard(context),
                      ),
                      const SizedBox(height: 12),
                      _HubEntry(
                        entryKey: const Key('hub_numbers'),
                        icon: Icons.query_stats,
                        title: '📊 I MIEI NUMERI',
                        subtitle: 'Quiz, boss, reward e serie',
                        onTap: () => _openNumbers(context),
                      ),
                      const SizedBox(height: 12),
                      _HubEntry(
                        entryKey: const Key('hub_settings'),
                        icon: Icons.settings,
                        title: '⚙️ IMPOSTAZIONI',
                        subtitle:
                            'Avatar, reset progressi e cambio utente',
                        onTap: () => _openSettings(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Voce di navigazione dell'Hub (Card + ListTile).
class _HubEntry extends StatelessWidget {
  final Key entryKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubEntry({
    required this.entryKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: entryKey,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
