import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/roadmap_repository.dart';
import '../../data/services/engine_client.dart';
import '../../data/services/user_store.dart';
import '../../domain/models/player_progress.dart';
import '../../domain/models/user_profile.dart';
import 'player_view_model.dart';
import 'roadmap_view_model.dart';

/// Sessione utente (F10): tiene il profilo attivo + i ViewModel caricati
/// per quell'utente (save isolato `slay_data_<id>`). Logout = smonta i
/// ViewModel e torna alla schermata di scelta profilo.
class SessionController with ChangeNotifier {
  final UserStore users;
  final EngineClient? engine;

  UserProfile? activeProfile;
  PlayerViewModel? player;
  RoadmapViewModel? roadmap;
  bool ready = false;

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

  /// playerId Hub del profilo (disegno utenti_campagne_hub §2: un player
  /// per coppia utente×campagna; campagna unica oggi → solo userId, la
  /// F11 aggiungerà il suffisso campagna senza cambiare meccaniche).
  static String hubPlayerIdFor(String userId) => 'slay_$userId';

  bool get isLoggedIn => activeProfile != null;

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

  Future<void> logout() async {
    await users.logout();
    activeProfile = null;
    player = null;
    roadmap = null;
    notifyListeners();
  }

  Future<void> _openSession(UserProfile profile) async {
    final persistence = users.dataFor(profile.userId);
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
      hubPlayerId: hubPlayerIdFor(profile.userId),
    );
    final roadmapVm = RoadmapViewModel(
      LocalRoadmapRepository(),
      // Campagna US-04: il gate `requiredBossId` legge le vittorie reali.
      isBossDefeated: playerVm.isBossDefeated,
    );
    await roadmapVm.loadRoadmap();
    roadmapVm.applyCompletedTopics(saved.completedTopicIds);
    activeProfile = profile;
    player = playerVm;
    roadmap = roadmapVm;
  }
}
