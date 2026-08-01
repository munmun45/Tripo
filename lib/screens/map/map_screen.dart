import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/places_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pull_refresh.dart';
import '../../widgets/skeletons/skeleton.dart';

class MapPlace {
  final String name;
  final LatLng point;
  final String? subtitle;

  const MapPlace({
    required this.name,
    required this.point,
    this.subtitle,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _searchController = TextEditingController();
  GoogleMapController? _controller;
  Timer? _debounce;

  final List<MapPlace> _pins = [
    const MapPlace(
      name: 'Gateway of India',
      point: LatLng(18.9220, 72.8347),
      subtitle: 'Mumbai landmark',
    ),
    const MapPlace(
      name: 'Marine Drive',
      point: LatLng(18.9432, 72.8235),
      subtitle: "Queen's Necklace",
    ),
  ];

  MapPlace? _selected;
  MapPlace? _routeFrom;
  MapPlace? _routeTo;
  bool _searching = false;
  bool _mapCreated = false;
  bool _locationOnMap = false;
  List<PlaceResult> _results = [];
  LatLng _center = const LatLng(18.9220, 72.8347);

  @override
  void initState() {
    super.initState();
    // Enable my-location only after a short defer — avoids GPS ANR on open.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _locationOnMap = true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers {
    return _pins.map((p) {
      final selected = _selected?.name == p.name &&
          _selected?.point == p.point;
      return Marker(
        markerId: MarkerId('${p.name}_${p.point.latitude}'),
        position: p.point,
        infoWindow: InfoWindow(title: p.name, snippet: p.subtitle),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selected ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
        ),
        onTap: () => _selectPlace(p, addPin: false),
      );
    }).toSet();
  }

  Set<Polyline> get _polylines {
    if (_routeFrom == null || _routeTo == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.coral,
        width: 4,
        points: [_routeFrom!.point, _routeTo!.point],
      ),
    };
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final list = await PlacesService.search(q);
      if (mounted) setState(() => _results = list);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (v.length >= 3) _search(v);
    });
  }

  Future<void> _selectPlace(MapPlace place, {bool addPin = true}) async {
    setState(() {
      _selected = place;
      _center = place.point;
      _results = [];
      _searchController.text = place.name;
      if (addPin &&
          !_pins.any(
            (p) =>
                p.name == place.name &&
                (p.point.latitude - place.point.latitude).abs() < 0.0001,
          )) {
        _pins.add(place);
      }
    });
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(place.point, 14),
    );
  }

  Future<void> _openGoogleMapsDirections() async {
    final from = _routeFrom ?? _pins.first;
    final to = _routeTo ?? _selected ?? _pins.last;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${from.point.latitude},${from.point.longitude}'
      '&destination=${to.point.latitude},${to.point.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInGoogleMaps(MapPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${place.point.latitude},${place.point.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _results = [];
      _searchController.clear();
      _selected = null;
      _routeFrom = null;
      _routeTo = null;
      _center = const LatLng(18.9220, 72.8347);
    });
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_center, 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: PullRefresh(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: SizedBox(
            height: h,
            child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 13),
            myLocationEnabled: _locationOnMap,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            liteModeEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (c) {
              _controller = c;
              if (!_mapCreated && mounted) {
                setState(() => _mapCreated = true);
              }
            },
            onTap: (point) {
              _selectPlace(
                MapPlace(
                  name: 'Dropped pin',
                  point: point,
                  subtitle:
                      '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                ),
              );
            },
          ),
          if (!_mapCreated) const Positioned.fill(child: MapSkeleton()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onSubmitted: _search,
                          onChanged: _onQueryChanged,
                          decoration: InputDecoration(
                            hintText: 'Search with Google Maps…',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.directions_rounded),
                                    onPressed: _openGoogleMapsDirections,
                                    tooltip: 'Directions',
                                  ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                        ),
                        if (_results.isNotEmpty)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _results.length,
                              itemBuilder: (context, i) {
                                final r = _results[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.place_outlined,
                                    color: AppColors.teal,
                                  ),
                                  title: Text(r.name),
                                  subtitle: Text(
                                    r.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _selectPlace(
                                    MapPlace(
                                      name: r.name,
                                      point: LatLng(r.lat, r.lng),
                                      subtitle: r.address,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (_selected != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selected!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (_selected!.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _selected!.subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  avatar: const Icon(Icons.flag_outlined,
                                      size: 16),
                                  label: const Text('Start'),
                                  onPressed: () {
                                    setState(() => _routeFrom = _selected);
                                  },
                                ),
                                ActionChip(
                                  avatar:
                                      const Icon(Icons.flag_rounded, size: 16),
                                  label: const Text('End'),
                                  onPressed: () {
                                    setState(() => _routeTo = _selected);
                                  },
                                ),
                                ActionChip(
                                  avatar: const Icon(Icons.directions_rounded,
                                      size: 16),
                                  label: const Text('Directions'),
                                  onPressed: _openGoogleMapsDirections,
                                ),
                                ActionChip(
                                  avatar: const Icon(Icons.open_in_new_rounded,
                                      size: 16),
                                  label: const Text('Google Maps'),
                                  onPressed: () =>
                                      _openInGoogleMaps(_selected!),
                                ),
                              ],
                            ),
                            if (_routeFrom != null || _routeTo != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Route: ${_routeFrom?.name ?? '—'} → ${_routeTo?.name ?? '—'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.ocean,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selected != null ? 200 : 24,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.white,
                  onPressed: () =>
                      _controller?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add, color: AppColors.ocean),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.white,
                  onPressed: () =>
                      _controller?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove, color: AppColors.ocean),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_loc',
                  backgroundColor: AppColors.ocean,
                  onPressed: () async {
                    const mumbai = LatLng(19.0760, 72.8777);
                    await _controller?.animateCamera(
                      CameraUpdate.newLatLngZoom(mumbai, 13),
                    );
                    _selectPlace(
                      const MapPlace(
                        name: 'Current area',
                        point: mumbai,
                        subtitle: 'Mumbai · enable GPS for live location',
                      ),
                    );
                  },
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }
}
