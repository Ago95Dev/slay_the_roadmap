import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/roadmap_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/persistence_repository.dart';
import '../data/services/shared_preferences_service.dart';
import '../ui/view_model/roadmap_view_model.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Repository
  getIt.registerLazySingleton<RoadmapRepository>(
    () => LocalRoadmapRepository(),
  );
  getIt.registerLazySingleton<QuizRepository>(
    () => LocalQuizRepository(),
  );

  // ViewModels
  getIt.registerFactory(
    () => RoadmapViewModel(getIt<RoadmapRepository>()),
  );

  // Servizi con inizializzazione async (verranno inizializzati quando necessari)
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  
  getIt.registerSingletonAsync<PersistenceRepository>(
    () async {
      final prefs = await getIt.getAsync<SharedPreferences>();
      return SharedPreferencesService(prefs);
    },
    dependsOn: [SharedPreferences],
  );
}
