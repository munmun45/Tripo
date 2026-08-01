import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_radii.dart';
import 'app_theme.dart';

/// Premium glassmorphism tokens + helpers for Tripo.
class Glass {
  Glass._();

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.ocean.withValues(alpha: 0.07),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.aqua.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get liftShadow => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.1),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];

  /// Soft white→sky→mint page wash with side glow (painted by [GlassBackground]).
  static const pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8FBFF),
      Color(0xFFF0F6FF),
      Color(0xFFE8F1FF),
      Color(0xFFF5F9FF),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static BoxDecoration panel({
    double radius = 18,
    double opacity = 0.78,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: opacity),
          AppColors.glassTint.withValues(alpha: opacity * 0.88),
          Colors.white.withValues(alpha: opacity * 0.72),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.9),
        width: 1.2,
      ),
      boxShadow: softShadow,
    );
  }

  static BoxDecoration bar({double opacity = 0.82}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity),
          AppColors.glassTint.withValues(alpha: opacity * 0.9),
        ],
      ),
      border: Border(
        bottom: BorderSide(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.ocean.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration navBar({double opacity = 0.88}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity * 0.95),
          Colors.white.withValues(alpha: opacity),
        ],
      ),
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  static BoxDecoration chip({bool selected = false}) {
    if (selected) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ocean, AppColors.teal],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ocean.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      color: Colors.white.withValues(alpha: 0.78),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
    );
  }
}

/// Full-page premium backdrop: white-forward wash + soft side glow / light rays.
class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool glowFromRight;

  const GlassBackground({
    super.key,
    required this.child,
    this.glowFromRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: Glass.pageGradient)),
        CustomPaint(
          painter: _GlowRaysPainter(fromRight: glowFromRight),
          size: Size.infinite,
        ),
        // Soft orbs for depth
        Positioned(
          top: -80,
          right: glowFromRight ? -60 : null,
          left: glowFromRight ? null : -60,
          child: _Orb(
            size: 220,
            color: AppColors.aqua.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          top: 180,
          left: glowFromRight ? -40 : null,
          right: glowFromRight ? null : -40,
          child: _Orb(
            size: 160,
            color: AppColors.softMint.withValues(alpha: 0.55),
          ),
        ),
        Positioned(
          bottom: 80,
          right: glowFromRight ? 40 : null,
          left: glowFromRight ? null : 40,
          child: _Orb(
            size: 140,
            color: AppColors.softSky.withValues(alpha: 0.5),
          ),
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowRaysPainter extends CustomPainter {
  final bool fromRight;

  _GlowRaysPainter({required this.fromRight});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(
      fromRight ? size.width * 1.05 : -size.width * 0.05,
      size.height * 0.12,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.aqua.withValues(alpha: 0.14),
          AppColors.teal.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: origin, radius: size.width * 0.85));
    canvas.drawCircle(origin, size.width * 0.85, paint);

    // Subtle light rays
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 6; i++) {
      final angle = (fromRight ? math.pi * 0.85 : -math.pi * 0.15) + i * 0.11;
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(
          origin.dx + math.cos(angle) * size.height * 1.2,
          origin.dy + math.sin(angle) * size.height * 1.2,
        )
        ..lineTo(
          origin.dx + math.cos(angle + 0.04) * size.height * 1.2,
          origin.dy + math.sin(angle + 0.04) * size.height * 1.2,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowRaysPainter oldDelegate) =>
      oldDelegate.fromRight != fromRight;
}

/// Frosted glass card with optional tap + light press scale.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.blur = 12,
    this.onTap,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: enableBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                padding: padding,
                decoration: Glass.panel(radius: radius),
                child: child,
              ),
            )
          : Container(
              padding: padding,
              decoration: Glass.panel(radius: radius),
              child: child,
            ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.aqua.withValues(alpha: 0.12),
        highlightColor: AppColors.softSky.withValues(alpha: 0.35),
        child: content,
      ),
    );
  }
}

/// Frosted strip for top / bottom chrome.
class GlassChrome extends StatelessWidget {
  final Widget child;
  final bool top;
  final double blur;

  const GlassChrome({
    super.key,
    required this.child,
    this.top = true,
    this.blur = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: top ? Glass.bar() : Glass.navBar(),
          child: child,
        ),
      ),
    );
  }
}
