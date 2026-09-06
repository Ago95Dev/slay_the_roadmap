import 'dart:async';

import 'package:flutter/material.dart';

/// Motion pack condiviso (tema dungeon, sobrio):
///
/// - [DungeonPageRoute]: fade + lieve risalita (250ms) per tutte le
///   navigazioni push, coerente tra schermate.
/// - [PressableScale]: feedback tap (scale 0.97, 150ms) puramente visivo
///   via [Listener] — non ruba gesture a InkWell/ListTile.
/// - [PopIn]: comparsa scale + fade (250ms, one-shot, con `delayMs`
///   opzionale per ingressi in sequenza).
/// - [showPopDialog]: dialoghi con transizione scale + fade (250ms).
/// - [CombatLogView]: battle-log con riga nuova animata (fade + slide).
///
/// Regole: durate 150-350ms, curve standard, nessun loop permanente,
/// `MediaQuery.disableAnimationsOf` rispettato ovunque.
class DungeonPageRoute<T> extends PageRouteBuilder<T> {
  DungeonPageRoute({
    required Widget Function(BuildContext context) builder,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, animation, _, child) {
            if (MediaQuery.disableAnimationsOf(context)) return child;
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

/// Feedback tap: si restringe al tocco e torna normale al rilascio.
///
/// Usa [Listener] (eventi raw, fuori dalla gesture arena): gli onTap di
/// ListTile/InkWell/Card interni continuano a funzionare invariati.
class PressableScale extends StatefulWidget {
  final Widget child;

  const PressableScale({super.key, required this.child});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Comparsa animata scale (0.92 -> 1) + fade (250ms, one-shot).
///
/// Con [delayMs] > 0 parte dopo il ritardo (utile per carte in sequenza);
/// prima del via resta invisibile ma occupa già il layout (niente salti).
class PopIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const PopIn({super.key, required this.child, this.delayMs = 0});

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> {
  bool _started = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delayMs <= 0) {
      _started = true;
    } else {
      _timer = Timer(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    if (!_started) return Opacity(opacity: 0, child: widget.child);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.92 + 0.08 * t,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Dialogo con entrata scale (0.92 -> 1) + fade (250ms).
///
/// Stesso contratto di [showDialog]: il `builder` restituisce tipicamente
/// un [AlertDialog]; la chiusura resta su Navigator.pop.
Future<T?> showPopDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool barrierDismissible = true,
}) {
  if (MediaQuery.disableAnimationsOf(context)) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Chiudi',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (ctx, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Battle-log dark-fantasy: le righe vecchie sono statiche, solo l'ultima
/// (quella appena aggiunta) entra con fade + slide (250ms, one-shot).
class CombatLogView extends StatelessWidget {
  final String log;

  static const _lineStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    color: Color(0xFFEDE7F6),
    height: 1.45,
  );

  const CombatLogView({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final lines = log.split('\n');
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < lines.length; i++)
            if (i == lines.length - 1)
              _LogLineEnter(
                key: ValueKey(log),
                line: lines[i],
              )
            else
              Text(lines[i], style: _lineStyle),
        ],
      ),
    );
  }
}

class _LogLineEnter extends StatelessWidget {
  final String line;

  const _LogLineEnter({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(line, style: CombatLogView._lineStyle);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 6 * (1 - t)),
          child: child,
        ),
      ),
      child: Text(line, style: CombatLogView._lineStyle),
    );
  }
}
