import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_radii.dart';

/// Soft light neumorphism helpers for white / light surfaces.
class Neo {
  static const base = AppColors.softBg;

  static List<BoxShadow> raised({double radius = 10}) => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.95),
          offset: const Offset(-3, -3),
          blurRadius: radius,
        ),
        BoxShadow(
          color: const Color(0xFFB8CDD8).withValues(alpha: 0.45),
          offset: const Offset(4, 4),
          blurRadius: radius,
        ),
      ];

  static List<BoxShadow> softCard({double radius = 12}) => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.9),
          offset: const Offset(-3, -3),
          blurRadius: radius,
        ),
        BoxShadow(
          color: const Color(0xFFAFC4D0).withValues(alpha: 0.35),
          offset: const Offset(4, 4),
          blurRadius: radius,
        ),
      ];

  static BoxDecoration surface({
    double borderRadius = AppRadii.md,
    Color color = AppColors.softBg,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: softCard(),
    );
  }

  static BoxDecoration iconButton({
    double borderRadius = AppRadii.sm,
    Color color = AppColors.softBg,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: raised(radius: 8),
    );
  }
}
