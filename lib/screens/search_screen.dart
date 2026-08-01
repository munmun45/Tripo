import 'package:flutter/material.dart';
import '../data/dummy_packages.dart';
import '../models/travel_package.dart';
import '../widgets/package_card.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/pull_refresh.dart';
import 'packages/package_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  late List<TravelPackage> _results;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _results = _filter(widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<TravelPackage> _filter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return DummyPackages.all;
    return DummyPackages.all
        .where(
          (p) =>
              p.title.toLowerCase().contains(query) ||
              p.city.toLowerCase().contains(query) ||
              p.country.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _results = _filter(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 700 ? 3 : 2;

    return PageScaffold(
      title: 'Search',
      subtitle: 'Find packages & cities',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: widget.initialQuery.isEmpty,
              onChanged: (v) => setState(() => _results = _filter(v)),
              decoration: const InputDecoration(
                hintText: 'City, package, category…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: PullRefresh(
              onRefresh: _onRefresh,
              child: _results.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No matches found')),
                      ],
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final p = _results[i];
                        return PackageCard(
                          package: p,
                          compact: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PackageDetailScreen(package: p),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
