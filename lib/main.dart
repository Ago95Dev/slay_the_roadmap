import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/main_menu_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const DartQuestApp());
}

class DartQuestApp extends StatelessWidget {
  const DartQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Slay the Roadmap',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MainMenuScreen(),
      ),
    );
  }
}
