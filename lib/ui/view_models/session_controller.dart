import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/roadmap_repository.dart';
import '../../data/services/engine_client.dart';
import '../../data/services/hub_identity.dart';
import '../../data/services/user_store.dart';
import '../../domain/models/campaign.dart';
import '../../domain/models/player_progress.dart';
import '../../domain/models/user_profile.dart';
import 'player_view_model.dart';
import 'roadmap_view_model.dart';

/// Sessione utente (F10, F11): tiene il profilo attivo + i ViewModel caricati
/// per quell'utente e per la campagna attiva (save isolato per coppia
/// utente×campagna). Logout = smonta i ViewModel e torna alla schermata
/// di scelta profilo.
class SessionController with ChangeNotifier {
  final UserStore users;
  final EngineClient? engine;

  UserProfile? activeProfile;
  PlayerViewModel? player;
  RoadmapViewModel? roadmap;
  bool ready = false;

  /// Campagna attiva (id, default spedita) + flag di selezione esplicita
  /// (persistito): finché false la root mostra la selezione campagne
  /// prima della Home.
  String activeCampaignId = CampaignRepository.webFoundationsId;
  bool campaignSelected = false;

  SessionController(this.users, {this.engine});

  /// Null quando nessun [SessionController] è fornito sopra nel tree
  /// (test che montano Home/Settings direttamente): in quel caso le voci
  /// di logout restano nascoste e il comportamento legacy è invariato.
  static SessionController? maybeOf(BuildContext context) {
    try {
      return Provider.of<SessionController>(context, listen: false);
    } on Exception {
      return null;
    }
  }

  /// playerId Hub della coppia (utente, campagna)
  /// (disegno utenti_campagne_hub §2: `slay_<userId>_<campaignId>`).
  static String hubPlayerIdFor(String userId, [String? campaignId]) =>
      HubIdentity.playerIdFor(userId, campaignId);

  bool get isLoggedIn => activeProfile != null;

  /// True quando l'utente ha già scelto la campagna (niente selezione).
  bool get hasSelectedCampaign => isLoggedIn && campaignSelected;

  /// Campagna attiva (sempre nota, default spedita).
  Campaign? get activeCampaign =>
      CampaignRepository.byId(activeCampaignId);

  /// Tutte le campagne per la schermata di selezione.
  List<Campaign> get availableCampaigns => CampaignRepository.list();

  /// Ripristina l'utente attivo (se presente) al bootstrap in `main`.
  Future<void> restore() async {
    final active = users.activeUser();
    if (active != null) {
      await _openSession(active);
    }
    ready = true;
    notifyListeners();
  }

  Future<UserProfile> register({
    required String username,
    required String password,
  }) async {
    final profile =
        await users.register(username: username, password: password);
    await _openSession(profile);
    notifyListeners();
    return profile;
  }

  /// Null se credenziali errate (nessun cambio di sessione).
  Future<UserProfile?> login({
    required String username,
    required String password,
  }) async {
    final profile = await users.login(username: username, password: password);
    if (profile == null) return null;
    await _openSession(profile);
    notifyListeners();
    return profile;
  }

  /// Sceglie la campagna [campaignId] e carica il suo progress isolato.
  /// Lancia [StateError] se la campagna è coming soon (non selezionabile):
  /// in quel caso la sessione resta sulla campagna corrente.
  Future<void> selectCampaign(String campaignId) async {
    final profile = activeProfile;
    if (profile == null) {
      throw StateError('Nessun utente attivo: accedi prima.');
    }
    if (!CampaignRepository.isSelectable(campaignId)) {
      throw StateError('Campagna "$campaignId" non disponibile (coming soon).');
    }
    final persistence = users.dataFor(profile.userId);
    await persistence.saveActiveCampaignId(campaignId);
    await persistence.saveCampaignSelected(true);
    await _openCampaign(profile, campaignId, selected: true);
    notifyListeners();
  }

  /// Torna alla selezione campagne (la Home resta dietro, i progress
  /// salvati sono intatti). Usato da "Cambia campagna" in Home.
  Future<void> backToCampaignSelection() async {
    final profile = activeProfile;
    if (profile == null) return;
    await users.dataFor(profile.userId).saveCampaignSelected(false);
    campaignSelected = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await users.logout();
    activeProfile = null;
    player = null;
    roadmap = null;
    activeCampaignId = CampaignRepository.webFoundationsId;
    campaignSelected = false;
    notifyListeners();
  }

  Future<void> _openSession(UserProfile profile) async {
    final persistence = users.dataFor(profile.userId);
    String? savedCampaign;
    bool selected = false;
    try {
      savedCampaign = await persistence.loadActiveCampaignId();
      selected = await persistence.loadCampaignSelected();
    } on Exception {
      savedCampaign = null;
      selected = false;
    }
    await _openCampaign(
      profile,
      savedCampaign ?? CampaignRepository.webFoundationsId,
      selected: selected,
    );
  }

  Future<void> _openCampaign(
    UserProfile profile,
    String campaignId, {
    required bool selected,
  }) async {
    final persistence = users.dataFor(profile.userId, campaignId: campaignId);
    PlayerProgress? saved;
    Set<String> claimed = {};
    try {
      saved = await persistence.loadPlayerProgress();
      claimed = await persistence.loadClaimedRewardTopics();
    } on Exception {
      saved = null;
      claimed = {};
    }
    saved ??=
        PlayerProgress.initial().copyWith(playerName: profile.displayName);
    final playerVm = PlayerViewModel(
      initialProgress: saved,
      claimedTopics: claimed,
      persistence: persistence,
      engine: engine,
      hubPlayerId: hubPlayerIdFor(profile.userId, campaignId),
    );
    // F12: ogni apertura utente×campagna conta come sessione (Evaluation).
    playerVm.recordSessionStart();
    final roadmapVm = RoadmapViewModel(
      LocalRoadmapRepository(),
      campaignId: campaignId,
      // Campagna US-04: il gate `requiredBossId` legge le vittorie reali.
      isBossDefeated: playerVm.isBossDefeated,
    );
    await roadmapVm.loadRoadmap();
    roadmapVm.applyCompletedTopics(saved.completedTopicIds);
    activeProfile = profile;
    activeCampaignId = campaignId;
    campaignSelected = selected;
    player = playerVm;
    roadmap = roadmapVm;
  }
}
