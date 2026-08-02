import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cities = [];
  String? _filterCity;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await ApiClient.instance.get(ApiConfig.packages, auth: true);
      if (!mounted) return;
      setState(() {
        _cities = ((data['cities'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load packages';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final cities = _filterCity == null
        ? _cities
        : _cities.where((c) => c['city'] == _filterCity).toList();

    return RefreshIndicator(
      color: AdminTheme.ocean,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          GlassPanel(
            radius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travel packages',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AdminTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catalog grouped city-wise',
                  style: TextStyle(
                    color: AdminTheme.slate.withValues(alpha: 0.95),
                  ),
                ),
                if (!_loading && _cities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All cities'),
                            selected: _filterCity == null,
                            onSelected: (_) =>
                                setState(() => _filterCity = null),
                          ),
                        ),
                        ..._cities.map((c) {
                          final city = '${c['city']}';
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('$city (${c['count']})'),
                              selected: _filterCity == city,
                              onSelected: (_) =>
                                  setState(() => _filterCity = city),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: AdminTheme.ocean),
              ),
            )
          else if (_error != null)
            GlassPanel(
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(color: AdminTheme.rose)),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          else if (cities.isEmpty)
            const GlassPanel(
              child: Center(
                child: Text(
                  'No packages yet.\nImport api/sql/migrate_admin.sql on the server.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...cities.map((cityBlock) {
              final city = '${cityBlock['city']}';
              final country = '${cityBlock['country']}';
              final packages = ((cityBlock['packages'] as List?) ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();

              return GlassPanel(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                radius: 20,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded:
                        _filterCity != null || cities.length <= 3,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    title: Text(
                      city,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '$country · ${packages.length} package${packages.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: AdminTheme.slate.withValues(alpha: 0.95),
                      ),
                    ),
                    children: packages.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AdminTheme.glassStroke),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '${p['image_url']}',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 64,
                                  height: 64,
                                  color: AdminTheme.soft,
                                  child: const Icon(Icons.image_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p['title']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p['category']} · ${p['duration_days']}D · ★ ${p['rating']}',
                                    style: TextStyle(
                                      color: AdminTheme.slate
                                          .withValues(alpha: 0.95),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              money.format((p['price'] as num?) ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AdminTheme.ocean,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
