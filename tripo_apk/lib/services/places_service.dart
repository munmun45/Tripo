import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class PlaceResult {
  final String name;
  final String address;
  final double lat;
  final double lng;

  const PlaceResult({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class PlacesService {
  PlacesService._();

  /// Google Geocoding / Places text search via Geocoding API.
  static Future<List<PlaceResult>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(q)}'
      '&key=${ApiConfig.googleMapsApiKey}',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['status'] != 'OK' && body['status'] != 'ZERO_RESULTS') {
      return [];
    }
    final results = body['results'] as List<dynamic>? ?? [];
    return results.take(6).map((e) {
      final m = e as Map<String, dynamic>;
      final loc = (m['geometry'] as Map)['location'] as Map;
      final formatted = m['formatted_address'] as String? ?? '';
      final name = formatted.split(',').first;
      return PlaceResult(
        name: name,
        address: formatted,
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
      );
    }).toList();
  }
}
