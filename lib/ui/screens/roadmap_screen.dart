import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/boss_repository.dart';
import '../../domain/models/campaign_lore.dart';
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
  /// Guardia anti-doppio dialog del finale (rebuild durante l'apertura).
  bool _campaignDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RoadmapViewModel>().loadRoadmap();
      if (!mounted) return;
      await _maybeShowCampaignComplete();
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

    // Intro capitolo (Fase 1B-A): alla prima apertura del capitolo per
    // save, prima del dettaglio; poi mai più fino a New Run.
    final chapterId = chapterIdForTopicId(topicId);
    if (chapterId != null) {
      final playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
      if (playerVm != null && !playerVm.hasSeenChapterIntro(chapterId)) {
        if (!mounted) return;
        await showPopDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            key: Key('chapter_intro_$chapterId'),
            title: Text(chapterIntroTitles[chapterId] ?? 'Nuovo capitolo'),
            content: Text(chapterIntros[chapterId] ?? ''),
            actions: [
              FilledButton(
                key: const Key('chapter_intro_ok'),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Inizia l\u2019esplorazione'),
              ),
            ],
          ),
        );
        playerVm.markChapterIntroSeen(chapterId);
        if (!mounted) return;
      }
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
  /// il capitolo non è interamente completato, altrimenti mostra il dialog
  /// lore pre-fight (Fase 1B-A: Combatti/Indietro) e solo su Combatti apre
  /// `BossFightActiveScreen` diretto (stesso setup del push da lista).
  /// Al rientro ricalcola gli unlock (la vittoria apre il capitolo dopo)
  /// e controlla il finale campagna.
  Future<void> _onBossTap(String bossId, String chapterId) async {
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

    // Lore pre-fight (Fase 1B-A): dialog con Combatti/Indietro prima di
    // ogni boss fight. Voce C: riga "Tratto: ..." con la passiva del boss.
    if (!mounted) return;
    final bossName = bossNames[bossId] ?? chapter?.bossName ?? 'Boss';
    final trait = bossTrait(bossId);
    final proceed = await showPopDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('boss_lore_dialog'),
        title: Text('👹 $bossName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bossLores[bossId] ?? 'Un guardiano del web ti sbarra la strada.',
            ),
            if (trait.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                trait,
                key: const Key('boss_lore_trait'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            key: const Key('boss_lore_back'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Indietro'),
          ),
          FilledButton(
            key: const Key('boss_lore_fight'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Combatti'),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

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
    ).then((_) async {
      if (!mounted) return;
      context.read<RoadmapViewModel>().reevaluateUnlocks();
      // Rete di sicurezza titoli (Fase 1B-B): ricalcola su tutti i
      // capitoli (copre i casi in cui la victory screen non aveva
      // PlayerViewModel o il capitolo si è chiuso dopo).
      _awardEarnedTitles();
      await _maybeShowCampaignComplete();
    });
  }

  /// Assegna ogni titolo di capitolo meritato (capitolo intero + boss
  /// sconfitto) e ancora non attivo. Ultimo vinto = attivo.
  void _awardEarnedTitles() {
    final playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
    if (playerVm == null) return;
    final roadmapVm = context.read<RoadmapViewModel>();
    if (roadmapVm.topics.isEmpty) return;
    for (final chapterId in chapterIds) {
      final chapter = _findTopic(roadmapVm.topics, chapterId);
      final bossId = bossIdForChapterId(chapterId);
      if (chapter == null || bossId == null) continue;
      playerVm.checkAndAwardChapterTitle(
        chapterId,
        chapterComplete: chapter.isChapterComplete,
        bossDefeated: playerVm.isBossDefeated(bossId),
      );
    }
  }

  /// Finale campagna (Fase 1B-A): tutti i capitoli completi + tutti i
  /// boss sconfitti → schermata "Campagna completata!" con stats, una
  /// sola volta per completamento (flag persistito), non a ogni apertura.
  Future<void> _maybeShowCampaignComplete() async {
    if (!mounted || _campaignDialogOpen) return;
    final playerVm = Provider.of<PlayerViewModel?>(context, listen: false);
    if (playerVm == null) return;
    final roadmapVm = context.read<RoadmapViewModel>();
    if (roadmapVm.topics.isEmpty) return;
    if (playerVm.hasSeenCampaignCompletion) return;
    if (!roadmapVm.isCampaignComplete(playerVm.isBossDefeated)) return;
    _campaignDialogOpen = true;
    playerVm.markCampaignCompletionSeen();
    await _showCampaignCompleteDialog(playerVm);
    _campaignDialogOpen = false;
  }

  Future<void> _showCampaignCompleteDialog(PlayerViewModel playerVm) {
    final progress = playerVm.progress;
    final defeated =
        campaignBossIds.where(playerVm.isBossDefeated).length;
    final titleLine = progress.activeTitle.isNotEmpty
        ? '🏅 ${progress.activeTitle}\n'
        : '';
    final stats =
        '${titleLine}XP: ${progress.experience} • Livello ${progress.level}\n'
        'Serie migliore: x${progress.maxStreak}\n'
        'Boss sconfitti: $defeated/${campaignBossIds.length}';
    return showPopDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('campaign_complete_dialog'),
        title: const Text(campaignCompleteTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(campaignCompleteBody),
            const SizedBox(height: 12),
            Text(
              stats,
              key: const Key('campaign_complete_stats'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('campaign_back'),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Torna alla roadmap'),
          ),
          FilledButton(
            key: const Key('campaign_replay'),
            onPressed: () => _confirmReplay(ctx),
            child: const Text('Rigioca'),
          ),
        ],
      ),
    );
  }

  /// Rigioca con conferma stile New Run: wipe + reset roadmap e ritorno
  /// alla Home.
  Future<void> _confirmReplay(BuildContext dialogContext) async {
    final confirmed = await showPopDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Ricominciare la campagna?'),
        content: const Text(
          'Perderai topic completati, XP, reward e boss sconfitti. Continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('RICOMINCIA'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<PlayerViewModel>().wipe();
    if (!mounted) return;
    await context.read<RoadmapViewModel>().resetToInitial();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
              // Da ripassare (F12): topic con 2+ fallimenti, nascosta
              // se vuota o senza PlayerViewModel (vecchi test).
              _buildReviewSection(viewModel),
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

  /// Sezione "Da ripassare" (F12): topic con 2+ quiz falliti, ordinati
  /// per fallimenti desc; tap → detail (stesso flusso del tap sull'albero:
  /// gate, intro capitolo, detail). Nascosta se vuota o se PlayerViewModel
  /// non è registrato (es. vecchi test con solo RoadmapViewModel).
  Widget _buildReviewSection(RoadmapViewModel viewModel) {
    return Builder(
      builder: (context) {
        try {
          final playerVm = Provider.of<PlayerViewModel>(context);
          final review = playerVm.reviewTopics;
          if (review.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Card(
              key: const Key('review_section'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      '📚 Da ripassare',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final topicId in review)
                    ListTile(
                      key: Key('review_topic_$topicId'),
                      dense: true,
                      leading: const Icon(Icons.replay),
                      title: Text(_titleFor(viewModel.topics, topicId)),
                      trailing: Text(
                        '❌×${playerVm.failCountOf(topicId)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _onTopicTap(topicId),
                    ),
                ],
              ),
            ),
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// Titolo del topic [topicId] per "Da ripassare"; fallback all'id se
  /// il topic non è più nell'albero (seed cambiato dopo il save).
  String _titleFor(List<Topic> topics, String topicId) =>
      _findTopic(topics, topicId)?.title ?? topicId;

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
