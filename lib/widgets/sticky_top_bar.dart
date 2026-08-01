import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/glass.dart';

/// Fixed top navigation — frosted glass chrome.
class StickyTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBack;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;

  const StickyTopBar({
    super.key,
    this.title = 'Tripo',
    this.subtitle = 'Travel beautifully',
    this.showBack = false,
    this.showMenu = true,
    this.onMenuTap,
    this.onBack,
    this.onSearchTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GlassChrome(
      top: true,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              if (showBack)
                _iconBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                )
              else if (showMenu)
                _iconBtn(
                  icon: Icons.menu_rounded,
                  onTap: onMenuTap ?? () {},
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 20),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.teal,
                          ),
                    ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onSearchTap != null)
                    _iconBtn(
                        icon: Icons.search_rounded, onTap: onSearchTap!),
                  if (onSearchTap != null &&
                      (onNotificationTap != null || onProfileTap != null))
                    const SizedBox(width: 6),
                  if (onNotificationTap != null)
                    _iconBtn(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotificationTap!,
                    ),
                  if (onNotificationTap != null && onProfileTap != null)
                    const SizedBox(width: 6),
                  if (onProfileTap != null) _profileBtn(onProfileTap!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileBtn(VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: const Size(34, 34),
      ),
      icon: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              AppColors.softSky,
            ],
          ),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: Glass.softShadow,
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 16,
          color: AppColors.ocean,
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: const Size(34, 34),
        elevation: 0,
      ),
      icon: Icon(icon, color: AppColors.ocean, size: 22),
    );
  }
}
