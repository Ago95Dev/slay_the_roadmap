import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/main_menu_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DartQuestApp());
}

class DartQuestApp extends StatelessWidget {
  const DartQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: _Bootstrap(
        child: MaterialApp(
          title: 'Slay the Roadmap',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const MainMenuScreen(),
        ),
      ),
    );
  }
}

/// Fa partire il load async del save DOPO il primo frame, mai durante il build
/// (il ctor di GameProvider resta solo sincrono).
class _Bootstrap extends StatefulWidget {
  final Widget child;

  const _Bootstrap({required this.child});

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GameProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
