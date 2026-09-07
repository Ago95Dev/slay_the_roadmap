import '../../domain/models/campaign.dart';
import '../../domain/models/topic.dart';
import 'topic_detail_repository.dart';

abstract class RoadmapRepository {
  Future<List<Topic>> getDartRoadmap({String? campaignId});
  Future<void> updateTopicStatus(String topicId, TopicStatus status);
  Future<void> expandCollapseTopic(String topicId, bool isExpanded);
  Future<void> unlockNextTopic(String completedTopicId);
  Future<Topic?> getTopicWithDetail(String topicId, {String? campaignId});
}

class LocalRoadmapRepository implements RoadmapRepository {
  final TopicDetailRepository _detailRepository = LocalTopicDetailRepository();

  final List<Topic> _dartRoadmap = [
    Topic(
      id: 'web_network',
      title: 'La Rete',
      description: 'Come i computer si trovano, si parlano e si scambiano contenuti',
      isOptional: false,
      status: TopicStatus.inProgress,
      isExpanded: true,
      quizId: 'quiz_web_network',
      bossId: 'man_in_the_middle',
      bossName: 'Man-in-the-Middle',
      subtopics: [
        Topic(
          id: 'net_client_server',
          title: 'Client e server',
          description: 'Chi chiede e chi risponde nella conversazione web',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['web_network'],
          quizId: 'quiz_net_client_server',
        ),
        Topic(
          id: 'net_dns_url',
          title: 'Indirizzi e nomi',
          description: 'Come i nomi diventano indirizzi e le risorse si localizzano',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['net_client_server'],
          quizId: 'quiz_net_dns_url',
        ),
        Topic(
          id: 'net_http_https',
          title: 'HTTP e HTTPS',
          description: 'Il linguaggio della conversazione web, in chiaro e cifrato',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['net_client_server'],
          quizId: 'quiz_net_http_https',
        ),
      ],
    ),
    Topic(
      id: 'web_data',
      title: 'Dati e Stato',
      description: 'Rappresentare, custodire e ricordare i dati sul web',
      isOptional: false,
      status: TopicStatus.locked,
      prerequisites: ['web_network'],
      requiredBossId: 'man_in_the_middle',
      bossId: 'the_amnesiac',
      bossName: 'The Amnesiac',
      quizId: 'quiz_web_data',
      subtopics: [
        Topic(
          id: 'data_represent',
          title: 'Rappresentare i dati',
          description: 'Forme e formati: come le informazioni viaggiano e si leggono',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['web_data'],
          quizId: 'quiz_data_represent',
        ),
        Topic(
          id: 'data_where',
          title: 'Dove vivono i dati',
          description: 'Frontend, backend e database: tre case per tre mestieri',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['data_represent'],
          quizId: 'quiz_data_where',
        ),
        Topic(
          id: 'data_state',
          title: 'Ricordare (stato, sessioni, cache)',
          description: 'Le memorie aggiuntive di un web smemorato (Opzionale)',
          isOptional: true,
          status: TopicStatus.locked,
          prerequisites: ['data_where'],
          quizId: 'quiz_data_state',
        ),
      ],
    ),
    Topic(
      id: 'web_building',
      title: 'Costruire sul Web',
      description: 'Dal browser alle app: mostrare, organizzare e spedire',
      isOptional: false,
      status: TopicStatus.locked,
      prerequisites: ['web_data'],
      requiredBossId: 'the_amnesiac',
      bossId: 'spaghetti_colossus',
      bossName: 'Spaghetti Colossus',
      quizId: 'quiz_web_building',
      subtopics: [
        Topic(
          id: 'build_browser',
          title: 'Come ragiona il browser',
          description: 'Interpretare, comporre e dipingere le pagine',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['web_building'],
          quizId: 'quiz_build_browser',
        ),
        Topic(
          id: 'build_framework',
          title: 'Domare la complessità',
          description: 'Componenti e stato quando le pagine diventano app',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['web_building'],
          quizId: 'quiz_build_framework',
        ),
        Topic(
          id: 'build_ship',
          title: 'Versionare e spedire',
          description: 'Tappe, rami e consegna: sbagliare a basso costo',
          isOptional: false,
          status: TopicStatus.locked,
          prerequisites: ['web_building'],
          quizId: 'quiz_build_ship',
        ),
      ],
    ),
  ];

  @override
  Future<List<Topic>> getDartRoadmap({String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 500));
    return _dartRoadmap;
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    print('Updating topic $topicId to status: $status');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> expandCollapseTopic(String topicId, bool isExpanded) async {
    print('Setting topic $topicId expanded: $isExpanded');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> unlockNextTopic(String completedTopicId) async {
    print('Unlocking next topics after completing: $completedTopicId');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<Topic?> getTopicWithDetail(String topicId,
      {String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    final topic = _findTopic(_dartRoadmap, topicId);
    if (topic != null) {
      final detail = await _detailRepository.getTopicDetail(topicId);
      return topic.copyWith(detail: detail);
    }
    return null;
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
}
