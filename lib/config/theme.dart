import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App color palette — Minimal Sharp / Cyan Frost
class AppColors {
  // Backgrounds
  static const background = Color(0xFF080810);
  static const surface = Color(0xFF111118);
  static const surfaceLight = Color(0xFF18181F);

  // Primary (Cyan Frost)
  static const primary = Color(0xFF00B4D8);
  static const primaryDark = Color(0xFF0096B4);
  static const primaryLight = Color(0xFF48CAE4);

  // Secondary
  static const secondary = Color(0xFF48CAE4);

  // Semantic
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF48CAE4);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x73FFFFFF); // 45%
  static const textTertiary = Color(0x4DFFFFFF); // 30%

  // Borders & Dividers
  static const border = Color(0x0FFFFFFF); // 6%
  static const divider = Color(0x14FFFFFF); // 8%

  // Glass effects
  static const glassBackground = Color(0xB3111118); // surface at 70%
  static const glassBorder = Color(0x1AFFFFFF); // 10% white
  static const double glassBlur = 20.0;

  // Design tokens
  static const double radiusS = 8.0;
  static const double radiusM = 10.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 14.0;
  static const double radiusXXL = 20.0;

  // Score Colors
  static Color scoreColor(int score) {
    if (score < 40) return danger;
    if (score < 70) return warning;
    return success;
  }
}

/// App typography
class AppTypography {
  static const _display = 'SF Pro Display';
  static const _text = 'SF Pro Text';
  static const _mono = 'SF Mono';

  static const displayLarge = TextStyle(
    fontFamily: _display,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const headlineLarge = TextStyle(
    fontFamily: _display,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontFamily: _text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontFamily: _text,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _text,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _text,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const labelLarge = TextStyle(
    fontFamily: _text,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const labelSmall = TextStyle(
    fontFamily: _text,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  static const mono = TextStyle(
    fontFamily: _mono,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const numberLarge = TextStyle(
    fontFamily: _display,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static const scoreLarge = TextStyle(
    fontFamily: _display,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: _text,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // Keep backward compat aliases
  static const labelBrutal = labelSmall;
  static const numberBrutal = numberLarge;
  static const buttonBrutal = button;
}

/// App theme configuration
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusXL),
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusM),
        ),
        textStyle: AppTypography.button,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.button,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineLarge: AppTypography.headlineLarge,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelLarge: AppTypography.labelLarge,
      labelSmall: AppTypography.labelSmall,
    ),
  );
}
