import 'package:flutter/material.dart';
import '../../models/travel_package.dart';
import '../../services/saved_packages_store.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/pull_refresh.dart';
import '../search_screen.dart';

class PackageDetailScreen extends StatefulWidget {
  final TravelPackage package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final _saved = SavedPackagesStore.instance;

  TravelPackage get package => widget.package;

  @override
  void initState() {
    super.initState();
    _saved.addListener(_refresh);
    _saved.load();
  }

  @override
  void dispose() {
    _saved.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleSave() async {
    await _saved.toggle(package.id);
    if (!mounted) return;
    final nowSaved = _saved.isSaved(package.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (nowSaved ? AppColors.teal : AppColors.slate)
                  .withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (nowSaved ? AppColors.teal : AppColors.slate)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  nowSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_remove_rounded,
                  size: 20,
                  color: nowSaved ? AppColors.teal : AppColors.slate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nowSaved ? 'Saved to your packages' : 'Removed from saved',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => messenger.hideCurrentSnackBar(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isSaved = _saved.isSaved(package.id);

    return PageScaffold(
      title: package.city,
      subtitle: package.country,
      onSearchTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      actions: [
        IconButton(
          tooltip: isSaved ? 'Unsave' : 'Save package',
          onPressed: _toggleSave,
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isSaved ? AppColors.ocean : AppColors.slate,
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: PullRefresh(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.zero,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      package.imageUrl,
                      fit: BoxFit.cover,
                      // Decode smaller for low-RAM Indian devices.
                      cacheWidth:
                          (screenW * MediaQuery.devicePixelRatioOf(context))
                              .round()
                              .clamp(320, 1200),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: AppColors.mist);
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppColors.ocean),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 16, color: AppColors.slate),
                            Expanded(
                              child: Text(
                                ' ${package.city}, ${package.country}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.star_rounded,
                                size: 18, color: AppColors.gold),
                            Text(
                              ' ${package.rating} (${package.reviews})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                                Icons.nights_stay_outlined, package.stayLong),
                            _chip(Icons.category_outlined, package.category),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: AppColors.slate,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Highlights',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        ...package.highlights.map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.teal, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(h)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Includes',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: package.includes
                              .map(
                                (e) => Chip(
                                  label: Text(e),
                                  backgroundColor: AppColors.mist,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.smAll,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(
                  top: BorderSide(color: AppColors.border),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(
                            color: AppColors.slate,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          package.stayShort,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ocean,
                          ),
                        ),
                        Text(
                          package.stayLong,
                          style: const TextStyle(
                            color: AppColors.slate,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _toggleSave,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 18,
                    ),
                    label: Text(isSaved ? 'Saved' : 'Save this trip'),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isSaved ? AppColors.teal : AppColors.ocean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: AppRadii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.ocean),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
