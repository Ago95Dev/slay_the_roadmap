import 'package:flutter_test/flutter_test.dart';
import 'package:slay_the_roadmap/data/topics_and_quizzes.dart';

/// US-02: ogni quiz deve avere 3-5 domande con soglia 80; ogni domanda
/// deve avere 4 opzioni con correctAnswer valido.
void main() {
  group('quiz length (US-02)', () {
    test('ogni quiz in quizzesData ha 3-5 domande', () {
      expect(quizzesData, isNotEmpty);
      for (final quiz in quizzesData) {
        expect(
          quiz.questions.length,
          inInclusiveRange(3, 5),
          reason: 'quiz ${quiz.topicId} deve avere 3-5 domande',
        );
      }
    });

    test('ogni quiz in quizzesData ha passingScore 80', () {
      expect(quizzesData, isNotEmpty);
      for (final quiz in quizzesData) {
        expect(
          quiz.passingScore,
          80,
          reason: 'quiz ${quiz.topicId} deve avere soglia 80',
        );
      }
    });

    test('ogni domanda ha 4 opzioni con correctAnswer valido', () {
      expect(quizzesData, isNotEmpty);
      for (final quiz in quizzesData) {
        for (var i = 0; i < quiz.questions.length; i++) {
          final q = quiz.questions[i];
          expect(
            q.options.length,
            4,
            reason: 'quiz ${quiz.topicId} domanda $i deve avere 4 opzioni',
          );
          expect(
            q.correctAnswer,
            inInclusiveRange(0, 3),
            reason:
                'quiz ${quiz.topicId} domanda $i: correctAnswer fuori range',
          );
        }
      }
    });
  });
}
