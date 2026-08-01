class HourlyForecast {
  final String time;
  final double temp;
  final String condition;
  final IconKey icon;

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    required this.icon,
  });
}

class DailyForecast {
  final String day;
  final double high;
  final double low;
  final String condition;
  final IconKey icon;
  final int rainChance;

  const DailyForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
    required this.icon,
    required this.rainChance,
  });
}

enum IconKey { sunny, cloudy, rainy, storm, partlyCloudy, fog, snow }

class WeatherData {
  final String city;
  final String country;
  final double temperature;
  final String condition;
  final String description;
  final IconKey icon;
  final double feelsLike;
  final int humidity;
  final double windKph;
  final int uvIndex;
  final double visibilityKm;
  final int pressureMb;
  final String sunrise;
  final String sunset;
  final double precipMm;
  final int aqi;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final bool isCurrentLocation;

  const WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windKph,
    required this.uvIndex,
    required this.visibilityKm,
    required this.pressureMb,
    required this.sunrise,
    required this.sunset,
    required this.precipMm,
    required this.aqi,
    required this.hourly,
    required this.daily,
    this.isCurrentLocation = false,
  });
}

class CityOption {
  final String name;
  final String country;
  final double lat;
  final double lng;

  const CityOption({
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
  });
}
