import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slay_the_roadmap/data/repositories/quiz_repository.dart';
import 'package:slay_the_roadmap/data/repositories/topic_detail_repository.dart';
import 'package:slay_the_roadmap/ui/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/quiz_view_model.dart';

const _allTopicIds = [
  'web_network',
  'net_client_server',
  'net_dns_url',
  'net_http_https',
  'web_data',
  'data_represent',
  'data_where',
  'data_state',
  'web_building',
  'build_browser',
  'build_framework',
  'build_ship',
];

void main() {
  group('F2 — detail presenti per tutti i 12 topic', () {
    test('getTopicDetail non-null con quizId e >=2 link', () async {
      final repo = LocalTopicDetailRepository();
      for (final id in _allTopicIds) {
        final detail = await repo.getTopicDetail(id);
        expect(detail, isNotNull, reason: 'detail mancante per $id');
        expect(detail!.description.trim().isNotEmpty, isTrue,
            reason: 'descrizione vuota per $id');
        expect(detail.quizId, isNotNull, reason: 'quizId null per $id');
        expect(detail.quizId!.isNotEmpty, isTrue);
        expect(detail.links.length, greaterThanOrEqualTo(2),
            reason: 'meno di 2 link per $id');
      }
    });

    test('getAllTopicDetails copre tutti i 12 topicId', () async {
      final repo = LocalTopicDetailRepository();
      final all = await repo.getAllTopicDetails();
      for (final id in _allTopicIds) {
        expect(all.containsKey(id), isTrue, reason: 'manca $id in getAll');
      }
    });
  });

  group('F2 — submit bloccato senza risposta', () {
    test('next/submit non avanzano senza selezione', () async {
      final vm = QuizViewModel(LocalQuizRepository());
      await vm.loadQuiz('web_network');

      expect(vm.totalQuestions, 5);
      expect(vm.canProceed, isFalse);
      expect(vm.canSubmit, isFalse);

      vm.nextQuestion();
      expect(vm.currentQuestionIndex, 0);

      await vm.submitQuiz();
      expect(vm.quizResult, isNull);

      // Dopo una risposta si può avanzare.
      final correct = vm.currentQuiz!.questions[0].correctAnswerIndex;
      vm.selectAnswer(correct);
      expect(vm.canProceed, isTrue);
      vm.nextQuestion();
      expect(vm.currentQuestionIndex, 1);
    });

    test('nessun fallback null->0: unanswered non completa', () async {
      final vm = QuizViewModel(LocalQuizRepository());
      await vm.loadQuiz('web_network');
      // Risponde solo a 4 domande su 5: submit bloccato.
      for (var i = 0; i < 4; i++) {
        vm.selectAnswer(vm.currentQuiz!.questions[i].correctAnswerIndex);
        if (i < 3) vm.nextQuestion();
      }
      expect(vm.canSubmit, isFalse);
      await vm.submitQuiz();
      expect(vm.quizResult, isNull);
    });
  });

  group('F2 — hint dopo 2 errori (ViewModel)', () {
    test('hint assente prima di 2 errori, visibile dopo', () async {
      final vm = QuizViewModel(LocalQuizRepository());
      await vm.loadQuiz('web_network');

      expect(vm.shouldShowHintForCurrent, isFalse);
      expect(vm.currentHint, isNull);

      final correct = vm.currentQuiz!.questions[0].correctAnswerIndex;
      final wrong = (correct + 1) % vm.currentQuiz!.questions[0].options.length;

      vm.selectAnswer(wrong);
      expect(vm.wrongAttemptsFor(0), 1);
      expect(vm.shouldShowHintForCurrent, isFalse);
      expect(vm.currentHint, isNull);

      vm.selectAnswer(wrong);
      expect(vm.wrongAttemptsFor(0), 2);
      expect(vm.shouldShowHintForCurrent, isTrue);
      expect(vm.currentHint,
          vm.currentQuiz!.questions[0].explanation);
    });

    test('cambiando domanda il contatore si azzera', () async {
      final vm = QuizViewModel(LocalQuizRepository());
      await vm.loadQuiz('web_network');

      final q0 = vm.currentQuiz!.questions[0];
      final wrong0 = (q0.correctAnswerIndex + 1) % q0.options.length;
      vm.selectAnswer(wrong0);
      vm.selectAnswer(wrong0);
      expect(vm.shouldShowHintForCurrent, isTrue);

      // Per cambiare domanda serve una risposta selezionata (c'è: wrong0).
      vm.nextQuestion();
      expect(vm.currentQuestionIndex, 1);
      expect(vm.wrongAttemptsFor(0), 0);
      expect(vm.shouldShowHintForCurrent, isFalse);
    });
  });

  group('F2 — quiz_screen widget', () {
    testWidgets('Avanti disabilitato senza risposta', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(topicId: 'web_network', topicTitle: 'La Rete'),
        ),
      );
      await tester.pumpAndSettle();

      final avanti = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Avanti'),
      );
      expect(avanti.onPressed, isNull);
    });

    testWidgets('hint visibile dopo 2 errori e non prima', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(topicId: 'web_network', topicTitle: 'La Rete'),
        ),
      );
      await tester.pumpAndSettle();

      // Q1: corretta = indice 1, quindi la prima opzione è errata.
      expect(find.byKey(const Key('quiz_hint')), findsNothing);

      await tester.tap(find.text('Per consumare più energia'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quiz_hint')), findsNothing);

      await tester.tap(find.text('Per consumare più energia'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quiz_hint')), findsOneWidget);
      expect(
        find.text(
            'Separare i problemi rende la rete riparabile ed evolvibile.'),
        findsOneWidget,
      );
    });
  });
}
