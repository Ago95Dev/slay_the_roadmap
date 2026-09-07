import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/roadmap_repository.dart';
import 'data/services/engine_client.dart';
import 'data/services/user_store.dart';
import 'ui/screens/screens.dart';
import 'ui/view_models/player_view_model.dart';
import 'ui/view_models/roadmap_view_model.dart';
import 'ui/view_models/session_controller.dart';

/// Avvio (F10): profili locali multipli con login/registrazione.
///
/// 1. Migrazione una-tantum del vecchio save singolo `slay_save_v1`
///    → utente "Giocatore" (poi il legacy è ignorato per sempre).
/// 2. Hub offline-first (F7): login fire-and-forget a ogni avvio.
/// 3. Se nessun profilo è attivo → schermata di scelta profilo PRIMA
///    della Home; altrimenti Home con i ViewModel dell'utente attivo.
///    Il logout da Settings torna alla scelta profilo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final users = UserStore(prefs);
  try {
    await users.migrateLegacyIfNeeded();
  } catch (_) {
    // Save legacy corrotto: si parte freschi, mai un crash all'avvio.
  }

  final engine = HttpEngineClient();
  unawaited(engine.login());

  final session = SessionController(users, engine: engine);
  try {
    await session.restore();
  } catch (_) {
    // Nessun utente attivo o save corrotto: mostra lo switch profili.
  }

  runApp(MyAppRoot(session: session));
}

/// Root con sessione (F10): osserva [SessionController] e monta lo switch
/// profili oppure la Home dell'utente attivo (i ViewModel per-utente sono
/// forniti qui; il cambio utente ricostruisce il Navigator da zero).
class MyAppRoot extends StatelessWidget {
  final SessionController session;

  const MyAppRoot({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: Builder(
        builder: (context) {
          final watched = context.watch<SessionController>();
          final active = watched.activeProfile;
          final player = watched.player;
          final roadmap = watched.roadmap;
          final Widget home;
          if (!watched.ready) {
            home = const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (active == null || player == null || roadmap == null) {
            home = ProfileSwitchScreen(session: watched);
          } else {
            home = MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: roadmap),
                ChangeNotifierProvider.value(value: player),
              ],
              child: HomeScreen(key: ValueKey(active.userId)),
            );
          }
          return MaterialApp(
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
            home: home,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
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
