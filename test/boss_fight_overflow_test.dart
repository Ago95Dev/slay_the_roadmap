import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/screens/boss_fight_screen.dart';

/// Regression: la mano carte non deve overfloware su superfici basse/strette.
/// Bug utente: "BOTTOM OVERFLOWED BY 39 PIXELS" sopra la bottom bar con
/// carte tagliate in basso.
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpFightAtSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final errors = <FlutterErrorDetails>[];
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
          child: const MaterialApp(
            home: BossFightScreen(bossId: 'syntax_sentinel'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      // Attraversa i 3 dialoghi di apertura: ogni dialogo richiede
      // tap (completa typewriter) + tap (avanti).
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 800));
        final gesture = find.byType(GestureDetector);
        if (gesture.evaluate().isNotEmpty) {
          await tester.tap(gesture.first);
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } finally {
      FlutterError.onError = oldOnError;
    }

    expect(tester.takeException(), isNull,
        reason: 'eccezione durante il pump a $size');
    final overflows =
        errors.where((e) => '$e'.toLowerCase().contains('overflowed'));
    expect(overflows, isEmpty,
        reason:
            'overflow a $size: ${overflows.map((e) => e.exceptionAsString()).join('\n')}');
  }

  testWidgets('BossFightScreen: nessun overflow a 800x600', (tester) async {
    await pumpFightAtSize(tester, const Size(800, 600));
  });

  testWidgets('BossFightScreen: nessun overflow a 1280x720', (tester) async {
    await pumpFightAtSize(tester, const Size(1280, 720));
  });
}
