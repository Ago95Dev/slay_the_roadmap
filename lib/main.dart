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
/// 3. Bootstrap NON ripristina mai la sessione (BUG 1): l'eventuale
///    utente attivo persistito viene sloggato, l'avvio mostra sempre
///    la scelta profilo e il profilo si carica SOLO dopo login o
///    registrazione espliciti.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final users = UserStore(prefs);
  try {
    await users.migrateLegacyIfNeeded();
  } catch (_) {
    // Save legacy corrotto: si parte freschi, mai un crash all'avvio.
  }
  try {
    // Mai auto-login al riavvio (BUG 1): solo login esplicito.
    await users.logout();
  } catch (_) {
    // Logout best-effort: un fallimento qui non blocca mai l'avvio.
  }

  final engine = HttpEngineClient();
  unawaited(engine.login());

  final session = SessionController(users, engine: engine);
  try {
    await session.restore();
  } catch (_) {
    // restore() non apre sessioni: segna solo la root come pronta.
  }

  runApp(MyAppRoot(session: session));
}

/// Root con sessione (F10, F11): osserva [SessionController] e monta lo
/// switch profili, poi l'Hub personale (dopo il login, centro di tutto),
/// da cui si raggiungono selezione campagna e Home di gioco.
///
/// I ViewModel per-utente e per-campagna sono forniti SOPRA il MaterialApp:
/// il Navigator crea le route come sorelle dell'`home:` (non discendenti),
/// quindi ogni provider montato come `home:` NON sarebbe ereditato dai
/// push (ProviderNotFound su Classifica/Settings/Roadmap/Quiz sul device
/// reale). Con lo scope qui sopra, TUTTE le route ereditano ViewModel e
/// SessionController senza inoltri per-push.
///
/// Il cambio utente o campagna ricostruisce tutto da zero via [ValueKey]
/// (niente stati mescolati); il logout smonta i ViewModel e azzera lo
/// stack tornando alla scelta profilo.
class MyAppRoot extends StatelessWidget {
  final SessionController session;

  const MyAppRoot({super.key, required this.session});

  ThemeData _lightTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  ThemeData _darkTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

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
          if (!watched.ready) {
            return MaterialApp(
              title: 'Slay the Roadmap',
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              debugShowCheckedModeBanner: false,
            );
          }
          if (active == null || player == null || roadmap == null) {
            // Nessuna sessione: niente ViewModel da fornire, solo la
            // scelta profilo (il logout atterra qui con stack azzerato).
            return MaterialApp(
              title: 'Slay the Roadmap',
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              home: ProfileSwitchScreen(session: watched),
              debugShowCheckedModeBanner: false,
            );
          }
          // Hub personale: la selezione campagna non è più forzata, è
          // raggiungibile da qui; la prima campagna mai scelta mostra
          // l'invito (CONTINUA nascosto).
          final scopeKey =
              'hub_${active.userId}_${watched.activeCampaignId}';
          return MultiProvider(
            key: ValueKey('vms_$scopeKey'),
            providers: [
              ChangeNotifierProvider.value(value: roadmap),
              ChangeNotifierProvider.value(value: player),
            ],
            child: MaterialApp(
              key: ValueKey('app_$scopeKey'),
              title: 'Slay the Roadmap',
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              home: HubScreen(key: ValueKey(scopeKey)),
              debugShowCheckedModeBanner: false,
            ),
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
