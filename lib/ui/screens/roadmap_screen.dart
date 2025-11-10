import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/topic.dart';
import 'quiz_screen.dart';
import '../view_model/roadmap_view_model.dart';
import '../widgets/roadmap/roadmap_tree.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  _RoadmapScreenState createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoadmapViewModel>().loadRoadmap();
    });
  }

  void _onTopicTap(String topicId) {
    final viewModel = context.read<RoadmapViewModel>();
    final topic = viewModel.findTopic(topicId);
    
    if (topic == null) return;
    
    if (topic.status == TopicStatus.locked) {
      _showLockedTopicDialog(topic);
    } else if (topic.status == TopicStatus.inProgress || topic.status == TopicStatus.completed) {
      if (topic.subtopics.isEmpty) {
        // Solo i topic foglia (senza sottotopic) hanno il quiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(topicId: topicId),
          ),
        );
      } else {
        // I topic con sottotopic si espandono/contraggono al tap
        viewModel.toggleTopicExpansion(topicId);
      }
    }
  }

  void _showLockedTopicDialog(Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Topic Bloccato'),
        content: Text(
          'Completa i prerequisiti per sbloccare "${topic.title}".'
          '${topic.prerequisites.isNotEmpty ? '\n\nPrerequisiti: ${topic.prerequisites.join(', ')}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Roadmap - Slay the Roadmap'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RoadmapViewModel>().loadRoadmap(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'legend') {
                _showLegendDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'legend',
                child: Text('Mostra Legenda'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<RoadmapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.topics.isEmpty) {
            return const Center(
              child: Text('Nessuna roadmap disponibile'),
            );
          }

          return RoadmapTree(
            topics: viewModel.topics,
            onTopicTap: _onTopicTap,
            onTopicExpand: (topicId) {
              viewModel.toggleTopicExpansion(topicId);
            },
          );
        },
      ),
    );
  }

  void _showLegendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Legenda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(Colors.green, 'Completato', Icons.check_circle),
            _buildLegendItem(Colors.orange, 'In Corso', Icons.play_circle_fill),
            _buildLegendItem(Colors.grey, 'Bloccato', Icons.lock),
            const SizedBox(height: 16),
            _buildLegendItem(Colors.blue, 'Core (Obbligatorio)', null, isType: true),
            _buildLegendItem(Colors.purple, 'Optional', null, isType: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, IconData? icon, {bool isType = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: color, size: 20)
          else if (isType)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
