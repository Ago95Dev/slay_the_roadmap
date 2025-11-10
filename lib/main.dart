import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/roadmap_screen.dart';
import 'ui/view_model/roadmap_view_model.dart';
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
      ],
      child: MaterialApp(
        title: 'Slay the Roadmap',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const RoadmapScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
