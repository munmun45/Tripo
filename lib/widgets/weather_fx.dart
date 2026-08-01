import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_data.dart';

/// Soft animated overlays matched to weather condition.
class WeatherFxLayer extends StatefulWidget {
  final IconKey iconKey;

  const WeatherFxLayer({super.key, required this.iconKey});

  @override
  State<WeatherFxLayer> createState() => _WeatherFxLayerState();
}

class _WeatherFxLayerState extends State<WeatherFxLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          switch (widget.iconKey) {
            case IconKey.sunny:
              return _SunnyFx(t: _c.value);
            case IconKey.partlyCloudy:
            case IconKey.cloudy:
              return _CloudDriftFx(t: _c.value);
            case IconKey.rainy:
              return _RainFx(t: _c.value);
            case IconKey.storm:
              return _StormFx(t: _c.value);
            case IconKey.fog:
              return _FogFx(t: _c.value);
            case IconKey.snow:
              return _SnowFx(t: _c.value);
          }
        },
      ),
    );
  }
}

class _SunnyFx extends StatelessWidget {
  final double t;
  const _SunnyFx({required this.t});

  @override
  Widget build(BuildContext context) {
    final pulse = 0.55 + 0.45 * math.sin(t * math.pi * 2);
    return Stack(
      children: [
        Positioned(
          right: -30,
          top: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.35 * pulse),
                  Colors.amber.withValues(alpha: 0.18 * pulse),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          top: 28,
          child: Transform.rotate(
            angle: t * math.pi * 0.35,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 52,
              color: Colors.white.withValues(alpha: 0.55 + 0.25 * pulse),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloudDriftFx extends StatelessWidget {
  final double t;
  const _CloudDriftFx({required this.t});

  @override
  Widget build(BuildContext context) {
    final dx = math.sin(t * math.pi * 2) * 10;
    return Stack(
      children: [
        Positioned(
          right: 8 + dx,
          top: 18,
          child: Icon(
            Icons.cloud_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        Positioned(
          right: 48 - dx,
          top: 42,
          child: Icon(
            Icons.cloud_rounded,
            size: 34,
            color: Colors.white.withValues(alpha: 0.28),
          ),
        ),
      ],
    );
  }
}

class _RainFx extends StatelessWidget {
  final double t;
  const _RainFx({required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RainPainter(t));
  }
}

class _RainPainter extends CustomPainter {
  final double t;
  _RainPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const drops = 28;
    for (var i = 0; i < drops; i++) {
      final x = (i * 37.0) % (size.width + 20) - 10;
      final speed = 0.35 + (i % 5) * 0.12;
      final y = ((t * speed + i * 0.07) % 1.0) * (size.height + 24) - 12;
      canvas.drawLine(Offset(x, y), Offset(x + 3, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _StormFx extends StatelessWidget {
  final double t;
  const _StormFx({required this.t});

  @override
  Widget build(BuildContext context) {
    // Soft lightning flash every ~1s
    final wave = math.sin(t * math.pi * 8);
    final flash = wave > 0.92 ? (wave - 0.92) / 0.08 : 0.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (flash > 0)
          ColoredBox(
            color: Colors.white.withValues(alpha: 0.18 * flash),
          ),
        CustomPaint(painter: _RainPainter(t)),
        Positioned(
          right: 22,
          top: 30,
          child: Icon(
            Icons.flash_on_rounded,
            size: 44,
            color: Colors.white.withValues(alpha: 0.35 + 0.45 * flash),
          ),
        ),
      ],
    );
  }
}

class _FogFx extends StatelessWidget {
  final double t;
  const _FogFx({required this.t});

  @override
  Widget build(BuildContext context) {
    final drift = math.sin(t * math.pi * 2) * 12;
    return Stack(
      children: [
        Positioned(
          left: -20 + drift,
          bottom: 40,
          right: 40 - drift,
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 10 - drift,
          bottom: 18,
          right: 10 + drift,
          child: Container(
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnowFx extends StatelessWidget {
  final double t;
  const _SnowFx({required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SnowPainter(t));
  }
}

class _SnowPainter extends CustomPainter {
  final double t;
  _SnowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    const flakes = 22;
    for (var i = 0; i < flakes; i++) {
      final baseX = (i * 41.0) % size.width;
      final sway = math.sin((t + i) * math.pi * 2) * 8;
      final y = ((t * (0.2 + (i % 4) * 0.08) + i * 0.05) % 1.0) *
              (size.height + 16) -
          8;
      final r = 1.4 + (i % 3) * 0.7;
      canvas.drawCircle(Offset(baseX + sway, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) =>
      oldDelegate.t != t;
}
