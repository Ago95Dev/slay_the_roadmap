import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap_models.dart';
import 'quiz_screen.dart';
import '../services/roadmap_service.dart';
import '../widgets/roadmap_tree.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  _RoadmapScreenState createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final RoadmapService _roadmapService = RoadmapService();
  List<Topic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    try {
      final topics = await _roadmapService.getDartRoadmap();
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading roadmap: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTopicTap(String topicId) {
    final topic = _findTopic(_topics, topicId);
    
    if (topic == null) return;
    
    if (topic.status == TopicStatus.locked) {
      _showLockedTopicDialog(topic);
    } else if (topic.status == TopicStatus.inProgress || topic.status == TopicStatus.completed) {
      if (topic.subtopics.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(topicId: topicId),
          ),
        );
      } else {
        _toggleTopicExpansion(topicId);
      }
    }
  }

  void _toggleTopicExpansion(String topicId) {
    setState(() {
      _updateTopic(topicId, (topic) => topic.copyWith(
        isExpanded: !topic.isExpanded
      ));
    });
  }

  void _updateTopic(String topicId, Topic Function(Topic) update) {
    _topics = _updateTopicsRecursive(_topics, topicId, update);
  }

  List<Topic> _updateTopicsRecursive(
    List<Topic> topics, 
    String topicId, 
    Topic Function(Topic) update
  ) {
    return topics.map((topic) {
      if (topic.id == topicId) {
        return update(topic);
      } else if (topic.subtopics.isNotEmpty) {
        return topic.copyWith(
          subtopics: _updateTopicsRecursive(topic.subtopics, topicId, update)
        );
      }
      return topic;
    }).toList();
  }

  Topic? _findTopic(List<Topic> topics, String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) {
        return topic;
      }
      if (topic.subtopics.isNotEmpty) {
        final found = _findTopic(topic.subtopics, topicId);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _showLockedTopicDialog(Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Topic Bloccato'),
        content: Text(
          'Completa i prerequisiti per sbloccare "${topic.title}".'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dart Roadmap'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRoadmap,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? Center(child: Text('Nessuna roadmap disponibile'))
              : RoadmapTree(
                  topics: _topics,
                  onTopicTap: _onTopicTap,
                  onTopicExpand: _toggleTopicExpansion,
                ),
    );
  }
}
