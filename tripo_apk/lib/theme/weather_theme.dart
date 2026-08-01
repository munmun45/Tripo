import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WeatherThemeStyle {
  final List<Color> gradient;
  final Color accent;
  final Color chipIcon;
  final IconData icon;
  final String artAsset;

  const WeatherThemeStyle({
    required this.gradient,
    required this.accent,
    required this.chipIcon,
    required this.icon,
    required this.artAsset,
  });
}

class WeatherTheme {
  static WeatherThemeStyle of(IconKey key) {
    switch (key) {
      case IconKey.sunny:
        return const WeatherThemeStyle(
          gradient: [Color(0xFFE07A3D), Color(0xFFF0A04B), Color(0xFFF5C26B)],
          accent: Color(0xFFFFF1C1),
          chipIcon: Color(0xFFFFE8A3),
          icon: Icons.wb_sunny_rounded,
          artAsset: 'assets/weather/sunny.jpg',
        );
      case IconKey.partlyCloudy:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF0F4A5C), Color(0xFF1A7A88), Color(0xFF2A9AAB)],
          accent: Color(0xFFD0B06A),
          chipIcon: Color(0xFF5EC8D8),
          icon: Icons.wb_cloudy_rounded,
          artAsset: 'assets/weather/partly_cloudy.jpg',
        );
      case IconKey.cloudy:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF4A5D73), Color(0xFF6B7F94), Color(0xFF8FA3B5)],
          accent: Color(0xFFE8EEF2),
          chipIcon: Color(0xFFD5E0E8),
          icon: Icons.cloud_rounded,
          artAsset: 'assets/weather/cloudy.jpg',
        );
      case IconKey.rainy:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF1B3A5C), Color(0xFF2E5A8A), Color(0xFF3D7AB5)],
          accent: Color(0xFF9ED0FF),
          chipIcon: Color(0xFF8EC8F5),
          icon: Icons.umbrella_rounded,
          artAsset: 'assets/weather/rainy.jpg',
        );
      case IconKey.storm:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF2B1F4A), Color(0xFF3D2E6B), Color(0xFF5540A0)],
          accent: Color(0xFFE8D4FF),
          chipIcon: Color(0xFFC9B0F5),
          icon: Icons.thunderstorm_rounded,
          artAsset: 'assets/weather/storm.jpg',
        );
      case IconKey.fog:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF5A6670), Color(0xFF7A8790), Color(0xFF9AA6AE)],
          accent: Color(0xFFE6EBEE),
          chipIcon: Color(0xFFD0D7DC),
          icon: Icons.foggy,
          artAsset: 'assets/weather/fog.jpg',
        );
      case IconKey.snow:
        return const WeatherThemeStyle(
          gradient: [Color(0xFF3A6B8A), Color(0xFF5B8FAD), Color(0xFF8BB8D0)],
          accent: Color(0xFFF2FAFF),
          chipIcon: Color(0xFFD8EEF8),
          icon: Icons.ac_unit_rounded,
          artAsset: 'assets/weather/snow.jpg',
        );
    }
  }

  static String aqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy*';
    if (aqi <= 200) return 'Unhealthy';
    return 'Hazardous';
  }

  static Color aqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFFFFC107);
    if (aqi <= 150) return const Color(0xFFFF9800);
    if (aqi <= 200) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }
}

IconData weatherIcon(IconKey key) => WeatherTheme.of(key).icon;
