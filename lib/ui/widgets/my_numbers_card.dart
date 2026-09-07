import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/player_view_model.dart';

/// "I miei numeri" (F12, Evaluation): solo conteggi locali
/// (quiz passati/falliti, boss vinti/persi, reward, serie max,
/// sessioni), niente tracking invasivo. Nascosta se [PlayerViewModel]
/// non è registrato (es. vecchi test).
///
/// Card condivisa tra Settings e schermata "I miei numeri" dell'Hub:
/// le righe sono costruite qui una sola volta (nessuna duplicazione
/// di logica).
class MyNumbersCard extends StatelessWidget {
  const MyNumbersCard({super.key});

  @override
  Widget build(BuildContext context) {
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
}
