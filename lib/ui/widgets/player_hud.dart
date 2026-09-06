import 'package:flutter/material.dart';

import '../../domain/models/player_progress.dart';

/// HUD globale del giocatore (F6): XP bar + "Livello N" + XP mancanti
/// al prossimo livello. Unica fonte: [PlayerProgress] (stesse soglie
/// dell'Hub futuro: L1 0 / L2 100 / L3 500).
class PlayerHud extends StatelessWidget {
  final PlayerProgress progress;

  const PlayerHud({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final xp = progress.experience;
    final level = progress.level;
    final next = progress.xpForNextLevel;
    final missing = progress.xpToNextLevel;
    final streak = progress.streak;

    return Container(
      key: const Key('player_hud'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Livello $level',
                key: const Key('player_hud_level'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  next == null
                      ? '$xp XP • Livello massimo'
                      : '$xp / $next XP • Mancano $missing XP',
                  key: const Key('player_hud_xp'),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (streak >= 2)
                Text(
                  'Serie x$streak',
                  key: const Key('player_hud_streak'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            key: const Key('player_hud_bar'),
            value: progress.xpProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Dialog celebrativo "Livello N raggiunto!" (F6): il chiamante lo mostra
/// una sola volta confrontando il level prima/dopo la mutazione XP
/// (quiz passato / prima vittoria boss).
Future<void> showLevelUpDialog(BuildContext context, int newLevel) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('level_up_dialog'),
      title: Text('Livello $newLevel raggiunto! 🎉'),
      content: Text(
        newLevel >= PlayerProgress.maxLevel
            ? 'Hai raggiunto il livello massimo. Continua a esplorare!'
            : 'Continua così: completa topic e sconfiggi boss per salire ancora!',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Fantastico!'),
        ),
      ],
    ),
  );
}
