import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/boss_repository.dart';
import 'package:slay_the_roadmap/ui/screens/boss_fight_active_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/boss_fight_view_model.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';

double _luminance(Color c) {
  double channel(int ch) {
    final v = ch / 255.0;
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  final argb = c.toARGB32();
  return 0.2126 * channel((argb >> 16) & 0xFF) +
      0.7152 * channel((argb >> 8) & 0xFF) +
      0.0722 * channel(argb & 0xFF);
}

double _ratio(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> _pumpBattle(WidgetTester tester, ThemeMode mode) async {
  final vm = BossFightViewModel(BossRepository(), bossTurnDelay: Duration.zero);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: vm),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: mode,
        home: const BossFightActiveScreen(bossId: 'boss_dart_basics'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // La schermata ricarica il boss al mount e mostra lo start screen:
  // si avvia la battaglia come farebbe l'utente.
  await tester.tap(find.text('START BATTLE'));
  await tester.pumpAndSettle();
}

void _expectBattleLogContrast(WidgetTester tester) {
  // Il testo del battle-log è l'unico con font monospace.
  final texts = tester.widgetList<Text>(
    find.byWidgetPredicate(
      (w) => w is Text && w.style?.fontFamily == 'monospace',
    ),
  );
  expect(texts, isNotEmpty, reason: 'battle-log text non trovato');
  final fg = texts.first.style?.color;
  expect(fg, isNotNull, reason: 'il testo del log deve avere colore esplicito');

  final containers = tester.widgetList<Container>(
    find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFF1E1B2E),
    ),
  );
  expect(containers, isNotEmpty, reason: 'pannello battle-log non trovato');
  final bg =
      ((containers.first.decoration!) as BoxDecoration).color ??
          const Color(0xFF1E1B2E);
  final ratio = _ratio(bg, fg!);
  // ignore: avoid_print
  print('battle-log bg=$bg fg=$fg ratio=${ratio.toStringAsFixed(2)}');
  expect(ratio, greaterThanOrEqualTo(4.5));
}

void main() {
  group('Battle-log contrasto (WCAG AA)', () {
    testWidgets('tema dark: log leggibile', (tester) async {
      await _pumpBattle(tester, ThemeMode.dark);
      _expectBattleLogContrast(tester);
    });

    testWidgets('tema light: log leggibile', (tester) async {
      await _pumpBattle(tester, ThemeMode.light);
      _expectBattleLogContrast(tester);
    });
  });
}
