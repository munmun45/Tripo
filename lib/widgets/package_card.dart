import 'package:flutter/material.dart';
import '../models/travel_package.dart';
import '../theme/app_theme.dart';
import '../theme/glass.dart';

class PackageCard extends StatelessWidget {
  final TravelPackage package;
  final VoidCallback onTap;
  final bool compact;
  final bool rowItem;

  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.compact = false,
    this.rowItem = false,
  });

  int _cacheW(BuildContext context, double logical) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logical * dpr).round().clamp(120, 800);
  }

  Widget _netImage(BuildContext context, {required double logicalWidth}) {
    return Image.network(
      package.imageUrl,
      fit: BoxFit.cover,
      cacheWidth: _cacheW(context, logicalWidth),
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.mist);
      },
      errorBuilder: (context, error, stackTrace) =>
          Container(color: AppColors.mist),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
          Text(
            ' ${package.rating}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rowItem || compact) return _gridCard(context);
    return _wide(context);
  }

  /// Clean 2-column home / grid card — image + city + duration + category.
  Widget _gridCard(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: Glass.panel(radius: 14, opacity: 0.82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _netImage(context, logicalWidth: w),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: _ratingBadge(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              package.city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              package.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.stayShort,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        package.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: AppColors.ocean,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wide(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 14),
        decoration: Glass.panel(radius: 16, opacity: 0.88),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _netImage(context, logicalWidth: 240),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: _ratingBadge(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package.stayShort,
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
