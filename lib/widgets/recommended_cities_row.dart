import 'package:flutter/material.dart';
import '../data/destination_cities.dart';
import '../theme/app_theme.dart';
import 'section_header.dart';
import '../screens/cities/all_cities_screen.dart';

/// Recommended destination cities — not linked to weather.
class RecommendedCitiesRow extends StatelessWidget {
  const RecommendedCitiesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cities = DestinationCities.featuredCities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recommended cities'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < cities.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _CityCard(
                    city: cities[i].name,
                    imageUrl: cities[i].imageUrl,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${cities[i].name} · ${cities[i].tagline}',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Expanded(
                child: _MoreCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AllCitiesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final String city;
  final String imageUrl;
  final VoidCallback onTap;

  const _CityCard({
    required this.city,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.softSky,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: AppColors.teal,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.softSky,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.ocean,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'More',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ocean,
            ),
          ),
        ],
      ),
    );
  }
}
