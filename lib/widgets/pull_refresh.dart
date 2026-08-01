import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared pull-to-refresh look for all Tripo scroll pages.
class PullRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  const PullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color ?? AppColors.ocean,
      backgroundColor: AppColors.white,
      displacement: 48,
      strokeWidth: 2.5,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
