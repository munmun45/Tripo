import 'package:flutter/material.dart';

class AdminTheme {
  static const ocean = Color(0xFF0A6BB8);
  static const teal = Color(0xFF12A89A);
  static const coral = Color(0xFFFF7A59);
  static const amber = Color(0xFFF0B429);
  static const rose = Color(0xFFE85D75);
  static const ink = Color(0xFF0A1628);
  static const slate = Color(0xFF4A5D78);
  static const soft = Color(0xFFDCE8F5);
  static const mist = Color(0xB8FFFFFF);
  static const glassFill = Color(0x66FFFFFF);
  static const glassStroke = Color(0x99FFFFFF);
  static const glassDark = Color(0x140A1628);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ocean,
        primary: ocean,
        secondary: teal,
        surface: Colors.white.withValues(alpha: 0.55),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: glassStroke,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        hintStyle: TextStyle(color: slate.withValues(alpha: 0.85)),
        labelStyle: const TextStyle(color: slate),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ocean, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.35),
        selectedColor: ocean.withValues(alpha: 0.18),
        side: const BorderSide(color: glassStroke),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.55),
        indicatorColor: ocean.withValues(alpha: 0.16),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? ocean : slate,
          );
        }),
      ),
    );
  }
}
