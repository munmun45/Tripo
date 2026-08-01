import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/weather_data.dart';

/// Live weather + AQI via Open-Meteo (free, no API key).
class WeatherService {
  WeatherService._();

  static const _timeout = Duration(seconds: 8);

  static Future<WeatherData> byCoordinates({
    required double lat,
    required double lng,
    String? city,
    String? country,
    bool isCurrentLocation = false,
  }) async {
    final resolved = await _resolvePlace(lat, lng, city, country);

    final weatherUri = Uri.parse(
      '${ApiConfig.openMeteoForecast}'
      '?latitude=$lat&longitude=$lng'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m,surface_pressure,visibility'
      '&hourly=temperature_2m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max,sunrise,sunset,uv_index_max'
      '&timezone=auto'
      '&forecast_days=7'
      '&wind_speed_unit=kmh',
    );

    final aqiUri = Uri.parse(
      '${ApiConfig.openMeteoAirQuality}'
      '?latitude=$lat&longitude=$lng'
      '&current=us_aqi,european_aqi,pm2_5'
      '&timezone=auto',
    );

    final weatherFuture = http.get(weatherUri).timeout(_timeout);
    final aqiFuture = http.get(aqiUri).timeout(_timeout);

    final weatherRes = await weatherFuture;
    if (weatherRes.statusCode != 200) {
      throw Exception('Weather API ${weatherRes.statusCode}: ${weatherRes.body}');
    }

    int aqi = 0;
    try {
      final aqiRes = await aqiFuture;
      if (aqiRes.statusCode == 200) {
        final aqiData = jsonDecode(aqiRes.body) as Map<String, dynamic>;
        final aqiCurrent = aqiData['current'] as Map<String, dynamic>?;
        final us = aqiCurrent?['us_aqi'];
        final eu = aqiCurrent?['european_aqi'];
        if (us is num) {
          aqi = us.round();
        } else if (eu is num) {
          aqi = eu.round();
        }
      }
    } catch (_) {
      // AQI optional — weather still shows
    }

    final data = jsonDecode(weatherRes.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(data['current'] as Map);
    final hourly = Map<String, dynamic>.from(data['hourly'] as Map);
    final daily = Map<String, dynamic>.from(data['daily'] as Map);

    final code = _asInt(current['weather_code']) ?? 0;
    final icon = _iconFromCode(code);

    final visibilityM = _asDouble(current['visibility']);
    final visibilityKm = visibilityM == null
        ? 10.0
        : (visibilityM / 1000).clamp(0.1, 50.0);

    final sunriseRaw = _asStringList(daily['sunrise']).first;
    final sunsetRaw = _asStringList(daily['sunset']).first;
    final uv = _asDoubleList(daily['uv_index_max']).isEmpty
        ? 0
        : _asDoubleList(daily['uv_index_max']).first.round();

    final hourlyTemps = _asDoubleList(hourly['temperature_2m']);
    final hourlyCodes = _asIntList(hourly['weather_code']);
    final hourlyTimes = _asStringList(hourly['time']);
    final now = DateTime.now();
    final hourlyForecast = <HourlyForecast>[];
    for (var i = 0; i < hourlyTimes.length && hourlyForecast.length < 8; i++) {
      DateTime t;
      try {
        t = DateTime.parse(hourlyTimes[i]);
      } catch (_) {
        continue;
      }
      if (t.isBefore(now.subtract(const Duration(hours: 1)))) continue;
      final c = i < hourlyCodes.length ? hourlyCodes[i] : code;
      hourlyForecast.add(
        HourlyForecast(
          time: hourlyForecast.isEmpty ? 'Now' : DateFormat('ha').format(t),
          temp: i < hourlyTemps.length ? hourlyTemps[i] : 0,
          condition: _conditionFromCode(c),
          icon: _iconFromCode(c),
        ),
      );
    }
    if (hourlyForecast.isEmpty) {
      hourlyForecast.add(
        HourlyForecast(
          time: 'Now',
          temp: _asDouble(current['temperature_2m']) ?? 0,
          condition: _conditionFromCode(code),
          icon: icon,
        ),
      );
    }

    final dailyCodes = _asIntList(daily['weather_code']);
    final dailyMax = _asDoubleList(daily['temperature_2m_max']);
    final dailyMin = _asDoubleList(daily['temperature_2m_min']);
    final rainChance = _asIntList(daily['precipitation_probability_max']);
    final dailyTimes = _asStringList(daily['time']);
    final dailyForecast = <DailyForecast>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      final day = DateTime.tryParse(dailyTimes[i]) ?? DateTime.now();
      final label = i == 0 ? 'Today' : DateFormat('E').format(day);
      final dCode = i < dailyCodes.length ? dailyCodes[i] : code;
      dailyForecast.add(
        DailyForecast(
          day: label,
          high: i < dailyMax.length ? dailyMax[i] : 0,
          low: i < dailyMin.length ? dailyMin[i] : 0,
          condition: _conditionFromCode(dCode),
          icon: _iconFromCode(dCode),
          rainChance: i < rainChance.length ? rainChance[i] : 0,
        ),
      );
    }

    return WeatherData(
      city: resolved.$1,
      country: resolved.$2,
      temperature: _asDouble(current['temperature_2m']) ?? 0,
      condition: _conditionFromCode(code),
      description: _descriptionFromCode(code),
      icon: icon,
      feelsLike: _asDouble(current['apparent_temperature']) ?? 0,
      humidity: _asInt(current['relative_humidity_2m']) ?? 0,
      windKph: _asDouble(current['wind_speed_10m']) ?? 0,
      uvIndex: uv,
      visibilityKm: double.parse(visibilityKm.toStringAsFixed(1)),
      pressureMb: (_asDouble(current['surface_pressure']) ?? 1013).round(),
      sunrise: _formatIsoTime(sunriseRaw),
      sunset: _formatIsoTime(sunsetRaw),
      precipMm: _asDouble(current['precipitation']) ?? 0,
      aqi: aqi,
      hourly: hourlyForecast,
      daily: dailyForecast,
      isCurrentLocation: isCurrentLocation,
    );
  }

  static Future<WeatherData> forMumbaiLive() {
    return byCoordinates(
      lat: 19.0760,
      lng: 72.8777,
      city: 'Mumbai',
      country: 'India',
      isCurrentLocation: true,
    );
  }

  static Future<List<CityOption>> searchCities(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];
    final uri = Uri.parse(
      '${ApiConfig.openMeteoGeocoding}'
      '?name=${Uri.encodeComponent(q)}&count=8&language=en&format=json',
    );
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['results'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return CityOption(
        name: m['name'] as String? ?? 'Unknown',
        country: m['country'] as String? ?? '',
        lat: (m['latitude'] as num).toDouble(),
        lng: (m['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  static Future<(String, String)> _resolvePlace(
    double lat,
    double lng,
    String? city,
    String? country,
  ) async {
    if (city != null &&
        city.isNotEmpty &&
        city != 'My location' &&
        country != null &&
        country.isNotEmpty &&
        country != 'Current') {
      return (city, country);
    }
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng'
        '&key=${ApiConfig.googleMapsApiKey}'
        '&result_type=locality|administrative_area_level_2',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final components =
              (results.first as Map)['address_components'] as List<dynamic>? ??
                  [];
          String name = city ?? 'My location';
          String ctry = country ?? '';
          for (final raw in components) {
            final c = raw as Map<String, dynamic>;
            final types = (c['types'] as List).cast<String>();
            if (types.contains('locality') ||
                types.contains('administrative_area_level_2')) {
              name = c['long_name'] as String? ?? name;
            }
            if (types.contains('country')) {
              ctry = c['long_name'] as String? ?? ctry;
            }
          }
          return (name, ctry.isEmpty ? 'Current' : ctry);
        }
      }
    } catch (_) {}
    return (city ?? 'My location', country ?? 'Current');
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return null;
  }

  static double? _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return null;
  }

  static List<double> _asDoubleList(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => e is num ? e.toDouble() : 0.0).toList();
  }

  static List<int> _asIntList(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => e is num ? e.round() : 0).toList();
  }

  static List<String> _asStringList(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => e?.toString() ?? '').toList();
  }

  static String _formatIsoTime(String iso) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  static IconKey _iconFromCode(int code) {
    if (code == 0) return IconKey.sunny;
    if (code == 1 || code == 2) return IconKey.partlyCloudy;
    if (code == 3) return IconKey.cloudy;
    if (code == 45 || code == 48) return IconKey.fog;
    if (code >= 51 && code <= 67) return IconKey.rainy;
    if (code >= 71 && code <= 77) return IconKey.snow;
    if (code >= 80 && code <= 82) return IconKey.rainy;
    if (code >= 85 && code <= 86) return IconKey.snow;
    if (code >= 95) return IconKey.storm;
    return IconKey.partlyCloudy;
  }

  static String _conditionFromCode(int code) {
    if (code == 0) return 'Clear';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 56 && code <= 57) return 'Freezing Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 66 && code <= 67) return 'Freezing Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 85 && code <= 86) return 'Snow Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Partly Cloudy';
  }

  static String _descriptionFromCode(int code) {
    switch (_iconFromCode(code)) {
      case IconKey.sunny:
        return 'Clear skies and bright conditions';
      case IconKey.partlyCloudy:
        return 'A mix of sun and clouds';
      case IconKey.cloudy:
        return 'Mostly cloudy overhead';
      case IconKey.rainy:
        return 'Expect wet conditions';
      case IconKey.storm:
        return 'Thunderstorms in the area';
      case IconKey.fog:
        return 'Reduced visibility in fog';
      case IconKey.snow:
        return 'Snowy conditions expected';
    }
  }
}
