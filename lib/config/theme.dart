import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const background = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFAFAF9),
    darkColor: Color(0xFF0A0A0A),
  );
  static const surface = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF141414),
  );

  // Borders & Dividers
  static const divider = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE8E8E6),
    darkColor: Color(0xFF1F1F1F),
  );
  static const border = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5E3),
    darkColor: Color(0xFF2A2A2A),
  );

  // Text
  static const textPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const textSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF999999),
    darkColor: Color(0xFF666666),
  );
  static const textTertiary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF999999),
    darkColor: Color(0xFF555555),
  );

  // Accent (near-black / near-white)
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );

  // Semantic score colors
  static const scoreGood = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF166534),
    darkColor: Color(0xFF4ADE80),
  );
  static const scoreMid = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF92400E),
    darkColor: Color(0xFFFB923C),
  );
  static const scoreBad = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF991B1B),
    darkColor: Color(0xFFF87171),
  );

  // Score badge backgrounds
  static const scoreGoodBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0FAF0),
    darkColor: Color(0xFF0F2A1A),
  );
  static const scoreMidBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFEF6ED),
    darkColor: Color(0xFF2A1A0A),
  );
  static const scoreBadBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFEF2F2),
    darkColor: Color(0xFF2A0F0F),
  );

  // Chips
  static const chipActive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const chipActiveFg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFAFAF9),
    darkColor: Color(0xFF0A0A0A),
  );
  static const chipInactive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF5F5F3),
    darkColor: Color(0xFF1A1A1A),
  );

  // Chart
  static const chartActive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const chartInactive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5E3),
    darkColor: Color(0xFF1A1A1A),
  );

  // Search field bg
  static const searchField = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0F0EE),
    darkColor: Color(0xFF141414),
  );

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 10.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 20.0;

  // Score color helper — thresholds: good >= 70, mid >= 40, bad < 40
  static CupertinoDynamicColor scoreColor(int score) {
    if (score >= 70) return scoreGood;
    if (score >= 40) return scoreMid;
    return scoreBad;
  }

  static CupertinoDynamicColor scoreBgColor(int score) {
    if (score >= 70) return scoreGoodBg;
    if (score >= 40) return scoreMidBg;
    return scoreBadBg;
  }
}

class AppTypography {
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
  );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
  );

  static TextStyle numberLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle scoreLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle chip(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
  );

  static TextStyle mono(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Menlo',
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );
}

class AppTheme {
  static CupertinoThemeData get theme => const CupertinoThemeData(
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.background,
  );
}

class AppConstants {
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 200);
  static const Duration countUpAnimation = Duration(milliseconds: 600);
  static const double entranceSlideDistance = 8.0;
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const double pageHorizontal = 24.0;
  static const double sectionGap = 28.0;
  static const double itemGap = 14.0;
  static const double contentGap = 4.0;
  static const double chipGap = 8.0;
  static const double statGap = 16.0;
  static const double navIconSize = 22.0;
  static const double navPillH = 16.0;
  static const double navPillV = 6.0;
  static const double scrollBottomPadding = 100.0;
}
