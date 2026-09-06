import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/roadmap_repository.dart';
import 'data/services/shared_preferences_persistence.dart';
import 'domain/models/player_progress.dart';
import 'ui/screens/screens.dart';
import 'ui/view_models/player_view_model.dart';
import 'ui/view_models/roadmap_view_model.dart';

/// Avvio (F5, US-05): carica il save PRIMA di runApp e passa lo stato
/// iniziale ai ViewModel (progress ripristinato; roadmap con completed
/// applicati + unlock ricalcolato). Save assente/corroto → partenza fresca.
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

  final playerViewModel = PlayerViewModel(
    initialProgress: savedProgress,
    claimedTopics: savedClaimed,
    persistence: persistence,
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
