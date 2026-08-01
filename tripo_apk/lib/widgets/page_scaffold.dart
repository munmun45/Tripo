import 'package:flutter/material.dart';

import '../theme/glass.dart';
import 'sticky_top_bar.dart';

/// Fixed top bar on every pushed page. Premium glass background.
class PageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final VoidCallback? onBack;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle = 'Travel beautifully',
    this.onBack,
    this.onSearchTap,
    this.onNotificationTap,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      body: GlassBackground(
        child: Column(
          children: [
            StickyTopBar(
              title: title,
              subtitle: subtitle,
              showBack: true,
              showMenu: false,
              onBack: onBack ?? () => Navigator.of(context).maybePop(),
              onSearchTap: onSearchTap,
              onNotificationTap: onNotificationTap,
              actions: actions,
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
