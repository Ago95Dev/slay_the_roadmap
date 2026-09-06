import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Regression test: passare il quiz dal TopicDetailScreen deve completare
/// il topic e sbloccare i dipendenti (dart_basics -> variables).
/// Sul codice vecchio (push senza await, risultato scartato) questo test
/// fallisce: dart_basics resta inProgress e variables resta locked.
void main() {
  group('TopicDetailScreen quiz unlock-chain (regressione bug critico)', () {
    testWidgets(
        'quiz dart_basics passato -> completed + variables sbloccato',
        (tester) async {
      final vm = RoadmapViewModel(LocalRoadmapRepository());

      // NOTA: niente await su loadRoadmap qui dentro: in testWidgets
      // Future.delayed usa il fake clock e si completa solo pompando.
      // Si avvia senza await e il pumpAndSettle sotto fa avanzare i timer.
      vm.loadRoadmap();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    final t = vm.topics
                        .firstWhere((e) => e.id == 'dart_basics');
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => TopicDetailScreen(topic: t),
                      ),
                    );
                  },
                  child: const Text('OPEN_DETAIL'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Fa scattare il Future.delayed(500ms) di loadRoadmap nel fake clock.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      Topic findTopic(String id) {
        for (final t in vm.topics) {
          if (t.id == id) return t;
          for (final s in t.subtopics) {
            if (s.id == id) return s;
          }
        }
        throw StateError('topic $id non trovato');
      }

      // Precondizioni dai dati reali.
      expect(findTopic('dart_basics').status, TopicStatus.inProgress);
      expect(findTopic('variables').status, TopicStatus.locked);

      // 1. Apri il detail (simula tap sulla roadmap) e avvia il quiz.
      await tester.tap(find.text('OPEN_DETAIL'));
      await tester.pumpAndSettle();
      expect(find.byType(TopicDetailScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Avvia Quiz'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);

      // 2. Risponde correttamente a tutte le 5 domande di quiz_dart_basics.
      const correctOptions = [
        'Mobile app development with Flutter',
        "name: 'John';",
        'The variable can only be set once',
        'foreach loop (but has for-in)',
        'dart run <file.dart>',
      ];

      for (var i = 0; i < correctOptions.length; i++) {
        await tester.tap(find.text(correctOptions[i]));
        await tester.pumpAndSettle();
        final isLast = i == correctOptions.length - 1;
        await tester.tap(
          find.widgetWithText(
              ElevatedButton, isLast ? 'Concludi Quiz' : 'Avanti'),
        );
        await tester.pumpAndSettle();
      }

      // 3. Schermata risultato: quiz superato, tap "Continua".
      expect(find.text('Quiz Superato! 🎉'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continua'));
      await tester.pumpAndSettle();

      // 4. Unlock-chain: dart_basics completed, variables inProgress,
      //    quiz e detail chiusi (ritorno alla "roadmap").
      expect(findTopic('dart_basics').status, TopicStatus.completed);
      expect(findTopic('variables').status, TopicStatus.inProgress);
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.byType(TopicDetailScreen), findsNothing);
      expect(find.text('OPEN_DETAIL'), findsOneWidget);
    });
  });
}
