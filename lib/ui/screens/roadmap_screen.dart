import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/topic.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import '../widgets/roadmap/roadmap_tree.dart';
import 'topic_detail_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoadmapViewModel>().loadRoadmap();
    });
  }

  void _onTopicTap(String topicId) async {
    final viewModel = context.read<RoadmapViewModel>();
    final topic = _findTopic(viewModel.topics, topicId);
    
    if (topic == null) return;

    // Gate F1 (US-01): i topic locked non sono navigabili.
    if (topic.isLocked) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa i prerequisiti per sbloccare questo topic'),
        ),
      );
      return;
    }

    // Mostra sempre i dettagli del topic quando viene cliccato
    final topicWithDetail = await viewModel.getTopicWithDetail(topicId);

    if (!mounted) return;
    if (topicWithDetail != null) {
      _showTopicDetail(topicWithDetail);
    } else {
      // Fallback: mostra i dettagli base se non ci sono dettagli specifici
      _showTopicDetail(topic);
    }
  }

  void _showTopicDetail(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(
          topic: topic,
          topicDetail: topic.detail,
        ),
      ),
    );
  }

  Topic? _findTopic(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
      final found = _findTopicInSubtopic(topic.subtopics, topicId);
      if (found != null) return found;
    }
    return null;
  }

  Topic? _findTopicInSubtopic(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
      final found = _findTopicInSubtopic(topic.subtopics, topicId);
      if (found != null) return found;
    }
    return null;
  }

  void _showInventory(BuildContext context) {
    final playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
    final rewards = playerVm?.inventory.rewards ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventario'),
        content: rewards.isEmpty
            ? const Text(
                'Nessuna ricompensa ancora. Completa un quiz!',
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    return ListTile(
                      leading: Text(
                        reward.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(reward.name),
                      subtitle: Text(reward.rarity.name),
                    );
                  },
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dart Learning Roadmap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.style),
            onPressed: () => _showInventory(context),
            tooltip: 'Inventario (deck)',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RoadmapViewModel>().loadRoadmap(),
            tooltip: 'Ricarica roadmap',
          ),
        ],
      ),
      body: Consumer<RoadmapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.topics.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento roadmap...'),
                ],
              ),
            );
          }

          if (viewModel.error != null && viewModel.topics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Errore nel caricamento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.retryLoading,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Completati',
                      _countCompletedTopics(viewModel.topics).toString(),
                      Colors.green,
                    ),
                    _buildStatItem(
                      'In Corso',
                      _countInProgressTopics(viewModel.topics).toString(),
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Totali',
                      _countAllTopics(viewModel.topics).toString(),
                      Colors.blue,
                    ),
                  ],
                ),
              ),
              
              // Roadmap tree
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.loadRoadmap();
                  },
                  child: RoadmapTree(
                    topics: viewModel.topics,
                    onTopicTap: _onTopicTap,
                    onTopicExpand: (topicId) {
                      viewModel.toggleTopicExpansion(topicId);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  int _countCompletedTopics(List<Topic> topics) {
    int count = 0;
    for (final topic in topics) {
      if (topic.status == TopicStatus.completed) count++;
      count += _countCompletedTopics(topic.subtopics);
    }
    return count;
  }

  int _countInProgressTopics(List<Topic> topics) {
    int count = 0;
    for (final topic in topics) {
      if (topic.status == TopicStatus.inProgress) count++;
      count += _countInProgressTopics(topic.subtopics);
    }
    return count;
  }

  int _countAllTopics(List<Topic> topics) {
    int count = 0;
    for (final topic in topics) {
      count++;
      count += _countAllTopics(topic.subtopics);
    }
    return count;
  }
}
