import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/types.dart';
import '../data/topics_and_quizzes.dart';
import '../providers/game_provider.dart';
import '../widgets/compact_stats_bar.dart';
import 'quiz_screen.dart';
import 'resource_browser_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  final RoadmapNode node;
  final String topicId;

  const TopicDetailScreen({
    super.key,
    required this.node,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context) {
    final topic = topicsData.firstWhere(
      (t) => t.id == topicId,
      orElse: () => Topic(
        id: '',
        title: '',
        description: '',
        chapterId: '',
        type: TopicType.core,
        difficulty: '',
        resources: [],
        order: 0,
      ),
    );

    final quiz = getQuizByTopicId(topicId);
    final hasQuiz = quiz != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(node.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Compact stats bar
          const CompactStatsBar(),
          
          // Topic detail content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Banner with Wavy Decoration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(34), // Golden ratio: 34
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21), // Golden ratio: 21
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 13, // Golden ratio: 13
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Title + Dropdown
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                node.title,
                                style: const TextStyle(
                                  fontSize: 34, // Golden ratio: 34
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ),
                            const SizedBox(width: 13), // Golden ratio: 13
                            _buildStatusDropdown(context, topicId),
                          ],
                        ),
                        const SizedBox(height: 21), // Golden ratio: 21
                        
                        // Badges
                        Wrap(
                          spacing: 13, // Golden ratio: 13
                          runSpacing: 13,
                          children: [
                            _buildBadge(
                              topic.difficulty.toUpperCase(),
                              _getDifficultyColor(topic.difficulty),
                            ),
                            _buildBadge(
                              topic.type.name.toUpperCase(),
                              topic.type == TopicType.core ? Colors.orange : Colors.purple,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 34), // Golden ratio: 34

                        // Description Header
                        const Text(
                          'VARIABLES BLOCK',
                          style: TextStyle(
                            fontSize: 13, // Golden ratio: 13
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 13), // Golden ratio: 13
                        
                        // Description Body
                        Text(
                          topic.description.isNotEmpty 
                            ? topic.description 
                            : node.description,
                          style: const TextStyle(
                            fontSize: 21, // Golden ratio: 21
                            color: Colors.black87,
                            height: 1.618, // Golden ratio line height
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Optional Resources Section
                  if (topic.resources.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.rotate(
                            angle: -0.05,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OPTIONAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...topic.resources.map((url) => _buildResourceLink(context, url, topic)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Mini Quiz Button
                  if (hasQuiz)
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      quiz: quiz,
                                      topicId: topicId,
                                      topicTitle: topic.title,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'MINI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'QUIZ',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Comic Sans MS',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Hand Cursor Icon
                          Positioned(
                            bottom: -20,
                            right: -20,
                            child: Transform.rotate(
                              angle: -0.5,
                              child: const Icon(
                                Icons.touch_app,
                                size: 64,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildResourceLink(BuildContext context, String url, Topic topic) {
    final gameProvider = context.watch<GameProvider>();
    final resourceIndex = topic.resources.indexOf(url);
    final hasViewed = gameProvider.hasViewedResource(topicId, resourceIndex);
    
    // Extract display name
    String displayName = url;
    if (url.contains('dart.dev')) {
      displayName = 'Documentation Link';
    } else if (url.contains('youtube')) {
      displayName = 'Video Tutorial';
    } else {
      displayName = 'Extra Resource';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          // Open in-app browser
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (_) => ResourceBrowserScreen(
                url: url,
                resourceTitle: topic.title,
                topicId: topicId,
                resourceIndex: resourceIndex,
              ),
            ),
          );

          if (result != null && result['qualifiesForReward'] == true && context.mounted) {
            final rewardResult = gameProvider.markResourceViewed(
              result['topicId'],
              result['resourceIndex'],
            );

            if (!rewardResult['alreadyViewed'] && context.mounted) {
              _showRewardDialog(context, rewardResult['reward']);
            }
          }
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    displayName.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Center(
                  child: hasViewed
                      ? const Icon(Icons.check_circle, color: Colors.black)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('REW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('ARD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black, width: 2)),
                  color: Colors.transparent,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showRewardDialog(BuildContext context, Map<String, dynamic>? reward) {
    if (reward == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Reward Earned! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You earned rewards for studying this resource!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '+${reward['xp']} XP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '+${reward['gold']} Gold',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, String topicId) {
    final gameProvider = context.watch<GameProvider>();
    final isCompleted = gameProvider.completedTopics.contains(topicId);
    
    // Determine current status for display
    TopicStatus currentStatus = TopicStatus.locked; // Default
    if (gameProvider.completedTopics.contains(topicId)) {
      currentStatus = TopicStatus.completed;
    } else if (gameProvider.skippedTopics.contains(topicId)) {
      currentStatus = TopicStatus.skipped;
    } else {
      // Check if skipped or in progress (logic might need refinement based on provider)
      // For now, if not completed, assume in progress or check if we track skipped separately
      // The provider update logic handles the state change, but reading it back:
      // We only have 'completedTopics' list exposed easily. 
      // Let's assume 'inProgress' if not completed for this UI element or default.
      currentStatus = TopicStatus.inProgress; 
      // Ideally we'd read the exact status from a map in provider if available.
    }

    String statusLabel = 'In Progress';
    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.timelapse;

    if (currentStatus == TopicStatus.completed) {
      statusLabel = 'Done';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (currentStatus == TopicStatus.skipped) {
      statusLabel = 'Skipped';
      statusColor = Colors.grey;
      statusIcon = Icons.skip_next;
    } 
    // Note: 'Skipped' state tracking might need a specific getter in provider if we want to show it persistently.
    // For now, we toggle actions.

    return PopupMenuButton<TopicStatus>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), // Golden ratio: 13
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), // Golden ratio: 13, 8(approx 13/1.618)
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(13), // Golden ratio: 13
          border: Border.all(color: statusColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 21, color: statusColor), // Golden ratio: 21
            const SizedBox(width: 8),
            Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13, // Golden ratio: 13
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: statusColor),
          ],
        ),
      ),
      onSelected: (TopicStatus status) {
        gameProvider.updateTopicStatus(topicId, status);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TopicStatus>>[
        const PopupMenuItem<TopicStatus>(
          value: TopicStatus.inProgress,
          child: Row(
            children: [
              Icon(Icons.timelapse, color: Colors.blue),
              SizedBox(width: 13),
              Text('In Progress'),
            ],
          ),
        ),
        const PopupMenuItem<TopicStatus>(
          value: TopicStatus.completed,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 13),
              Text('Done'),
            ],
          ),
        ),
        const PopupMenuItem<TopicStatus>(
          value: TopicStatus.skipped,
          child: Row(
            children: [
              Icon(Icons.skip_next, color: Colors.grey),
              SizedBox(width: 13),
              Text('Skip'),
            ],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Custom Painter for Wavy Lines
class _WavyLinePainter extends CustomPainter {
  final Color color;

  _WavyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height / 2);

    double x = 0;
    while (x < size.width) {
      path.quadraticBezierTo(
        x + 10, size.height / 2 - 5,
        x + 20, size.height / 2,
      );
      path.quadraticBezierTo(
        x + 30, size.height / 2 + 5,
        x + 40, size.height / 2,
      );
      x += 40;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


