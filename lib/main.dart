import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/roadmap_repository.dart';
import 'data/services/engine_client.dart';
import 'data/services/hub_identity.dart';
import 'data/services/shared_preferences_persistence.dart';
import 'domain/models/player_progress.dart';
import 'ui/screens/screens.dart';
import 'ui/view_models/player_view_model.dart';
import 'ui/view_models/roadmap_view_model.dart';

/// Avvio (F5, US-05): carica il save PRIMA di runApp e passa lo stato
/// iniziale ai ViewModel (progress ripristinato; roadmap con completed
/// applicati + unlock ricalcolato). Save assente/corroto → partenza fresca.
///
/// F7 (Hub, offline-first): playerId stabile `slay_<...>` da
/// SharedPreferences + [HttpEngineClient] con login fire-and-forget a ogni
/// avvio (re-login trasparente contro la scadenza 24h del token). Senza
/// credenziali `--dart-define` assenti nessuna chiamata parte e l'app
/// è identica all'offline.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistence = SharedPreferencesPersistence();
  PlayerProgress? savedProgress;
  Set<String> savedClaimed = {};
  try {
    savedProgress = await persistence.loadPlayerProgress();
    savedClaimed = await persistence.loadClaimedRewardTopics();
  } catch (_) {
    savedProgress = null;
    savedClaimed = {};
  }

  final engine = HttpEngineClient();
  unawaited(engine.login());
  String hubPlayerId = '';
  try {
    hubPlayerId = await HubIdentity.loadOrCreate(
      await SharedPreferences.getInstance(),
    );
  } catch (_) {
    hubPlayerId = '';
  }

  final playerViewModel = PlayerViewModel(
    initialProgress: savedProgress,
    claimedTopics: savedClaimed,
    persistence: persistence,
    engine: engine,
    hubPlayerId: hubPlayerId,
  );
  final roadmapViewModel = RoadmapViewModel(LocalRoadmapRepository());
  await roadmapViewModel.loadRoadmap();
  if (savedProgress != null) {
    roadmapViewModel.applyCompletedTopics(savedProgress.completedTopicIds);
  }

  runApp(MyApp(playerViewModel: playerViewModel, roadmapViewModel: roadmapViewModel));
}

class MyApp extends StatelessWidget {
  final PlayerViewModel? playerViewModel;
  final RoadmapViewModel? roadmapViewModel;

  const MyApp({super.key, this.playerViewModel, this.roadmapViewModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: roadmapViewModel ?? RoadmapViewModel(LocalRoadmapRepository()),
        ),
        ChangeNotifierProvider.value(
          value: playerViewModel ?? PlayerViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Slay the Roadmap',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
