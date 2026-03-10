import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App color palette (Dark Premium — Neo-Brutalist / Sunset Gold)
class AppColors {
  // Backgrounds
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF141420);
  static const surfaceLight = Color(0xFF1C1C2E);

  // Primary (Sunset Gold)
  static const primary = Color(0xFFFF9F43);
  static const primaryDark = Color(0xFFE68A30);
  static const primaryLight = Color(0xFFFFBB70);

  // Secondary
  static const secondary = Color(0xFF5DADE2);

  // Semantic
  static const success = Color(0xFF00D68F);
  static const warning = Color(0xFFFDCB6E);
  static const danger = Color(0xFFFF6B6B);
  static const info = Color(0xFF5DADE2);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x80FFFFFF); // rgba(255,255,255,0.5)
  static const textTertiary = Color(0x59FFFFFF); // rgba(255,255,255,0.35)

  // Borders & Dividers
  static const border = Color(0x0FFFFFFF);
  static const divider = Color(0x14FFFFFF);

  // Glassmorphism
  static const glass = Color(0x1AFFFFFF);

  // Brutal design tokens
  static const double brutalBorderWidth = 2.0;
  static const Offset brutalShadowOffset = Offset(3, 3);
  static const Offset brutalShadowOffsetPressed = Offset(1, 1);
  static const double brutalRadius = 12.0;
  static const double brutalButtonRadius = 10.0;
  static const double brutalNavRadius = 16.0;

  // Score Colors
  static Color scoreColor(int score) {
    if (score < 40) return danger;
    if (score < 70) return warning;
    return success;
  }
}

/// App typography
class AppTypography {
  static const displayLarge = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const headlineLarge = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const labelLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const mono = TextStyle(
    fontFamily: 'SF Mono',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Neo-brutalist typography
  static const labelBrutal = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  static const numberBrutal = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const scoreLarge = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 56,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  );

  static const buttonBrutal = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.background,
  );
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
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.brutalRadius),
        side: const BorderSide(
          color: AppColors.border,
          width: AppColors.brutalBorderWidth,
        ),
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
          borderRadius: BorderRadius.circular(AppColors.brutalButtonRadius),
        ),
        textStyle: AppTypography.buttonBrutal,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Text',
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.brutalRadius),
        borderSide: const BorderSide(color: AppColors.border, width: AppColors.brutalBorderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.brutalRadius),
        borderSide: const BorderSide(color: AppColors.border, width: AppColors.brutalBorderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.brutalRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: AppColors.brutalBorderWidth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.brutalRadius),
        borderSide: const BorderSide(color: AppColors.danger, width: AppColors.brutalBorderWidth),
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
      unselectedItemColor: AppColors.textSecondary,
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
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelLarge: AppTypography.labelLarge,
    ),
  );
}
