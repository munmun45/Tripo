import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/glass.dart';

/// Frosted glass bottom nav with soft selected pill.
/// Indexes: 0 Home · 1 Trips · 2 Map · 3 Split · 4 Docs · More is an action.
class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMoreTap;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassChrome(
      top: false,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              _NavTab(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavTab(
                label: 'Trips',
                icon: Icons.luggage_outlined,
                selectedIcon: Icons.luggage_rounded,
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavTab(
                label: 'Map',
                icon: Icons.map_outlined,
                selectedIcon: Icons.map_rounded,
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavTab(
                label: 'Split',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavTab(
                label: 'Docs',
                icon: Icons.folder_outlined,
                selectedIcon: Icons.folder_rounded,
                selected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
              _NavTab(
                label: 'More',
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
                selected: false,
                onTap: onMoreTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ocean : AppColors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.softSky.withValues(alpha: 0.9)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.aqua.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
