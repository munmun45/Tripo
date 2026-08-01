import 'package:flutter/material.dart';
import '../../models/weather_data.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_theme.dart';
import '../../theme/weather_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/pull_refresh.dart';
import '../../widgets/skeletons/skeleton.dart';
import '../search_screen.dart';
import 'city_picker_screen.dart';

class WeatherDetailScreen extends StatefulWidget {
  final WeatherData initial;

  const WeatherDetailScreen({super.key, required this.initial});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late WeatherData _weather;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _weather = widget.initial;
  }

  void _pop() => Navigator.of(context).pop(_weather);

  Future<void> _refresh() async {
    if (_weather.isCurrentLocation) {
      await _useCurrentLocation();
      return;
    }
    await _loadCity(
      CityOption(
        name: _weather.city,
        country: _weather.country,
        lat: 0,
        lng: 0,
      ),
      byName: true,
    );
  }

  Future<void> _loadCity(
    CityOption city, {
    bool isCurrent = false,
    bool byName = false,
  }) async {
    setState(() => _loading = true);
    try {
      final WeatherData data;
      if (byName || (city.lat == 0 && city.lng == 0)) {
        final found = await WeatherService.searchCities(city.name);
        if (found.isEmpty) throw Exception('City not found');
        final match = found.firstWhere(
          (c) => c.name.toLowerCase() == city.name.toLowerCase(),
          orElse: () => found.first,
        );
        data = await WeatherService.byCoordinates(
          lat: match.lat,
          lng: match.lng,
          city: match.name,
          country: match.country,
          isCurrentLocation: isCurrent,
        );
      } else {
        data = await WeatherService.byCoordinates(
          lat: city.lat,
          lng: city.lng,
          city: city.name,
          country: city.country,
          isCurrentLocation: isCurrent,
        );
      }
      if (mounted) setState(() => _weather = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Live weather error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickCity() async {
    final city = await Navigator.of(context).push<CityOption>(
      MaterialPageRoute(builder: (_) => const CityPickerScreen()),
    );
    if (city != null) await _loadCity(city);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loading = true);
    try {
      final pos = await LocationService.currentPosition()
          .timeout(const Duration(seconds: 6));
      final data = pos == null
          ? await WeatherService.forMumbaiLive()
          : await WeatherService.byCoordinates(
              lat: pos.latitude,
              lng: pos.longitude,
              isCurrentLocation: true,
            );
      if (mounted) setState(() => _weather = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location unavailable: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = WeatherTheme.of(_weather.icon);
    final aqiLabel = WeatherTheme.aqiLabel(_weather.aqi);
    final aqiColor = WeatherTheme.aqiColor(_weather.aqi);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: PageScaffold(
        title: 'Weather',
        subtitle: _weather.isCurrentLocation
            ? 'Live · current location'
            : 'Live · ${_weather.city}',
        onBack: _pop,
        onSearchTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        onNotificationTap: _pickCity,
        body: _loading
            ? const WeatherDetailSkeleton()
            : PullRefresh(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.mdAll,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: theme.gradient,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _weather.isCurrentLocation
                                  ? Icons.my_location_rounded
                                  : Icons.place_rounded,
                              color: theme.chipIcon,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_weather.city}, ${_weather.country}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _miniAction(
                              Icons.refresh_rounded,
                              _loading ? null : _refresh,
                            ),
                            const SizedBox(width: 6),
                            _miniAction(
                              Icons.my_location_rounded,
                              _loading ? null : _useCurrentLocation,
                            ),
                            const SizedBox(width: 6),
                            _miniAction(
                              Icons.location_city_rounded,
                              _loading ? null : _pickCity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '${_weather.temperature.round()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w200,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _weather.condition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _weather.description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(theme.icon, color: theme.accent, size: 44),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _stat('Feels', '${_weather.feelsLike.round()}°'),
                            const SizedBox(width: 6),
                            _stat('Hum', '${_weather.humidity}%'),
                            const SizedBox(width: 6),
                            _stat('Wind', '${_weather.windKph.round()}'),
                            const SizedBox(width: 6),
                            _stat('AQI', '${_weather.aqi}', dot: aqiColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Air quality · $aqiLabel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label('Hourly'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 108,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weather.hourly.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final h = _weather.hourly[i];
                        final active = i == 0;
                        return Container(
                          width: 66,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? AppColors.ocean : AppColors.white,
                            borderRadius: AppRadii.smAll,
                            border: Border.all(
                              color: active
                                  ? AppColors.ocean
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                h.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: active
                                      ? Colors.white70
                                      : AppColors.slate,
                                ),
                              ),
                              Icon(
                                weatherIcon(h.icon),
                                size: 22,
                                color: active ? Colors.white : AppColors.teal,
                              ),
                              Text(
                                '${h.temp.round()}°',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: active ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  _label('Conditions'),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _tile(Icons.thermostat, 'Feels like',
                          '${_weather.feelsLike.round()}°'),
                      _tile(Icons.water_drop_outlined, 'Humidity',
                          '${_weather.humidity}%'),
                      _tile(Icons.air, 'Wind',
                          '${_weather.windKph.round()} km/h'),
                      _tile(Icons.wb_sunny_outlined, 'UV index',
                          '${_weather.uvIndex}'),
                      _tile(Icons.visibility_outlined, 'Visibility',
                          '${_weather.visibilityKm} km'),
                      _tile(Icons.compress_rounded, 'Pressure',
                          '${_weather.pressureMb} mb'),
                      _tile(Icons.water_outlined, 'Precipitation',
                          '${_weather.precipMm} mm'),
                      _tile(Icons.eco_outlined, 'Air quality',
                          'AQI ${_weather.aqi}',
                          accent: aqiColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.mdAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _sun(Icons.wb_twilight, 'Sunrise',
                              _weather.sunrise),
                        ),
                        Container(
                            width: 1, height: 34, color: AppColors.border),
                        Expanded(
                          child: _sun(Icons.nights_stay_outlined, 'Sunset',
                              _weather.sunset),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _label('7-day forecast'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.mdAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _weather.daily.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: AppColors.border),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    _weather.daily[i].day,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  weatherIcon(_weather.daily[i].icon),
                                  color: AppColors.teal,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_weather.daily[i].rainChance}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.slate,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_weather.daily[i].low.round()}°',
                                  style: const TextStyle(color: AppColors.slate),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_weather.daily[i].high.round()}°',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _miniAction(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: AppRadii.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.smAll,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? dot}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: AppRadii.smAll,
        ),
        child: Column(
          children: [
            if (dot != null)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
    );
  }

  Widget _tile(IconData icon, String label, String value, {Color? accent}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: accent ?? AppColors.teal),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.slate)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sun(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.slate)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}
