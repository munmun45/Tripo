/// API keys & endpoints for Tripo.
/// Restrict this Google key in Cloud Console (Android/iOS package + Maps APIs only).
class ApiConfig {
  static const googleMapsApiKey = 'AIzaSyCP3WJE-zs_Pw5lwBs6GFmbJ4Qofgag_WQ';

  /// Open-Meteo — free, no key, high-quality forecast (ECMWF / etc.)
  static const openMeteoForecast =
      'https://api.open-meteo.com/v1/forecast';
  static const openMeteoAirQuality =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const openMeteoGeocoding =
      'https://geocoding-api.open-meteo.com/v1/search';
}
