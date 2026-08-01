import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/dummy_packages.dart';
import '../../models/travel_package.dart';
import '../../models/weather_data.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/package_card.dart';
import '../../widgets/pull_refresh.dart';
import '../../widgets/recommended_cities_row.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeletons/skeleton.dart';
import '../../widgets/weather_home_card.dart';
import '../packages/package_detail_screen.dart';
import '../weather/weather_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? _weather;
  bool _loadingWeather = true;
  String? _weatherError;
  String? _selectedCategory;

  static const _cats = [
    ('Beach', Icons.beach_access_rounded),
    ('Mountain', Icons.terrain_rounded),
    ('Luxury', Icons.diamond_outlined),
    ('Culture', Icons.museum_outlined),
    ('Adventure', Icons.hiking_rounded),
    ('Romantic', Icons.favorite_outline_rounded),
    ('Wellness', Icons.self_improvement_rounded),
  ];

  List<TravelPackage> get _featuredPackages {
    final all = DummyPackages.all;
    if (_selectedCategory == null) return all.take(8).toList();
    final filtered =
        all.where((p) => p.category == _selectedCategory).toList();
    return filtered.isEmpty ? all.take(8).toList() : filtered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLiveWeather();
    });
  }

  Future<void> _loadLiveWeather({bool showSkeleton = true}) async {
    if (!mounted) return;
    if (showSkeleton) {
      setState(() {
        _loadingWeather = true;
        _weatherError = null;
      });
    }
    try {
      Position? pos;
      try {
        pos = await LocationService.currentPosition(
          timeout: const Duration(seconds: 3),
        );
      } catch (_) {
        pos = null;
      }

      final WeatherData data = await (pos != null
              ? WeatherService.byCoordinates(
                  lat: pos.latitude,
                  lng: pos.longitude,
                  isCurrentLocation: true,
                )
              : WeatherService.forMumbaiLive())
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      setState(() {
        _weather = data;
        _loadingWeather = false;
        _weatherError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingWeather = false;
        if (_weather == null) {
          _weatherError = 'Live weather failed. Tap to retry.';
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _selectedCategory = null);
    await _loadLiveWeather(showSkeleton: false);
  }

  Future<void> _openWeather() async {
    if (_weather == null) {
      await _loadLiveWeather();
      return;
    }
    final result = await Navigator.of(context).push<WeatherData>(
      MaterialPageRoute(
        builder: (_) => WeatherDetailScreen(initial: _weather!),
      ),
    );
    if (result != null && mounted) {
      setState(() => _weather = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = _featuredPackages;

    return PullRefresh(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _loadingWeather
                    ? const WeatherCardSkeleton()
                    : _weather == null
                        ? GestureDetector(
                            onTap: () => _loadLiveWeather(),
                            child: Container(
                              height: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.softSky,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.coral),
                              ),
                              child: Text(
                                _weatherError ?? 'Tap to load live weather',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.coral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : WeatherHomeCard(
                            weather: _weather!,
                            onTap: _openWeather,
                          ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(
              child: RecommendedCitiesRow(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Featured packages'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cats.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final isAll = i == 0;
                    final label = isAll ? 'All' : _cats[i - 1].$1;
                    final icon =
                        isAll ? Icons.apps_rounded : _cats[i - 1].$2;
                    final selected = isAll
                        ? _selectedCategory == null
                        : _selectedCategory == label;
                    const chipRadius = 22.0;
                    return Material(
                      color: selected
                          ? AppColors.ocean
                          : Colors.white.withValues(alpha: 0.92),
                      elevation: selected ? 3 : 1,
                      shadowColor: AppColors.ocean.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(chipRadius),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = isAll ? null : label;
                          });
                        },
                        borderRadius: BorderRadius.circular(chipRadius),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : AppColors.ocean,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = packages[i];
                    return PackageCard(
                      package: p,
                      compact: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PackageDetailScreen(package: p),
                          ),
                        );
                      },
                    );
                  },
                  childCount: packages.length,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
