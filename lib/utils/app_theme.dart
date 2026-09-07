import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color dartBlue = Color(0xFF0175C2);
  static const Color commonGray = Color(0xFF9E9E9E);
  static const Color rareBlue = Color(0xFF2196F3);
  static const Color epicPurple = Color(0xFF9C27B0);
  static const Color legendaryGold = Color(0xFFFFD700);

  // Rarity Colors
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return commonGray;
      case 'rare':
        return rareBlue;
      case 'epic':
        return epicPurple;
      case 'legendary':
        return legendaryGold;
      default:
        return commonGray;
    }
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dartBlue,
        brightness: Brightness.light,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearMinHeight: 6,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dartBlue,
        brightness: Brightness.dark,
      ),
      
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearMinHeight: 6,
      ),
    );
  }

  // Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
  );

  // Card Rarity Gradients
  static LinearGradient getCardGradient(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'epic':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rare':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
