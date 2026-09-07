import 'package:flutter/material.dart';

import '../animations/dungeon_motion.dart';
import '../../domain/models/player_progress.dart';
import 'avatar_picker.dart';

/// HUD globale del giocatore (F6): XP bar + "Livello N" + XP mancanti
/// al prossimo livello. Unica fonte: [PlayerProgress] (stesse soglie
/// dell'Hub futuro: L1 0 / L2 100 / L3 500).
///
/// Fase 1B-B: mostra anche l'avatar (badge con cornice) e il titolo
/// attivo sotto il livello (se vinto).
///
/// La barra XP si muove con Tween tra un valore e l'altro (300ms,
/// one-shot); rispetta `MediaQuery.disableAnimations`.
class PlayerHud extends StatefulWidget {
  final PlayerProgress progress;

  const PlayerHud({super.key, required this.progress});

  @override
  State<PlayerHud> createState() => _PlayerHudState();
}

class _PlayerHudState extends State<PlayerHud> {
  late double _fromProgress;

  @override
  void initState() {
    super.initState();
    _fromProgress = widget.progress.xpProgress;
  }

  @override
  void didUpdateWidget(PlayerHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fromProgress = oldWidget.progress.xpProgress;
  }

  @override
  Widget build(BuildContext context) {
    final xp = widget.progress.experience;
    final level = widget.progress.level;
    final next = widget.progress.xpForNextLevel;
    final missing = widget.progress.xpToNextLevel;
    final streak = widget.progress.streak;
    final target = widget.progress.xpProgress;

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
              AvatarBadge(progress: widget.progress, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Livello $level',
                      key: const Key('player_hud_level'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.progress.activeTitle.isNotEmpty)
                      Text(
                        '🏅 ${widget.progress.activeTitle}',
                        key: const Key('player_hud_title'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
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
          if (MediaQuery.disableAnimationsOf(context))
            LinearProgressIndicator(
              key: const Key('player_hud_bar'),
              value: target,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            )
          else
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: _fromProgress, end: target),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                key: const Key('player_hud_bar'),
                value: value.clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog celebrativo "Livello N raggiunto!" (F6): il chiamante lo mostra
/// una sola volta confrontando il level prima/dopo la mutazione XP
/// (quiz passato / prima vittoria boss). Entrata scale + fade (250ms).
Future<void> showLevelUpDialog(BuildContext context, int newLevel) {
  return showPopDialog<void>(
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
