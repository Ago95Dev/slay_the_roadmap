import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slay_the_roadmap/ui/animations/dungeon_motion.dart';
import 'package:slay_the_roadmap/ui/widgets/boss/boss_health_bar.dart';
import 'package:slay_the_roadmap/ui/widgets/boss/player_health_bar.dart';

/// Motion pack dungeon (solo UI): route, feedback tap, comparse,
/// HP bar animate, battle-log, dialoghi. Niente loop, durate 150-350ms.
void main() {
  group('DungeonPageRoute', () {
    testWidgets('naviga alla destinazione con fade/slide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: _NavProbe()),
      );
      await tester.tap(find.text('VAI'));
      await tester.pump();
      // A metà transizione (250ms) la destinazione è già visibile.
      await tester.pump(const Duration(milliseconds: 125));
      expect(find.text('Destinazione'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Destinazione'), findsOneWidget);
    });
  });

  group('PressableScale', () {
    testWidgets('mostra il child e non blocca il tap interno', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              child: InkWell(
                onTap: () => tapped = true,
                child: const Text('Tocca'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Tocca'), findsOneWidget);
      await tester.tap(find.text('Tocca'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('PopIn', () {
    testWidgets('mostra il child dopo la comparsa', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PopIn(child: Text('Premio'))),
        ),
      );
      expect(find.text('Premio'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Premio'), findsOneWidget);
    });

    testWidgets('con delay resta nel layout e poi appare', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PopIn(delayMs: 120, child: Text('Ritardato')),
          ),
        ),
      );
      expect(find.text('Ritardato'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Ritardato'), findsOneWidget);
    });
  });

  group('BossHealthBar', () {
    testWidgets('mostra nome e HP e segue i danni', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BossHealthBar(
              currentHp: 100,
              maxHp: 100,
              bossName: 'Bug Drake',
            ),
          ),
        ),
      );
      expect(find.text('100 / 100 HP'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BossHealthBar(
              currentHp: 40,
              maxHp: 100,
              bossName: 'Bug Drake',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('40 / 100 HP'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    });
  });

  group('PlayerHealthBar', () {
    testWidgets('mostra HP e segue i danni', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerHealthBar(currentHp: 30, maxHp: 30),
          ),
        ),
      );
      expect(find.text('30 / 30'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerHealthBar(currentHp: 12, maxHp: 30),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('12 / 30'), findsOneWidget);
    });
  });

  group('CombatLogView', () {
    testWidgets('mostra le righe e la nuova riga entra animata',
        (tester) async {
      const first = 'Turno 1: inizi!';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CombatLogView(log: first)),
        ),
      );
      expect(find.text(first), findsOneWidget);

      const updated = 'Turno 1: inizi!\nDanno al boss: 25';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CombatLogView(log: updated)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 125));
      expect(find.text('Danno al boss: 25'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Turno 1: inizi!'), findsOneWidget);
      expect(find.text('Danno al boss: 25'), findsOneWidget);
    });
  });

  group('showPopDialog', () {
    testWidgets('mostra e chiude il dialogo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: _DialogProbe()),
      );
      await tester.tap(find.text('APRI'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}

class _NavProbe extends StatelessWidget {
  const _NavProbe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => Navigator.push(
          context,
          DungeonPageRoute(
            builder: (_) => const Scaffold(body: Text('Destinazione')),
          ),
        ),
        child: const Text('VAI'),
      ),
    );
  }
}

class _DialogProbe extends StatelessWidget {
  const _DialogProbe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => showPopDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text('Corpo'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: const Text('APRI'),
      ),
    );
  }
}
