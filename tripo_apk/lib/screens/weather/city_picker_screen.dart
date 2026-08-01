import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/dummy_weather.dart';
import '../../models/weather_data.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/pull_refresh.dart';
import '../../widgets/skeletons/skeleton.dart';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<CityOption> _filtered = DummyWeather.cities;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _filtered = DummyWeather.cities;
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final remote = await WeatherService.searchCities(query);
      if (!mounted) return;
      setState(() {
        _filtered = remote.isEmpty
            ? DummyWeather.cities
                .where((c) =>
                    c.name.toLowerCase().contains(query.toLowerCase()) ||
                    c.country.toLowerCase().contains(query.toLowerCase()))
                .toList()
            : remote;
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    final pos = await LocationService.currentPosition();
    if (!mounted) return;
    if (pos == null) {
      Navigator.pop(
        context,
        const CityOption(
          name: 'Mumbai',
          country: 'India',
          lat: 19.0760,
          lng: 72.8777,
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      CityOption(
        name: 'My location',
        country: 'Current',
        lat: pos.latitude,
        lng: pos.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Choose city',
      subtitle: 'Search worldwide',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Search any city worldwide',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.mist,
              child: Icon(Icons.my_location_rounded, color: AppColors.ocean),
            ),
            title: const Text('Use current location'),
            subtitle: const Text('GPS + live weather & AQI'),
            onTap: _useCurrentLocation,
          ),
          const Divider(height: 1),
          Expanded(
            child: PullRefresh(
              onRefresh: () async {
                await _search(_controller.text);
              },
              child: _searching
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: CityListSkeleton()),
                      ],
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final c = _filtered[i];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.mist,
                            child: Icon(Icons.location_city_rounded,
                                color: AppColors.teal, size: 18),
                          ),
                          title: Text(c.name),
                          subtitle: Text(c.country),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pop(context, c),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
