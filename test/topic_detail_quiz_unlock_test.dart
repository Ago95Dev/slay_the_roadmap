import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

/// Regression test: passare il quiz dal TopicDetailScreen deve completare
/// il topic e sbloccare i dipendenti (web_network -> net_client_server).
/// Sul codice vecchio (push senza await, risultato scartato) questo test
/// fallisce: web_network resta inProgress e net_client_server resta locked.
void main() {
  group('TopicDetailScreen quiz unlock-chain (regressione bug critico)', () {
    testWidgets(
        'quiz web_network passato -> completed + net_client_server sbloccato',
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
                        .firstWhere((e) => e.id == 'web_network');
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
      expect(findTopic('web_network').status, TopicStatus.inProgress);
      expect(findTopic('net_client_server').status, TopicStatus.locked);

      // 1. Apri il detail (simula tap sulla roadmap) e avvia il quiz.
      await tester.tap(find.text('OPEN_DETAIL'));
      await tester.pumpAndSettle();
      expect(find.byType(TopicDetailScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Avvia Quiz'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);

      // 2. Risponde correttamente a tutte le 5 domande di quiz_web_network.
      const correctOptions = [
        'Ogni strato risolve un problema diverso e si può cambiare senza rompere gli altri',
        'Tutto ciò che costruirai dopo (dati, pagine, app) si appoggia su di essi',
        'Permette di isolare il colpevole: il nome? l’indirizzo? il server? la risposta?',
        'Specializzazione: se uno cambia tecnologia, gli altri non si rompono',
        'Prima capisci come viaggiano le informazioni, poi cosa sono e come impacchettarle',
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

      // 4. Unlock-chain: web_network completed, net_client_server inProgress,
      //    quiz e detail chiusi (ritorno alla "roadmap").
      expect(findTopic('web_network').status, TopicStatus.completed);
      expect(findTopic('net_client_server').status, TopicStatus.inProgress);
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.byType(TopicDetailScreen), findsNothing);
      expect(find.text('OPEN_DETAIL'), findsOneWidget);
    });
  });
}
