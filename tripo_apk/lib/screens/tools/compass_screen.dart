import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';

import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  StreamSubscription<MagnetometerEvent>? _sub;
  double _heading = 0;
  bool _ok = true;
  Position? _pos;
  String? _place;

  @override
  void initState() {
    super.initState();
    _startCompass();
    _loadLocation();
  }

  void _startCompass() {
    try {
      _sub = magnetometerEventStream().listen((e) {
        var deg = math.atan2(e.y, e.x) * 180 / math.pi;
        deg = (deg + 360) % 360;
        if (mounted) {
          setState(() {
            _heading = deg;
            _ok = true;
          });
        }
      }, onError: (_) {
        if (mounted) setState(() => _ok = false);
      });
    } catch (_) {
      _ok = false;
    }
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService.currentPosition();
    if (!mounted) return;
    setState(() => _pos = pos);
    if (pos == null) return;
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=10',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'TripoTravelApp/1.0'})
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && mounted) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = j['address'] as Map<String, dynamic>?;
        final city = addr?['city'] ??
            addr?['town'] ??
            addr?['village'] ??
            addr?['state_district'];
        final state = addr?['state'];
        final parts = <String>[
          if (city != null) '$city',
          if (state != null) '$state',
        ];
        if (parts.isNotEmpty) setState(() => _place = parts.join(', '));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String get _dir {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final i = ((_heading + 22.5) % 360 / 45).floor();
    return dirs[i.clamp(0, 7)];
  }

  String _dms(double value, bool lat) {
    final abs = value.abs();
    final d = abs.floor();
    final mFull = (abs - d) * 60;
    final m = mFull.floor();
    final s = ((mFull - m) * 60).round();
    final hemi = lat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
    return "$d°$m'$s\" $hemi";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dial = (size.shortestSide * 0.72).clamp(220.0, 300.0);

    return PageScaffold(
      title: 'Compass',
      subtitle: _ok ? 'Hold phone flat' : 'Sensor unavailable',
      backgroundColor: AppColors.white,
      body: ColoredBox(
        color: AppColors.white,
        child: Column(
          children: [
            const SizedBox(height: 6),
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                  width: dial,
                  height: dial,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: -_heading * math.pi / 180,
                        child: CustomPaint(
                          size: Size(dial, dial),
                          painter: _CompassDialPainter(),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 2,
                          height: dial * 0.07,
                          color: AppColors.ink,
                        ),
                      ),
                      Positioned(
                        top: dial * 0.075,
                        child: CustomPaint(
                          size: const Size(14, 11),
                          painter: _NeedleTipPainter(),
                        ),
                      ),
                      CustomPaint(
                        size: Size(dial * 0.2, dial * 0.2),
                        painter: _CrosshairPainter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_heading.toStringAsFixed(0)}° $_dir',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_pos != null) ...[
                      Text(
                        '${_dms(_pos!.latitude, true)}  ${_dms(_pos!.longitude, false)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                      if (_place != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          _place!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.slate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        '${_pos!.altitude.isFinite ? _pos!.altitude.round() : '—'}m Elevation',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate,
                        ),
                      ),
                    ] else
                      const Text(
                        'Getting location…',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slate,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedleTipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.ocean);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.slate.withValues(alpha: 0.4)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, size.width * 0.28, paint);
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), paint);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final ring = Paint()
      ..color = const Color(0xFFD5DEE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(c, r - 1.5, ring);
    canvas.drawCircle(c, r * 0.76, ring);

    final tick = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final major = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 360; i += 5) {
      final rad = (i - 90) * math.pi / 180;
      final isMajor = i % 30 == 0;
      final isMid = i % 10 == 0;
      final outer = r * 0.745;
      final inner = isMajor
          ? r * 0.64
          : isMid
              ? r * 0.68
              : r * 0.71;
      canvas.drawLine(
        Offset(c.dx + outer * math.cos(rad), c.dy + outer * math.sin(rad)),
        Offset(c.dx + inner * math.cos(rad), c.dy + inner * math.sin(rad)),
        isMajor ? major : tick,
      );
    }

    for (var i = 0; i < 360; i += 30) {
      final rad = (i - 90) * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          c.dx + (r * 0.88) * math.cos(rad) - tp.width / 2,
          c.dy + (r * 0.88) * math.sin(rad) - tp.height / 2,
        ),
      );
    }

    void card(String t, double angDeg, {bool north = false}) {
      final rad = (angDeg - 90) * math.pi / 180;
      final pr = r * 0.48;
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: TextStyle(
            color: north ? AppColors.ocean : AppColors.ink,
            fontSize: north ? 22 : 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          c.dx + pr * math.cos(rad) - tp.width / 2,
          c.dy + pr * math.sin(rad) - tp.height / 2,
        ),
      );
    }

    card('N', 0, north: true);
    card('E', 90);
    card('S', 180);
    card('W', 270);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
