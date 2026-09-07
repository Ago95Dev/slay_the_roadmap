import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/campaign_lore.dart';
import '../../domain/models/player_progress.dart';
import '../../domain/models/quiz.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/topic_detail.dart';
import '../view_models/player_view_model.dart';
import '../view_models/roadmap_view_model.dart';
import '../animations/dungeon_motion.dart';
import '../widgets/player_hud.dart';
import 'quiz_screen.dart';
import 'reward_choice_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  final Topic topic;
  final TopicDetail? topicDetail;

  const TopicDetailScreen({
    super.key,
    required this.topic,
    this.topicDetail,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = topicDetail;

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (topic.quizId != null && !topic.isCompleted)
            IconButton(
              icon: const Icon(Icons.quiz),
              onPressed: () async {
                final vm = context.read<RoadmapViewModel>();
                final result = await Navigator.push<QuizResult>(
                  context,
                  DungeonPageRoute(
                    builder: (context) => QuizScreen(
                      topicId: topic.id,
                      topicTitle: topic.title,
                    ),
                  ),
                );
                if (result?.passed == true) {
                  vm.updateTopicStatus(topic.id, TopicStatus.completed);
                  if (!context.mounted) return;
                  // F3 (US-03): prima del pop a roadmap mostra la scelta
                  // reward (solo se il topic non ha già riscosso).
                  // Se PlayerViewModel non è registrato (es. vecchi test),
                  // si mantiene il comportamento precedente.
                  final playerVm = Provider.of<PlayerViewModel?>(
                    context,
                    listen: false,
                  );
                  if (playerVm != null) {
                    final leveledUp = playerVm.addCompletedTopic(topic.id);
                    // Titolo capitolo (Fase 1B-B): se questo quiz chiudeva
                    // il capitolo E il boss è già sconfitto, assegna ora
                    // il titolo (altrimenti arriverà alla vittoria boss).
                    final chapterId = chapterIdForTopicId(topic.id);
                    if (chapterId != null) {
                      final chapter = _findChapter(vm.topics, chapterId);
                      final bossId = bossIdForChapterId(chapterId);
                      if (chapter != null &&
                          bossId != null &&
                          chapter.isChapterComplete &&
                          playerVm.isBossDefeated(bossId)) {
                        if (playerVm.checkAndAwardChapterTitle(
                          chapterId,
                          chapterComplete: true,
                          bossDefeated: true,
                        )) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🏅 Nuovo titolo: '
                                '${playerVm.progress.activeTitle}!',
                              ),
                            ),
                          );
                        }
                      }
                    }
                    if (leveledUp) {
                      if (!context.mounted) return;
                      // F6: level-up mostrato una sola volta (al crossing).
                      await showLevelUpDialog(
                        context,
                        playerVm.progress.level,
                      );
                      if (!context.mounted) return;
                    }
                    // Streak bonus ogni 3 quiz di fila (+25 XP già accreditati).
                    if (playerVm.progress.streak >=
                            PlayerProgress.streakBonusEvery &&
                        playerVm.progress.streak %
                                PlayerProgress.streakBonusEvery ==
                            0) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Serie x${playerVm.progress.streak}! +${PlayerProgress.streakBonusXp} XP',
                          ),
                        ),
                      );
                    }
                    if (!playerVm.isTopicClaimed(topic.id)) {
                      if (playerVm.isInventoryFull) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Inventario pieno: ricompensa non riscattata',
                            ),
                          ),
                        );
                      } else {
                        await Navigator.push<Reward>(
                          context,
                          DungeonPageRoute(
                            builder: (_) => RewardChoiceScreen(
                              topicId: topic.id,
                            ),
                          ),
                        );
                      }
                    }
                  }
                  if (context.mounted) Navigator.pop(context);
                } else if (result != null && !result.passed) {
                  // Quiz fallito: azzera la serie (streak 0).
                  if (!context.mounted) return;
                  Provider.of<PlayerViewModel?>(
                    context,
                    listen: false,
                  )?.recordQuizFail(topic.id);
                }
              },
              tooltip: 'Avvia Quiz',
            ),
        ],
      ),
      body: detail != null
          ? _buildDetailContent(detail)
          : _buildPlaceholderContent(),
    );
  }

  Widget _buildDetailContent(TopicDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          _buildStatusBadge(),
          const SizedBox(height: 20),

          // Title
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                detail.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Resources Section
          const Text(
            'Learning Resources',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Visit the following resources to learn more:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Links List
          ...detail.links.map((link) => _buildLinkCard(link)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 20),
          Text(
            topic.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                topic.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cerca il capitolo root [chapterId] nei topic della roadmap.
  Topic? _findChapter(List<Topic> topics, String chapterId) {
    for (final topic in topics) {
      if (topic.id == chapterId) return topic;
    }
    return null;
  }

  Widget _buildStatusBadge() {    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (topic.status) {
      case TopicStatus.completed:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        statusText = 'COMPLETATO';
        break;
      case TopicStatus.inProgress:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        statusText = 'IN CORSO';
        break;
      case TopicStatus.locked:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        statusText = 'BLOCCATO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLinkCard(LearningLink link) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: Text(
          link.icon,
          style: const TextStyle(fontSize: 20),
        ),
        title: Text(
          link.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          link.url,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.blue),
        ),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () => _launchUrl(link.url),
      ),
    );
  }
}
