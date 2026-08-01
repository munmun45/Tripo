import 'dart:ui';

import 'package:flutter/material.dart';
import '../services/saved_packages_store.dart';
import '../theme/app_theme.dart';
import '../theme/glass.dart';

enum TravelTool {
  myPackages,
  planPackage,
  weather,
  compass,
  splitMoney,
  emergency,
  packingList,
  currency,
  translator,
  documents,
  tripNotes,
  todo,
  map,
  createTrip,
  expenses,
  trekking,
  worldClock,
  flashlight,
  tools,
}

class TravelToolItem {
  final TravelTool tool;
  final IconData icon;
  final String label;

  const TravelToolItem({
    required this.tool,
    required this.icon,
    required this.label,
  });
}

/// Shared list used by More sheet + side menu.
class TravelTools {
  TravelTools._();

  static const all = <TravelToolItem>[
    TravelToolItem(
      tool: TravelTool.tripNotes,
      icon: Icons.sticky_note_2_outlined,
      label: 'Notes',
    ),
    TravelToolItem(
      tool: TravelTool.todo,
      icon: Icons.checklist_rounded,
      label: 'Todo',
    ),
    TravelToolItem(
      tool: TravelTool.compass,
      icon: Icons.explore_rounded,
      label: 'Compass',
    ),
    TravelToolItem(
      tool: TravelTool.emergency,
      icon: Icons.medical_services_rounded,
      label: 'Emergency',
    ),
    TravelToolItem(
      tool: TravelTool.worldClock,
      icon: Icons.public_rounded,
      label: 'World Clock',
    ),
    TravelToolItem(
      tool: TravelTool.currency,
      icon: Icons.currency_exchange_rounded,
      label: 'Currency',
    ),
    TravelToolItem(
      tool: TravelTool.translator,
      icon: Icons.translate_rounded,
      label: 'Translate',
    ),
    TravelToolItem(
      tool: TravelTool.myPackages,
      icon: Icons.bookmark_rounded,
      label: 'Saved Packages',
    ),
    TravelToolItem(
      tool: TravelTool.documents,
      icon: Icons.folder_outlined,
      label: 'Docs',
    ),
    TravelToolItem(
      tool: TravelTool.splitMoney,
      icon: Icons.account_balance_wallet_outlined,
      label: 'Split Money',
    ),
  ];
}

class _Feature {
  final TravelTool tool;
  final IconData icon;
  final String label;
  final Color tint;
  final Color iconColor;

  const _Feature({
    required this.tool,
    required this.icon,
    required this.label,
    required this.tint,
    required this.iconColor,
  });
}

/// More sheet — Notes, Todo, Compass, Emergency, World Clock, Currency, Translate.
/// 4 items per row.
class ToolsSheet extends StatelessWidget {
  final ValueChanged<TravelTool> onSelect;

  const ToolsSheet({super.key, required this.onSelect});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<TravelTool> onSelect,
  }) {
    SavedPackagesStore.instance.load();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ToolsSheet(onSelect: onSelect),
    );
  }

  static const _features = <_Feature>[
    _Feature(
      tool: TravelTool.tripNotes,
      icon: Icons.sticky_note_2_rounded,
      label: 'Notes',
      tint: Color(0xFFFFF3D6),
      iconColor: Color(0xFFE6A100),
    ),
    _Feature(
      tool: TravelTool.todo,
      icon: Icons.checklist_rounded,
      label: 'Todo',
      tint: Color(0xFFDDF7E8),
      iconColor: Color(0xFF1FA971),
    ),
    _Feature(
      tool: TravelTool.compass,
      icon: Icons.explore_rounded,
      label: 'Compass',
      tint: Color(0xFFDDEBFF),
      iconColor: Color(0xFF2B6BCF),
    ),
    _Feature(
      tool: TravelTool.emergency,
      icon: Icons.medical_services_rounded,
      label: 'Emergency',
      tint: Color(0xFFFFE0E3),
      iconColor: Color(0xFFE23D4A),
    ),
    _Feature(
      tool: TravelTool.worldClock,
      icon: Icons.public_rounded,
      label: 'World Clock',
      tint: Color(0xFFE4F4FF),
      iconColor: Color(0xFF0B8FBF),
    ),
    _Feature(
      tool: TravelTool.currency,
      icon: Icons.currency_exchange_rounded,
      label: 'Currency',
      tint: Color(0xFFE8F8E0),
      iconColor: Color(0xFF4CAF50),
    ),
    _Feature(
      tool: TravelTool.translator,
      icon: Icons.translate_rounded,
      label: 'Translate',
      tint: Color(0xFFF0E6FF),
      iconColor: Color(0xFF7B4FD6),
    ),
    _Feature(
      tool: TravelTool.myPackages,
      icon: Icons.bookmark_rounded,
      label: 'Saved Packages',
      tint: Color(0xFFFFE8D6),
      iconColor: Color(0xFFE06B1F),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.96),
                AppColors.glassTint.withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: Glass.liftShadow,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom > 0 ? 12 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tools',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const cols = 4;
                        const gap = 10.0;
                        final cellW =
                            (constraints.maxWidth - gap * (cols - 1)) / cols;
                        return ListenableBuilder(
                          listenable: SavedPackagesStore.instance,
                          builder: (context, _) {
                            final savedCount =
                                SavedPackagesStore.instance.count;
                            return Wrap(
                              spacing: gap,
                              runSpacing: 16,
                              children: [
                                for (final f in _features)
                                  SizedBox(
                                    width: cellW,
                                    child: _FeatureCell(
                                      feature: f,
                                      badgeCount:
                                          f.tool == TravelTool.myPackages
                                              ? savedCount
                                              : null,
                                      onTap: () {
                                        Navigator.pop(context);
                                        onSelect(f.tool);
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCell extends StatelessWidget {
  final _Feature feature;
  final VoidCallback onTap;
  final int? badgeCount;

  const _FeatureCell({
    required this.feature,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: feature.tint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: feature.iconColor.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Icon(
                          feature.icon,
                          color: feature.iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                    if (badgeCount != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 18),
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: feature.iconColor,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badgeCount! > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feature.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: feature.iconColor.withValues(alpha: 0.92),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
