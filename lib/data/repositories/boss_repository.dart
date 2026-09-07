import '../../domain/models/boss_fight.dart';
import '../../domain/models/campaign.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/quiz.dart';
import 'quiz_repository.dart';
import 'package:flutter/foundation.dart';

class BossRepository {
  final QuizRepository _quizRepository;

  BossRepository({QuizRepository? quizRepository})
      : _quizRepository = quizRepository ?? LocalQuizRepository();

  /// Topic del capitolo: da qui si pescano le domande del turno boss.
  static List<String> chapterTopicIds(String chapterId,
      [String? campaignId]) {
    CampaignRepository.requireActive(campaignId);
    switch (chapterId) {
      case 'web_network':
        return const [
          'web_network',
          'net_client_server',
          'net_dns_url',
          'net_http_https',
        ];
      case 'web_data':
        return const [
          'web_data',
          'data_represent',
          'data_where',
          'data_state',
        ];
      case 'web_building':
        return const [
          'web_building',
          'build_browser',
          'build_framework',
          'build_ship',
        ];
      default:
        return const [];
    }
  }

  // Mock boss fights for now
  Future<List<BossFight>> getAllBosses({String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      for (final boss in _mockBosses)
        await _withChapterQuizzes(boss, campaignId),
    ];
  }

  Future<BossFight?> getBossById(String id, {String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return await _withChapterQuizzes(
        _mockBosses.firstWhere((boss) => boss.id == id),
        campaignId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<BossFight?> getBossByChapterId(String chapterId,
      {String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return await _withChapterQuizzes(
        _mockBosses.firstWhere((boss) => boss.chapterId == chapterId),
        campaignId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Se il boss non ha adaptiveQuizzes, li popola con i quiz dei topic
  /// del suo capitolo (fallback per il turno boss).
  @visibleForTesting
  Future<BossFight> populateChapterQuizzes(BossFight boss,
          {String? campaignId}) =>
      _withChapterQuizzes(boss, campaignId);

  Future<BossFight> _withChapterQuizzes(BossFight boss,
      [String? campaignId]) async {
    if (boss.adaptiveQuizzes.isNotEmpty) return boss;
    final quizzes = <Quiz>[];
    for (final topicId in chapterTopicIds(boss.chapterId, campaignId)) {
      try {
        quizzes.add(await _quizRepository.getQuizForTopic(topicId,
            campaignId: campaignId));
      } catch (_) {
        // Topic senza quiz: si salta, le altre domande bastano.
      }
    }
    if (quizzes.isEmpty) return boss;
    return boss.copyWith(adaptiveQuizzes: quizzes);
  }

  // Mock data
  static final List<BossFight> _mockBosses = [
    BossFight(
      id: 'man_in_the_middle',
      chapterId: 'web_network',
      name: 'Man-in-the-Middle',
      maxHp: 10,
      currentHp: 10,
      maxPlayerHp: 3,
      currentPlayerHp: 3,
      availableRewards: [
        const Reward(
          id: 'reward_1',
          name: 'Quick Learner',
          description: 'Gain +10% quiz score on network topics',
          type: RewardType.utility,
          rarity: RewardRarity.common,
          icon: '📚',
          effects: {'quizBonus': 0.1, 'topics': ['web_network']},
        ),
        const Reward(
          id: 'reward_2',
          name: 'Syntax Master',
          description: 'Deal +5 damage on correct network questions',
          type: RewardType.attack,
          rarity: RewardRarity.rare,
          icon: '⚔️',
          effects: {'damage': 5, 'questionType': 'network'},
        ),
        const Reward(
          id: 'reward_3',
          name: 'Defender Shield',
          description: 'Reduce damage from boss attacks by 3',
          type: RewardType.defense,
          rarity: RewardRarity.common,
          icon: '🛡️',
          effects: {'damageReduction': 3},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_network_1',
          topicId: 'web_network',
          questions: [
            const Question(
              text: 'Apri un sito: chi inizia la conversazione?',
              options: ['Il server invia la pagina da solo', 'Il client chiede, il server risponde', 'Il DNS crea la pagina', 'Il browser indovina'],
              correctAnswerIndex: 1,
              explanation: 'Tutto parte da una richiesta del client.',
            ),
            const Question(
              text: 'A cosa serve il DNS?',
              options: ['Cifrare i dati', 'Tradurre nomi di dominio in indirizzi IP', 'Creare pagine web', 'Velocizzare il CSS'],
              correctAnswerIndex: 1,
              explanation: 'È la rubrica di Internet.',
            ),
            const Question(
              text: 'Compili un form con la carta: perché serve HTTPS?',
              options: ['Il sito carica prima', 'In HTTP chi intercetta legge tutto in chiaro', 'Evita i 404', 'Il browser lo richiede per i colori'],
              correctAnswerIndex: 1,
              explanation: 'Cifratura del trasporto, non del sito.',
            ),
          ],
          passingThreshold: 70,
        ),
      ],
    ),
    BossFight(
      id: 'the_amnesiac',
      chapterId: 'web_data',
      name: 'The Amnesiac',
      maxHp: 10,
      currentHp: 10,
      maxPlayerHp: 3,
      currentPlayerHp: 3,
      availableRewards: [
        const Reward(
          id: 'reward_4',
          name: 'Widget Wisdom',
          description: 'Gain insight into where app data lives',
          type: RewardType.utility,
          rarity: RewardRarity.epic,
          icon: '🧠',
          effects: {'hintChance': 0.25},
        ),
        const Reward(
          id: 'reward_5',
          name: 'Critical Strike',
          description: 'Deal double damage on perfect answers',
          type: RewardType.attack,
          rarity: RewardRarity.legendary,
          icon: '💥',
          effects: {'criticalMultiplier': 2.0},
        ),
        const Reward(
          id: 'reward_6',
          name: 'Health Potion',
          description: 'Restore 20 HP when quiz score > 80%',
          type: RewardType.defense,
          rarity: RewardRarity.rare,
          icon: '❤️',
          effects: {'healing': 20, 'threshold': 0.8},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_data_1',
          topicId: 'web_data',
          questions: [
            const Question(
              text: 'Quando conviene pensare a "lista" e quando a "mappa"?',
              options: ['Sono uguali', 'Lista quando conta l\u2019ordine, mappa quando conta ritrovare per nome', 'Lista per i numeri, mappa per le foto', 'A caso'],
              correctAnswerIndex: 1,
              explanation: 'La domanda è "come lo ritroverò?".',
            ),
            const Question(
              text: 'Come fa un sito a ricordarti il login da una pagina all\u2019altra?',
              options: ['Indovina', 'Il browser ripresenta un bigliettino (cookie) e il server lo lega alla tua sessione', 'Lo scrive nell\u2019URL in chiaro', 'Lo chiede ogni volta'],
              correctAnswerIndex: 1,
              explanation: 'Riconoscimento = gettone ripresentato + registro lato server.',
            ),
          ],
          passingThreshold: 75,
        ),
      ],
    ),
    BossFight(
      id: 'spaghetti_colossus',
      chapterId: 'web_building',
      name: 'Spaghetti Colossus',
      maxHp: 10,
      currentHp: 10,
      maxPlayerHp: 3,
      currentPlayerHp: 3,
      availableRewards: [
        const Reward(
          id: 'reward_7',
          name: 'Future Vision',
          description: 'See upcoming boss moves',
          type: RewardType.utility,
          rarity: RewardRarity.legendary,
          icon: '🔮',
          effects: {'foresight': 1},
        ),
        const Reward(
          id: 'reward_8',
          name: 'Async Blade',
          description: 'Deal massive damage on building questions',
          type: RewardType.attack,
          rarity: RewardRarity.epic,
          icon: '🗡️',
          effects: {'damage': 15, 'questionType': 'building'},
        ),
      ],
      adaptiveQuizzes: [
        Quiz(
          id: 'quiz_boss_building_1',
          topicId: 'build_ship',
          questions: [
            const Question(
              text: 'Perché separare cosa c\u2019è, come appare e cosa fa?',
              options: ['Moda', 'Per cambiare un aspetto senza rompere gli altri', 'Per andare offline', 'Per usare più file'],
              correctAnswerIndex: 1,
              explanation: 'Separazione = modifiche indipendenti.',
            ),
            const Question(
              text: 'Perché spedire spesso piccoli passi è più sicuro di un unico grande lancio?',
              options: ['Non lo è', 'Se qualcosa si rompe, sai quale passo è colpevole e torni indietro di poco', 'Costa meno', 'È più emozionante'],
              correctAnswerIndex: 1,
              explanation: 'Piccoli passi = colpevoli piccoli e vicini.',
            ),
          ],
          passingThreshold: 80,
        ),
      ],
    ),
  ];
}
