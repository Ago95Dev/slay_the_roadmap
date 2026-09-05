import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/topic_detail.dart';
import 'quiz_screen.dart';

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      topicId: topic.id,
                      topicTitle: topic.title,
                    ),
                  ),
                );
              },
              tooltip: 'Avvia Quiz',
            ),
        ],
      ),
      body: detail != null ? _buildDetailContent(detail) : _buildPlaceholderContent(),
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
          const SizedBox(height: 20),

          // Quiz Button
          if (topic.quizId != null && !topic.isCompleted)
            _buildQuizButton(),
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
          const SizedBox(height: 20),
          if (topic.quizId != null && !topic.isCompleted)
            _buildQuizButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
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

  Widget _buildQuizButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // La navigazione al quiz è gestita nell'AppBar action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 20),
            SizedBox(width: 8),
            Text(
              'Avvia Quiz per Completare il Topic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
