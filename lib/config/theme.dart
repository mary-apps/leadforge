import 'package:flutter/cupertino.dart';

/// App color palette — Cupertino dynamic colors (auto light/dark)
class AppColors {
  static const background = CupertinoColors.systemGroupedBackground;
  static const surface = CupertinoColors.secondarySystemGroupedBackground;
  static const surfaceLight = CupertinoColors.tertiarySystemGroupedBackground;
  static const primary = CupertinoColors.systemBlue;
  static const success = CupertinoColors.systemGreen;
  static const warning = CupertinoColors.systemOrange;
  static const danger = CupertinoColors.systemRed;
  static const info = CupertinoColors.systemIndigo;
  static const textPrimary = CupertinoColors.label;
  static const textSecondary = CupertinoColors.secondaryLabel;
  static const textTertiary = CupertinoColors.tertiaryLabel;
  static const border = CupertinoColors.separator;
  static const divider = CupertinoColors.opaqueSeparator;

  // Border radius tokens
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
}

/// App typography — uses system font (SF Pro on iOS)
class AppTypography {
  static const displayLarge = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 0.37);
  static const headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0.36);
  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.35);
  static const titleMedium = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.41);
  static const bodyLarge = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: -0.41, height: 1.3);
  static const bodyMedium = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.24);
  static const labelLarge = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.08);
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.07);
  static const numberLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.36);
  static const scoreLarge = TextStyle(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: 0.37);
  static const button = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.41);
}

/// App theme configuration
class AppTheme {
  static CupertinoThemeData get theme => const CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.systemBlue,
      textStyle: AppTypography.bodyMedium,
      navTitleTextStyle: AppTypography.titleMedium,
      navLargeTitleTextStyle: AppTypography.displayLarge,
      tabLabelTextStyle: AppTypography.labelSmall,
    ),
  );
}
