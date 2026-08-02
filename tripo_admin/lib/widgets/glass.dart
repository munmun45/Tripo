import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/admin_theme.dart';

/// Soft mesh orbs behind the whole admin shell.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F3FF),
                Color(0xFFD7F0EC),
                Color(0xFFF3EFE8),
                Color(0xFFDDE7F8),
              ],
              stops: [0, 0.35, 0.7, 1],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _Orb(color: AdminTheme.ocean.withValues(alpha: 0.28), size: 280),
        ),
        Positioned(
          top: 180,
          left: -90,
          child: _Orb(color: AdminTheme.teal.withValues(alpha: 0.26), size: 260),
        ),
        Positioned(
          bottom: -60,
          right: 80,
          child: _Orb(color: AdminTheme.coral.withValues(alpha: 0.18), size: 220),
        ),
        Positioned(
          bottom: 120,
          left: 180,
          child: _Orb(color: AdminTheme.amber.withValues(alpha: 0.16), size: 160),
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? tint;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.blur = 18,
    this.tint,
    this.gradient,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AdminTheme.ink.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (tint ?? Colors.white).withValues(alpha: 0.62),
                      (tint ?? Colors.white).withValues(alpha: 0.28),
                    ],
                  ),
              border: Border.all(color: AdminTheme.glassStroke, width: 1.2),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class GlassIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const GlassIconBox({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class GlassNavTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const GlassNavTile({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 14,
              vertical: compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        AdminTheme.ocean.withValues(alpha: 0.22),
                        AdminTheme.teal.withValues(alpha: 0.14),
                      ],
                    )
                  : null,
              border: Border.all(
                color: selected
                    ? AdminTheme.ocean.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        color: selected ? AdminTheme.ocean : AdminTheme.slate,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? AdminTheme.ink : AdminTheme.slate,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        color: selected ? AdminTheme.ocean : AdminTheme.slate,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? AdminTheme.ink : AdminTheme.slate,
                          ),
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
