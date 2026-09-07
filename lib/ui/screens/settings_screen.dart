import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../animations/dungeon_motion.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';

/// Impostazioni minime (F5, US-05): Reset progressi + About.
/// F10: "Cambia utente" (logout, torna alla scelta profilo senza
/// cancellare nulla) quando [onLogout] è fornito (sessione attiva).
/// Niente profilo/achievements (§2 OUT).
class SettingsScreen extends StatelessWidget {
  final Future<void> Function()? onLogout;

  const SettingsScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(context),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset progressi'),
              subtitle: const Text(
                'Cancella il salvataggio e ricomincia da capo',
              ),
              onTap: () => _confirmReset(context),
            ),
          ),
          if (onLogout != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                key: const Key('settings_logout'),
                leading: const Icon(Icons.switch_account),
                title: const Text('Cambia utente'),
                subtitle: const Text(
                  'Torna alla scelta del profilo (nessun dato cancellato)',
                ),
                onTap: () => onLogout!(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              subtitle: Text(
                'Slay the Roadmap v1.0.0\n'
                'Impara Dart sconfiggendo boss: completa i topic, '
                'supera i quiz (80%), colleziona reward e salva i '
                'progressi in automatico sul dispositivo.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "I miei numeri" (F12, Evaluation): solo conteggi locali
  /// (quiz passati/falliti, boss vinti/persi, reward, serie max,
  /// sessioni), niente tracking invasivo. Nascosta se PlayerViewModel
  /// non è registrato (es. vecchi test).
  Widget _buildStatsCard(BuildContext context) {
    PlayerViewModel? playerVm;
    try {
      playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
    } catch (_) {
      playerVm = null;
    }
    if (playerVm == null) return const SizedBox.shrink();
    final progress = playerVm.progress;
    final rows = [
      'Quiz superati: ${progress.analytics.quizPassed}',
      'Quiz falliti: ${progress.analytics.quizFailed}',
      'Boss vinti: ${progress.analytics.bossWon}',
      'Boss persi: ${progress.analytics.bossLost}',
      'Reward riscattate: ${progress.analytics.rewardsClaimed}',
      'Serie migliore: x${progress.maxStreak}',
      'Sessioni: ${progress.analytics.sessions}',
    ];
    return Card(
      key: const Key('settings_stats'),
      child: ListTile(
        leading: const Icon(Icons.query_stats),
        title: const Text('📊 I miei numeri'),
        subtitle: Text(rows.join('\n')),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showPopDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progressi?'),
        content: const Text(
          'Tutti i progressi salvati (topic, XP, reward, boss) '
          'verranno cancellati. Continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<PlayerViewModel>().wipe();
    if (!context.mounted) return;
    await context.read<RoadmapViewModel>().resetToInitial();
    if (!context.mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Progressi cancellati. Buona avventura!')),
    );
  }
}
