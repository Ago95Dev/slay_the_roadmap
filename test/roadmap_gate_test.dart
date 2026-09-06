import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/roadmap_repository.dart';
import 'package:slay_the_roadmap/domain/models/topic.dart';
import 'package:slay_the_roadmap/ui/screens/quiz_screen.dart';
import 'package:slay_the_roadmap/ui/screens/roadmap_screen.dart';
import 'package:slay_the_roadmap/ui/screens/topic_detail_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/roadmap_view_model.dart';

class _FakeRoadmapRepository implements RoadmapRepository {
  final List<Topic> seed;
  _FakeRoadmapRepository(this.seed);

  @override
  Future<List<Topic>> getDartRoadmap() async => seed;

  @override
  Future<Topic?> getTopicWithDetail(String topicId) async =>
      seed.firstWhere((t) => t.id == topicId);

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}

  @override
  Future<void> expandCollapseTopic(String topicId, bool isExpanded) async {}

  @override
  Future<void> unlockNextTopic(String completedTopicId) async {}
}

const _openTopic = Topic(
  id: 'open',
  title: 'Open Topic',
  description: 'open',
  status: TopicStatus.inProgress,
  quizId: 'quiz_open',
);

const _lockedTopic = Topic(
  id: 'locked',
  title: 'Locked Topic',
  description: 'locked',
  status: TopicStatus.locked,
  quizId: 'quiz_locked',
);

Widget _harness(List<Topic> topics) {
  return ChangeNotifierProvider(
    create: (_) => RoadmapViewModel(_FakeRoadmapRepository(topics)),
    child: const MaterialApp(home: RoadmapScreen()),
  );
}

void main() {
  group('Topic gate getters', () {
    test('locked topic cannot start, inProgress can', () {
      expect(_lockedTopic.isLocked, isTrue);
      expect(_lockedTopic.canStart, isFalse);
      expect(_openTopic.isLocked, isFalse);
      expect(_openTopic.canStart, isTrue);
    });
  });

  group('RoadmapScreen gate (US-01)', () {
    testWidgets('tap locked non naviga e mostra SnackBar', (tester) async {
      await tester.pumpWidget(_harness([_openTopic, _lockedTopic]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Locked Topic'));
      await tester.pumpAndSettle();

      expect(find.byType(TopicDetailScreen), findsNothing);
      expect(find.text('Completa i prerequisiti per sbloccare questo topic'),
          findsOneWidget);
    });

    testWidgets('tap su topic sbloccato naviga al detail', (tester) async {
      await tester.pumpWidget(_harness([_openTopic, _lockedTopic]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Topic'));
      await tester.pumpAndSettle();

      expect(find.byType(TopicDetailScreen), findsOneWidget);
    });
  });

  group('TopicDetailScreen quiz entry (AppBar)', () {
    testWidgets('icona quiz presente e naviga a QuizScreen', (tester) async {
      // Il detail ora legge RoadmapViewModel per gestire il QuizResult:
      // va fornito anche in questo harness (in app è globale da main.dart).
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => RoadmapViewModel(_FakeRoadmapRepository([_openTopic])),
          child: const MaterialApp(home: TopicDetailScreen(topic: _openTopic)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.quiz), findsWidgets);

      await tester.tap(find.byTooltip('Avvia Quiz'));
      await tester.pumpAndSettle();

      expect(find.byType(QuizScreen), findsOneWidget);
    });
  });
}
