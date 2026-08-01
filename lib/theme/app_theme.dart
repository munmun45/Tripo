import 'package:flutter/material.dart';

class AppColors {
  /// White-first surfaces with blue accents only
  static const white = Color(0xFFFFFFFF);
  static const softBg = Color(0xFFF5F9FF);
  static const softSky = Color(0xFFE8F1FF);
  static const softMint = Color(0xFFEAF4FF); // soft blue (legacy name)
  static const softBlue = Color(0xFFD6E8FF);
  static const softLavender = Color(0xFFE9F0FF);
  static const ice = Color(0xFFF0F6FF);
  static const glassTint = Color(0xFFF2F7FF);

  static const navy = Color(0xFF0A1F45);
  static const ocean = Color(0xFF1A4F9C); // primary blue
  static const teal = Color(0xFF2B6BCF); // mid blue (legacy name)
  static const aqua = Color(0xFF5B9EFF); // light blue
  static const mist = Color(0xFFE6F0FF);
  static const sand = Color(0xFFF5F9FF);
  static const ink = Color(0xFF14233D);
  static const slate = Color(0xFF5E7194);
  static const coral = Color(0xFF4A7FD4); // blue accent (legacy name)
  static const gold = Color(0xFF7AA8F0); // soft blue highlight
  static const card = Color(0xFFFFFFFF);
  static const nightStart = Color(0xFF0D2A5C);
  static const nightEnd = Color(0xFF1E5BB8);
  static const navInactive = Color(0xFF8A9BB8);
  static const border = Color(0xFFD9E6F7);
}

/// System fonts only — no runtime Google Fonts download (ANR-safe on slow nets).
/// Android uses Roboto / Noto (Hindi Devanagari works). iOS uses SF.
class AppTheme {
  static const _fallback = <String>[
    'Roboto',
    'Noto Sans',
    'Noto Sans Devanagari',
    'sans-serif',
  ];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        primary: AppColors.ocean,
        secondary: AppColors.aqua,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.ink,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F9FF),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.82),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );

    TextStyle display(double size, FontWeight weight) => TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: AppColors.ink,
          height: 1.2,
          fontFamilyFallback: _fallback,
          // Serif when available; otherwise system sans.
          fontFamily: 'serif',
        );

    TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
        TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? AppColors.ink,
          height: 1.35,
          fontFamily: 'Roboto',
          fontFamilyFallback: _fallback,
        );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: display(34, FontWeight.w700),
        displayMedium: display(26, FontWeight.w700),
        headlineMedium: display(20, FontWeight.w600),
        titleLarge: body(18, weight: FontWeight.w700),
        bodyLarge: body(16),
        bodyMedium: body(14, color: AppColors.slate),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: display(22, FontWeight.w700),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ocean,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: body(15, weight: FontWeight.w700, color: AppColors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ice,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.aqua, width: 1.5),
        ),
      ),
    );
  }
}
