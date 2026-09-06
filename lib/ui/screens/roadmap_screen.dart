import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/boss_repository.dart';
import '../../domain/models/topic.dart';
import '../view_models/boss_fight_view_model.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import '../animations/dungeon_motion.dart';
import '../widgets/player_hud.dart';
import '../widgets/roadmap/roadmap_tree.dart';
import 'boss_fight_active_screen.dart';
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
      DungeonPageRoute(
        builder: (context) => TopicDetailScreen(
          topic: topic,
          topicDetail: topic.detail,
        ),
      ),
    );
  }

  /// Tap sul nodo boss a fine capitolo (campagna US-04): locked finché
  /// il capitolo non è interamente completato, altrimenti apre
  /// `BossFightActiveScreen` diretto (stesso setup del push da lista).
  /// Al rientro ricalcola gli unlock (la vittoria apre il capitolo dopo).
  void _onBossTap(String bossId, String chapterId) {
    final roadmapVm = context.read<RoadmapViewModel>();
    final chapter = _findTopic(roadmapVm.topics, chapterId);
    if (chapter?.bossId == null) return;

    if (chapter != null && !chapter.isChapterComplete) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa tutti i topic del capitolo per sfidare il boss',
          ),
        ),
      );
      return;
    }

    final playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
    if (playerVm != null && !playerVm.canEnterBoss) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supera un quiz per recuperare una vita'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      DungeonPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => BossFightViewModel(BossRepository()),
          child: BossFightActiveScreen(
            bossId: bossId,
            chapterCompleted: true,
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      context.read<RoadmapViewModel>().reevaluateUnlocks();
    });
  }

  /// `PlayerViewModel.isBossDefeated` se registrato (in app da `main.dart`),
  /// null nei vecchi test con solo `RoadmapViewModel`.
  bool Function(String)? _bossDefeatedLookup() {
    try {
      final playerVm =
          Provider.of<PlayerViewModel?>(context, listen: false);
      return playerVm?.isBossDefeated;
    } catch (_) {
      return null;
    }
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
    showPopDialog(
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
              // HUD globale (F6): XP bar + livello, sopra le stats.
              _buildHudSlot(),
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

              // Roadmap tree: scrollabile (a 800x600 l'albero intero non
              // ci sta); HUD e stats restano fisse sopra.
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.loadRoadmap();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RoadmapTree(
                      topics: viewModel.topics,
                      onTopicTap: _onTopicTap,
                      onTopicExpand: (topicId) {
                        viewModel.toggleTopicExpansion(topicId);
                      },
                      isBossDefeated: _bossDefeatedLookup(),
                      onBossTap: _onBossTap,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// HUD globale (F6): nascosto se PlayerViewModel non è registrato
  /// (es. vecchi test che forniscono solo RoadmapViewModel).
  Widget _buildHudSlot() {
    return Builder(
      builder: (context) {
        try {
          final progress = Provider.of<PlayerViewModel>(context).progress;
          return PlayerHud(progress: progress);
        } catch (_) {
          return const SizedBox.shrink();
        }
      },
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
