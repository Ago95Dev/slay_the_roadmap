import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/player_progress.dart';
import '../view_models/player_view_model.dart';

/// Colori cornice avatar (Fase 1B-B): stesso ordine di
/// [PlayerProgress.avatarFrameColorValues].
const List<Color> avatarFrameColors = [
  Color(0xFF7C4DFF), // viola
  Color(0xFF009688), // teal
  Color(0xFFF57C00), // arancio
];

/// Badge avatar: emoji dentro un cerchio con cornice colorata.
class AvatarBadge extends StatelessWidget {
  final PlayerProgress progress;
  final double size;

  const AvatarBadge({super.key, required this.progress, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final frame = avatarFrameColors[
        progress.avatarFrameIndex.clamp(0, avatarFrameColors.length - 1)];
    return Container(
      key: const Key('player_avatar'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: frame, width: 3),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: Text(
        progress.avatarIcon,
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }
}

/// Picker avatar (Fase 1B-B): 3 icone + 3 colori frame. Salva subito
/// la scelta via [PlayerViewModel.setAvatar] (persistito in autosave).
Future<void> showAvatarPicker(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final vm = Provider.of<PlayerViewModel>(ctx);
      final progress = vm.progress;
      return AlertDialog(
        key: const Key('avatar_picker'),
        title: const Text('Scegli il tuo avatar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Icona'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0;
                    i < PlayerProgress.avatarIcons.length;
                    i++)
                  _IconChoice(
                    icon: PlayerProgress.avatarIcons[i],
                    selected: progress.avatarIconIndex == i,
                    onTap: () => vm.setAvatar(iconIndex: i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Colore cornice'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < avatarFrameColors.length; i++)
                  _ColorChoice(
                    color: avatarFrameColors[i],
                    selected: progress.avatarFrameIndex == i,
                    onTap: () => vm.setAvatar(frameIndex: i),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            key: const Key('avatar_picker_done'),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fatto'),
          ),
        ],
      );
    },
  );
}

class _IconChoice extends StatelessWidget {
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('avatar_icon_$icon'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.4),
            width: selected ? 3 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('avatar_color_${color.toARGB32().toRadixString(16)}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}
