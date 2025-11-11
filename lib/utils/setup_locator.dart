import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/roadmap_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/reward_repository.dart';
import '../data/repositories/persistence_repository.dart';
import '../data/services/shared_preferences_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  getIt.registerSingleton<PersistenceRepository>(
    SharedPreferencesService(sharedPreferences),
  );

  // Repositories
  getIt.registerSingleton<RoadmapRepository>(LocalRoadmapRepository());
  getIt.registerSingleton<QuizRepository>(LocalQuizRepository());
  getIt.registerSingleton<RewardRepository>(LocalRewardRepository());
}
