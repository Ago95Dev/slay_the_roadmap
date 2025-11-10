import 'topic.dart';
import 'reward.dart';

class PlayerProgress {
  final List<Topic> completedTopics;
  final List<Reward> obtainedRewards;
  final Map<String, int> bossProgress; // chapterId -> bossHp

  PlayerProgress({
    required this.completedTopics,
    required this.obtainedRewards,
    required this.bossProgress,
  });

  factory PlayerProgress.initial() {
    return PlayerProgress(
      completedTopics: [],
      obtainedRewards: [],
      bossProgress: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedTopics': completedTopics.map((t) => t.id).toList(),
      'obtainedRewards': obtainedRewards.map((r) => r.id).toList(),
      'bossProgress': bossProgress,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    // Questo è un esempio semplificato, in pratica dovresti ricostruire
    // gli oggetti Topic e Reward dai loro ID
    return PlayerProgress(
      completedTopics: [],
      obtainedRewards: [],
      bossProgress: Map<String, int>.from(json['bossProgress'] ?? {}),
    );
  }
}
