import 'package:equatable/equatable.dart';

/// Stato di pubblicazione di una campagna (F11).
enum CampaignStatus {
  /// Giocabile: contenuti presenti nei repository.
  active,

  /// Annunciata ma senza contenuti: visibile in lista, non selezionabile.
  comingSoon,
}

/// Campagna di gioco (F11, disegno utenti_campagne_hub §4).
///
/// I contenuti (roadmap/quiz/detail/boss) restano nei repository, che
/// delegano al seed Web quando `id == webFoundationsId`; qui vivono solo
/// i metadati di presentazione per la schermata di selezione.
class Campaign extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String intro;
  final CampaignStatus status;

  const Campaign({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.status,
  });

  bool get isActive => status == CampaignStatus.active;
  bool get isComingSoon => status == CampaignStatus.comingSoon;

  @override
  List<Object?> get props => [id, title, subtitle, intro, status];
}

/// Catalogo campagne (F11: progettare per N, spedirne 1).
///
/// Oggi 1 attiva (Fondamenta Web) + 2 annunciate oneste (titolo
/// segnaposto + "Prossimamente", niente contenuti). Nuova campagna =
/// nuovo seed nei repository + voce in questa lista, zero cambi a
/// meccaniche, formato save o Hub.
abstract final class CampaignRepository {
  /// Id della campagna spedita (unica con contenuti).
  static const String webFoundationsId = 'web_foundations';

  static const List<Campaign> _campaigns = [
    Campaign(
      id: webFoundationsId,
      title: 'Fondamenta Web',
      subtitle: 'Client, rete, dati: costruisci le basi del web',
      intro:
          'Tre capitoli (La Rete, Dati e Stato, Costruire sul Web), '
          'quiz da superare e boss da affrontare. Buona avventura!',
      status: CampaignStatus.active,
    ),
    Campaign(
      id: 'backend_arcana',
      title: 'Backend Arcana',
      subtitle: 'Prossimamente',
      intro: 'Questa campagna è in costruzione: i contenuti non ci sono ancora.',
      status: CampaignStatus.comingSoon,
    ),
    Campaign(
      id: 'mobile_odyssey',
      title: 'Mobile Odyssey',
      subtitle: 'Prossimamente',
      intro: 'Questa campagna è in costruzione: i contenuti non ci sono ancora.',
      status: CampaignStatus.comingSoon,
    ),
  ];

  /// Tutte le campagne in ordine di presentazione (attive prima).
  static List<Campaign> list() => List.unmodifiable(_campaigns);

  /// Solo le campagne giocabili.
  static List<Campaign> activeList() =>
      _campaigns.where((c) => c.isActive).toList();

  static Campaign? byId(String id) {
    for (final campaign in _campaigns) {
      if (campaign.id == id) return campaign;
    }
    return null;
  }

  /// True se la campagna è selezionabile (attiva e con contenuti).
  static bool isSelectable(String id) => byId(id)?.isActive ?? false;

  /// Guardia per i repository: null/default = seed Web (compat con i
  /// chiamanti pre-F11); id attivo noto = ok; qualsiasi altro id
  /// (coming soon o sconosciuto) = [StateError], mai contenuti finti.
  static String requireActive([String? campaignId]) {
    final id = campaignId ?? webFoundationsId;
    if (id == webFoundationsId) return id;
    final campaign = byId(id);
    if (campaign != null && campaign.isActive) return id;
    throw StateError('Campagna "$id" non disponibile (coming soon).');
  }
}
