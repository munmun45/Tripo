import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_radii.dart';
import '../../theme/app_theme.dart';

/// Soft shimmer wrapper used across all Tripo skeletons.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) return child;
    return Shimmer.fromColors(
      baseColor: AppColors.softBlue.withValues(alpha: 0.55),
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class SkeletonBone extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const SkeletonBone({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadii.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.softSky,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Shows [skeleton] until [loading] is false, with a minimum visible time.
mixin SkeletonPageMixin<T extends StatefulWidget> on State<T> {
  bool skeletonReady = false;
  static const skeletonMinMs = 650;

  Future<void> startSkeleton({int ms = skeletonMinMs}) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (mounted) setState(() => skeletonReady = true);
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonBone(height: 168, radius: AppRadii.md),
          const SizedBox(height: 20),
          const SkeletonBone(width: 140, height: 18),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: const SkeletonBone(height: 88, radius: AppRadii.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SkeletonBone(width: 110, height: 18),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: const SkeletonBone(width: 88, height: 36),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SkeletonBone(width: 160, height: 18),
          const SizedBox(height: 12),
          const _PackageRowSkeleton(),
          const SizedBox(height: 10),
          const _PackageRowSkeleton(),
          const SizedBox(height: 10),
          const _PackageRowSkeleton(),
        ],
      ),
    );
  }
}

class _PackageRowSkeleton extends StatelessWidget {
  const _PackageRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SkeletonBone(radius: 8),
                ),
                SizedBox(height: 8),
                SkeletonBone(width: 72, height: 12),
                SizedBox(height: 6),
                SkeletonBone(height: 10),
                SizedBox(height: 6),
                SkeletonBone(width: 48, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PackagesGridSkeleton extends StatelessWidget {
  final int count;

  const PackagesGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: count,
        itemBuilder: (_, i) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBone(radius: 8)),
            SizedBox(height: 8),
            SkeletonBone(width: 90, height: 12),
            SizedBox(height: 6),
            SkeletonBone(height: 10),
            SizedBox(height: 6),
            SkeletonBone(width: 56, height: 12),
          ],
        ),
      ),
    );
  }
}

class PackageDetailSkeleton extends StatelessWidget {
  const PackageDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const AspectRatio(
            aspectRatio: 16 / 10,
            child: SkeletonBone(radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBone(height: 26),
                const SizedBox(height: 8),
                const SkeletonBone(width: 180, height: 14),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    SkeletonBone(width: 88, height: 32, radius: AppRadii.sm),
                    SizedBox(width: 8),
                    SkeletonBone(width: 88, height: 32, radius: AppRadii.sm),
                  ],
                ),
                const SizedBox(height: 20),
                const SkeletonBone(width: 80, height: 18),
                const SizedBox(height: 10),
                const SkeletonBone(height: 12),
                const SizedBox(height: 8),
                const SkeletonBone(height: 12),
                const SizedBox(height: 8),
                const SkeletonBone(width: 220, height: 12),
                const SizedBox(height: 20),
                const SkeletonBone(width: 100, height: 18),
                const SizedBox(height: 10),
                ...List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: SkeletonBone(height: 14),
                  ),
                ),
                const SizedBox(height: 16),
                const SkeletonBone(height: 48, radius: AppRadii.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherCardSkeleton extends StatelessWidget {
  const WeatherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: const SkeletonBone(height: 168, radius: AppRadii.md),
    );
  }
}

class WeatherDetailSkeleton extends StatelessWidget {
  const WeatherDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonBone(height: 200, radius: AppRadii.md),
          const SizedBox(height: 16),
          const SkeletonBone(width: 120, height: 16),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: const SkeletonBone(height: 88, radius: AppRadii.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SkeletonBone(width: 100, height: 16),
          const SizedBox(height: 12),
          ...List.generate(
            5,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SkeletonBone(height: 52, radius: AppRadii.sm),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.softSky,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SkeletonBone(
                  width: 64,
                  height: 64,
                  radius: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBone(width: 140, height: 16),
                      SizedBox(height: 10),
                      SkeletonBone(width: 180, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SkeletonBone(height: 48, radius: AppRadii.md),
          const SizedBox(height: 28),
          const SkeletonBone(width: 110, height: 16),
          const SizedBox(height: 12),
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SkeletonBone(height: 64, radius: AppRadii.md),
            ),
          ),
        ],
      ),
    );
  }
}

class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Stack(
        children: [
          const Positioned.fill(
            child: SkeletonBone(radius: 0),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  const SkeletonBone(height: 52, radius: AppRadii.md),
                  const Spacer(),
                  const SkeletonBone(height: 120, radius: AppRadii.md),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppShimmer(
            child: const SkeletonBone(height: 48, radius: AppRadii.md),
          ),
        ),
        const Expanded(child: PackagesGridSkeleton(count: 4)),
      ],
    );
  }
}

class AuthFormSkeleton extends StatelessWidget {
  const AuthFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SkeletonBone(width: 160, height: 24),
            SizedBox(height: 10),
            SkeletonBone(width: 220, height: 14),
            SizedBox(height: 28),
            SkeletonBone(height: 52, radius: AppRadii.md),
            SizedBox(height: 14),
            SkeletonBone(height: 52, radius: AppRadii.md),
            SizedBox(height: 14),
            SkeletonBone(height: 52, radius: AppRadii.md),
            SizedBox(height: 24),
            SkeletonBone(height: 48, radius: AppRadii.md),
          ],
        ),
      ),
    );
  }
}

class CityListSkeleton extends StatelessWidget {
  const CityListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, i) => const SizedBox(height: 10),
        itemBuilder: (_, i) => const SkeletonBone(
          height: 56,
          radius: AppRadii.sm,
        ),
      ),
    );
  }
}
