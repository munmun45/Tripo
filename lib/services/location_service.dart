import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  /// Fast path for home / low-end devices — never blocks UI long.
  static Future<Position?> currentPosition({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2),
              onTimeout: () => LocationPermission.denied);
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 8),
                onTimeout: () => LocationPermission.denied);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Instant when available — avoids GPS wait / ANR on cold start.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: timeout,
          distanceFilter: 100,
        ),
      ).timeout(timeout);
    } catch (_) {
      return null;
    }
  }
}
