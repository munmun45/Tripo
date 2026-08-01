import 'package:flutter/material.dart';

class AdminTheme {
  static const ocean = Color(0xFF0A4D8C);
  static const ink = Color(0xFF0A1F45);
  static const slate = Color(0xFF5A6B85);
  static const soft = Color(0xFFF3F7FC);
  static const border = Color(0xFFD7E2F0);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ocean,
        primary: ocean,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: soft,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }
}
