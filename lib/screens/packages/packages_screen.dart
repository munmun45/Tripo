import 'package:flutter/material.dart';
import '../../data/dummy_packages.dart';
import '../../models/travel_package.dart';
import '../../services/saved_packages_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/package_card.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/pull_refresh.dart';
import 'package_detail_screen.dart';

class PackagesScreen extends StatefulWidget {
  final bool standalone;

  const PackagesScreen({super.key, this.standalone = false});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _saved = SavedPackagesStore.instance;

  static const _categories = [
    'All',
    'Romantic',
    'Culture',
    'Wellness',
    'Adventure',
    'Luxury',
    'Beach',
    'Mountain',
  ];

  String _category = 'All';
  double _minRating = 0;
  String _duration = 'Any'; // Any | Short | Mid | Long
  bool _showSavedOnly = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _saved.addListener(_onSavedChange);
    if (_saved.consumeShowSavedOnly()) {
      _showSavedOnly = true;
    }
    _saved.load();
  }

  @override
  void dispose() {
    _saved.removeListener(_onSavedChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSavedChange() {
    if (!mounted) return;
    var showSaved = false;
    if (_saved.consumeShowSavedOnly()) {
      showSaved = true;
    }
    setState(() {
      if (showSaved) _showSavedOnly = true;
    });
  }

  List<TravelPackage> get _filtered {
    final q = _query.trim().toLowerCase();
    final source = _showSavedOnly ? _saved.packages : DummyPackages.all;
    return source.where((p) {
      if (_category != 'All' && p.category != _category) return false;
      if (p.rating < _minRating) return false;
      if (_duration == 'Short' && p.durationDays > 4) return false;
      if (_duration == 'Mid' && (p.durationDays < 5 || p.durationDays > 7)) {
        return false;
      }
      if (_duration == 'Long' && p.durationDays < 8) return false;
      if (q.isNotEmpty) {
        final hay =
            '${p.title} ${p.city} ${p.country} ${p.category}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _category != 'All' || _minRating > 0 || _duration != 'Any';

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<_TripFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _TripFilterSheet(
        category: _category,
        minRating: _minRating,
        duration: _duration,
        categories: _categories,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _category = result.category;
      _minRating = result.minRating;
      _duration = result.duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 700 ? 3 : 2;
    final packages = _filtered;

    final grid = Expanded(
      child: PullRefresh(
        onRefresh: _onRefresh,
        child: packages.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.travel_explore_rounded,
                    size: 48,
                    color: AppColors.slate.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showSavedOnly
                        ? 'No saved packages yet'
                        : 'No trips match your filters',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _category = 'All';
                          _minRating = 0;
                          _duration = 'Any';
                          _showSavedOnly = false;
                          _query = '';
                          _searchCtrl.clear();
                        });
                      },
                      child: Text(
                        _showSavedOnly ? 'Show all trips' : 'Clear filters',
                      ),
                    ),
                  ),
                ],
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: packages.length,
                itemBuilder: (context, i) {
                  final p = packages[i];
                  return PackageCard(
                    package: p,
                    compact: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PackageDetailScreen(package: p),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );

    final content = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.softSky, AppColors.softBg, AppColors.white],
          stops: [0, 0.18, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search trips',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                      filled: true,
                      fillColor: AppColors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.95),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.95),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: AppColors.ocean,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _IconActionButton(
                  icon: _showSavedOnly
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  active: _showSavedOnly,
                  badge: '${_saved.count}',
                  tooltip: 'Saved packages',
                  onTap: () {
                    setState(() => _showSavedOnly = !_showSavedOnly);
                  },
                ),
                const SizedBox(width: 8),
                _HeaderActionChip(
                  icon: Icons.tune_rounded,
                  label: 'Filter',
                  active: _hasActiveFilter,
                  onTap: _openFilter,
                ),
              ],
            ),
          ),
          if (_hasActiveFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                '${packages.length} trip${packages.length == 1 ? '' : 's'} · '
                '${_category == 'All' ? 'All categories' : _category}'
                '${_duration != 'Any' ? ' · $_duration' : ''}'
                '${_minRating > 0 ? ' · ${_minRating.toStringAsFixed(1)}+' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          grid,
        ],
      ),
    );

    if (widget.standalone) {
      return PageScaffold(
        title: 'Packages',
        subtitle: 'Curated city escapes',
        body: content,
      );
    }
    return content;
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String? badge;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.ocean;
    final bg = active ? AppColors.ocean : AppColors.white;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? AppColors.ocean
                    : AppColors.border.withValues(alpha: 0.95),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.ocean.withValues(alpha: active ? 0.16 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                if (badge != null)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : AppColors.ocean,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: active ? AppColors.ocean : Colors.white,
                          height: 1,
                        ),
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

class _HeaderActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback onTap;

  const _HeaderActionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.ocean;
    final bg = active ? AppColors.ocean : AppColors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? AppColors.ocean
                  : AppColors.border.withValues(alpha: 0.95),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ocean.withValues(alpha: active ? 0.18 : 0.06),
                blurRadius: active ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: fg,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.22)
                        : AppColors.softSky,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TripFilterResult {
  final String category;
  final double minRating;
  final String duration;

  const _TripFilterResult({
    required this.category,
    required this.minRating,
    required this.duration,
  });
}

class _TripFilterSheet extends StatefulWidget {
  final String category;
  final double minRating;
  final String duration;
  final List<String> categories;

  const _TripFilterSheet({
    required this.category,
    required this.minRating,
    required this.duration,
    required this.categories,
  });

  @override
  State<_TripFilterSheet> createState() => _TripFilterSheetState();
}

class _TripFilterSheetState extends State<_TripFilterSheet> {
  late String _category = widget.category;
  late double _minRating = widget.minRating;
  late String _duration = widget.duration;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.ocean),
              SizedBox(width: 8),
              Text(
                'Filter trips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((c) {
              final on = _category == c;
              return ChoiceChip(
                label: Text(c),
                selected: on,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: AppColors.teal,
                labelStyle: TextStyle(
                  color: on ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                backgroundColor: AppColors.softBg,
                side: BorderSide(
                  color: on ? AppColors.teal : AppColors.border,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Duration',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Any', 'Short', 'Mid', 'Long'].map((d) {
              final label = switch (d) {
                'Short' => 'Short (≤4D)',
                'Mid' => 'Mid (5–7D)',
                'Long' => 'Long (8D+)',
                _ => 'Any',
              };
              final on = _duration == d;
              return ChoiceChip(
                label: Text(label),
                selected: on,
                onSelected: (_) => setState(() => _duration = d),
                selectedColor: AppColors.teal,
                labelStyle: TextStyle(
                  color: on ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                backgroundColor: AppColors.softBg,
                side: BorderSide(
                  color: on ? AppColors.teal : AppColors.border,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Min rating',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const Spacer(),
              Text(
                _minRating <= 0
                    ? 'Any'
                    : '${_minRating.toStringAsFixed(1)}+',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppColors.teal,
            label: _minRating <= 0
                ? 'Any'
                : '${_minRating.toStringAsFixed(1)}+',
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _category = 'All';
                      _minRating = 0;
                      _duration = 'Any';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ocean,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _TripFilterResult(
                        category: _category,
                        minRating: _minRating,
                        duration: _duration,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
