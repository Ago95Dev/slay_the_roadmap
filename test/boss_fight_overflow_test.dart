import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/models/types.dart';
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

  group('BossFightScreen quiz dialog (KNOWLEDGE CHECK / DEFEND YOURSELF)',
      () {
    testWidgets('quiz boss senza overflow a 800x600', (tester) async {
      await pumpQuizAtSize(tester, const Size(800, 600));
    });

    testWidgets('quiz boss senza overflow a 1280x720', (tester) async {
      await pumpQuizAtSize(tester, const Size(1280, 720));
    });
  });
}

/// Regression: il dialog quiz del boss (KNOWLEDGE CHECK con risposte A-D +
/// conseguenza fallimento) non deve overfloware su superfici basse.
/// Bug utente: "BOTTOM OVERFLOWED BY 15 PIXELS" sul pulsante inferiore.
/// Usa la domanda live più lunga (worst case reale) e guida la UI fino al
/// quiz via END TURN (nessuna carta giocata: niente vittoria/sconfitta).

/// Provider deterministico: restituisce sempre la domanda peggiore (reale).
class _FixedQuizGameProvider extends GameProvider {
  final QuizQuestion fixed;
  _FixedQuizGameProvider(this.fixed);

  @override
  List<QuizQuestion> getRandomQuestionsFromTopics(int count) => [fixed];

  @override
  List<QuizQuestion> getRandomQuestionsFromTopic(String topicId, int count) =>
      [fixed];
}

/// Domanda live più lunga (question + options): worst case del dataset reale.
QuizQuestion _longestLiveQuestion() {
  final pool = GameProvider().getRandomQuestionsFromTopics(100000);
  expect(pool, isNotEmpty, reason: 'pool quiz live vuota');
  int weight(QuizQuestion q) =>
      q.question.length + q.options.fold(0, (sum, o) => sum + o.length);
  pool.sort((a, b) => weight(b).compareTo(weight(a)));
  return pool.first;
}

bool _quizVisible() =>
    find.text('KNOWLEDGE CHECK').evaluate().isNotEmpty ||
    find.text('DEFEND YOURSELF').evaluate().isNotEmpty;

List<String> _overflowMessages(List<FlutterErrorDetails> errors) => errors
    .where((e) => e.exceptionAsString().toLowerCase().contains('overflowed'))
    .map((e) => e.exceptionAsString())
    .toList();

Future<void> pumpQuizAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final question = _longestLiveQuestion();
  final provider = _FixedQuizGameProvider(question);

  final errors = <FlutterErrorDetails>[];
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details);
  };
  try {
    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: BossFightScreen(bossId: 'syntax_sentinel'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    // Salta i 3 dialoghi di apertura: tap (completa typewriter) + tap (avanti).
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 800));
      final gesture = find.byType(GestureDetector);
      if (gesture.evaluate().isNotEmpty) {
        await tester.tap(gesture.first);
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.pump(const Duration(seconds: 1));

    // Chiudi il turno finché il quiz boss non appare (~50% a turno boss).
    var opened = false;
    for (var i = 0; i < 12 && !opened; i++) {
      if (_quizVisible()) {
        opened = true;
        break;
      }
      // Full-heal: il loop non deve mai finire in defeat.
      provider.playerStats.currentHp = provider.playerStats.maxHp;
      final endTurn = find.text('END TURN');
      if (endTurn.evaluate().isNotEmpty) {
        await tester.tap(endTurn);
      }
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }
    expect(opened || _quizVisible(), isTrue,
        reason: 'quiz boss mai apparso a $size');

    expect(tester.takeException(), isNull,
        reason: 'eccezione durante il pump quiz a $size');
    expect(_overflowMessages(errors), isEmpty,
        reason:
            'overflow quiz a $size: ${_overflowMessages(errors).join('\n')}');

    // Le 4 risposte A-D esistono (anche se scrollabili)...
    for (final option in question.options) {
      expect(find.text(option, skipOffstage: false), findsOneWidget,
          reason: 'risposta quiz mancante a $size: $option');
    }
    // ...la prima risposta e la conseguenza fallimento restano visibili
    // senza scroll (footer pinnato, lista scrollabile).
    expect(find.text(question.options.first), findsOneWidget,
        reason: 'prima risposta non visibile a $size');
    expect(find.textContaining('FAILURE CONSEQUENCE'), findsOneWidget,
        reason: 'conseguenza fallimento non visibile a $size');

    // Stato "risposto": il layout non deve overfloware nemmeno dopo il tap.
    await tester.tap(find.text(question.options.first));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull,
        reason: 'eccezione dopo risposta quiz a $size');
    expect(_overflowMessages(errors), isEmpty,
        reason:
            'overflow dopo risposta a $size: ${_overflowMessages(errors).join('\n')}');
    expect(find.textContaining('FAILURE CONSEQUENCE'), findsOneWidget,
        reason: 'conseguenza fallimento sparita dopo risposta a $size');

    // Lascia risolvere il risultato (2s) senza eccezioni/overflow.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull,
        reason: 'eccezione dopo risultato quiz a $size');
    expect(_overflowMessages(errors), isEmpty,
        reason:
            'overflow dopo risultato a $size: ${_overflowMessages(errors).join('\n')}');
  } finally {
    FlutterError.onError = oldOnError;
  }
}
