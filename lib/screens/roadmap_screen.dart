import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/types.dart';
import '../data/topics_and_quizzes.dart';
import '../providers/game_provider.dart';
import '../widgets/compact_stats_bar.dart';
import '../widgets/topic_node.dart';
import 'topic_detail_screen.dart';
import 'boss_fight_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  // Map to track expanded state of topics (since it's UI state)
  final Set<String> _expandedTopics = {};

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final completedTopics = gameProvider.completedTopics;

    // Group topics by chapter
    final chapters = {
      'chapter-1': {'title': 'BASICS', 'topics': <Topic>[]},
      'chapter-2': {'title': 'CONTROL FLOW', 'topics': <Topic>[]},
      'chapter-3': {'title': 'OOP', 'topics': <Topic>[]},
    };

    // Populate chapters with topics
    for (var topic in topicsData) {
      if (chapters.containsKey(topic.chapterId)) {
        // Update topic status based on game progress
        if (completedTopics.contains(topic.id)) {
          topic.status = TopicStatus.completed;
        } else if (gameProvider.skippedTopics.contains(topic.id)) {
          topic.status = TopicStatus.skipped;
        } else if (_isTopicUnlocked(topic, completedTopics)) {
          topic.status = TopicStatus.inProgress;
        } else {
          topic.status = TopicStatus.locked;
        }
        
        // Update expanded state
        topic.isExpanded = _expandedTopics.contains(topic.id);
        
        (chapters[topic.chapterId]!['topics'] as List<Topic>).add(topic);
      }
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0a0806),
            Color(0xFF1a1410),
            Color(0xFF0a0806),
          ],
        ),
      ),
      child: Column(
        children: [
          // Compact Stats Bar
          const CompactStatsBar(),

          // Roadmap Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildChapterNode(context, 'chapter-1', chapters['chapter-1']!),
                _buildConnectorLine(),
                _buildChapterNode(context, 'chapter-2', chapters['chapter-2']!),
                _buildConnectorLine(),
                _buildMidBossNode('BASIC TEST'),
                _buildConnectorLine(),
                _buildChapterNode(context, 'chapter-3', chapters['chapter-3']!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isTopicUnlocked(Topic topic, List<String> completedTopics) {
    // Logic to determine if topic is unlocked
    // For now, unlock if previous topic is completed or it's the first one
    if (topic.order == 1 && topic.chapterId == 'chapter-1') return true;
    
    // Find previous topic
    // This is simplified; real logic would check dependencies
    return true; // Unlock all for demo/testing purposes or implement real logic
  }

  Widget _buildChapterNode(
    BuildContext context,
    String chapterId,
    Map<String, dynamic> chapterData,
  ) {
    final title = chapterData['title'] as String;
    final topics = chapterData['topics'] as List<Topic>;

    return Column(
      children: [
        // Gothic Chapter Node
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1a1410),
                Color(0xFF2d1f1a),
              ],
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFFd4af37), width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Color(0xFFfbbf24),
              shadows: [
                Shadow(
                  color: Color(0xFFfbbf24),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Connector from Chapter to Topics
        if (topics.isNotEmpty) ...[
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF8b6f47),
                  const Color(0xFF8b6f47).withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          // Topics Tree
          ...topics.map((topic) => _buildTopicTree(topic)),
        ],
      ],
    );
  }

  Widget _buildTopicTree(Topic topic) {
    return Column(
      children: [
        // Horizontal connector if multiple siblings (simplified for now)
        
        // The Topic Node
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TopicNode(
            topic: topic,
            depth: 0,
            onTopicTap: (t) => _handleTopicTap(t),
            onToggleExpansion: (id) {
              setState(() {
                if (_expandedTopics.contains(id)) {
                  _expandedTopics.remove(id);
                } else {
                  _expandedTopics.add(id);
                }
              });
            },
          ),
        ),
        
        // Connector to next sibling
        Container(
          width: 3,
          height: 16,
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildMidBossNode(String title) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BossFightScreen(bossId: 'syntax_sentinel'),
                ),
              );
            },
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7f1d1d),
                    Color(0xFF991b1b),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFef4444), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFef4444).withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Reward Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF78350f),
                          Color(0xFF92400e),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFfbbf24), width: 2),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'REW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFfbbf24),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'ARD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFfbbf24),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Color(0xFFfca5a5),
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Boss Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.sentiment_very_dissatisfied,
                      size: 40,
                      color: Color(0xFFfca5a5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine() {
    return Center(
      child: Container(
        width: 3,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF8b6f47).withValues(alpha: 0.3),
              const Color(0xFF8b6f47),
              const Color(0xFF8b6f47).withValues(alpha: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTopicTap(Topic topic) {
    if (topic.status == TopicStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete previous topics to unlock this one!')),
      );
      return;
    }

    // Convert Topic to RoadmapNode for compatibility with TopicDetailScreen
    // In a real app, we might refactor TopicDetailScreen to take Topic directly
    final node = RoadmapNode(
      id: topic.id,
      type: RoadmapNodeType.topic,
      topicId: topic.id,
      title: topic.title,
      description: topic.description,
      tier: 0,
      lane: 0,
      connections: [],
      rewards: [],
      chapterId: topic.chapterId,
      unlocked: true,
      completed: topic.status == TopicStatus.completed,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicDetailScreen(
          node: node,
          topicId: topic.id,
        ),
      ),
    );
  }
}
