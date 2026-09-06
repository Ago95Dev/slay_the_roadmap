import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/screens.dart';
import 'ui/view_models/player_view_model.dart';
import 'ui/view_models/roadmap_view_model.dart';
import 'data/repositories/roadmap_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RoadmapViewModel(LocalRoadmapRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => PlayerViewModel(),
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
