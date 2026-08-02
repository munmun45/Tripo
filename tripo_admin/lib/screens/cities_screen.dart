import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';
import 'city_form_dialog.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await ApiClient.instance.get(ApiConfig.locations, auth: true);
      if (!mounted) return;
      setState(() {
        _countries = ((data['countries'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _states = ((data['states'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
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
        _error = 'Failed to load cities';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _cities;
    return _cities.where((c) {
      final hay =
          '${c['name']} ${c['country_name']} ${c['state_name']} ${c['tagline']}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  Future<void> _openCityForm({Map<String, dynamic>? city}) async {
    if (_countries.isEmpty || _states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add Country and State on their pages first'),
        ),
      );
      return;
    }
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CityFormDialog(
        city: city,
        countries: _countries,
        states: _states,
      ),
    );
    if (payload == null || !mounted) return;
    try {
      final res = await ApiClient.instance.post(
        ApiConfig.citySave,
        body: payload,
        auth: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${res['message'] ?? 'Saved'}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AdminTheme.rose),
      );
    }
  }

  Future<void> _toggle(Map<String, dynamic> c) async {
    final id = (c['id'] as num?)?.toInt();
    if (id == null || _busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      final res = await ApiClient.instance.post(
        ApiConfig.cityToggle,
        body: {'id': id},
        auth: true,
      );
      if (!mounted) return;
      setState(() {
        final i = _cities.indexWhere((e) => e['id'] == id);
        if (i >= 0) _cities[i]['active'] = res['active'] == true;
        _busy.remove(id);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy.remove(id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AdminTheme.rose),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy.remove(id));
    }
  }

  Future<void> _delete(Map<String, dynamic> c) async {
    final id = (c['id'] as num?)?.toInt();
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete city?'),
        content: Text('Remove "${c['name']}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AdminTheme.rose),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ApiClient.instance.post(
        ApiConfig.cityDelete,
        body: {'id': id},
        auth: true,
      );
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AdminTheme.rose),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

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
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cities',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AdminTheme.ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pick country & state from dropdowns (add them on their pages first)',
                            style: TextStyle(color: AdminTheme.slate),
                          ),
                        ],
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AdminTheme.ocean, AdminTheme.teal],
                        ),
                      ),
                      child: FilledButton.icon(
                        onPressed: () => _openCityForm(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'Create city',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Search city / state / country',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
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
                  const SizedBox(height: 8),
                  const Text(
                    'If empty DB, run api/sql/migrate_cities.sql',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          else if (rows.isEmpty)
            const GlassPanel(
              child: Center(child: Text('No cities yet')),
            )
          else
            GlassPanel(
              padding: EdgeInsets.zero,
              radius: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minW =
                      constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: minW),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(2.2),
                          1: FlexColumnWidth(1.3),
                          2: FlexColumnWidth(1.3),
                          3: FlexColumnWidth(1.6),
                          4: FlexColumnWidth(1.2),
                          5: FlexColumnWidth(1.4),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AdminTheme.ocean.withValues(alpha: 0.08),
                              border: Border(
                                bottom: BorderSide(
                                  color: AdminTheme.glassStroke
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            children: const [
                              _Th('City'),
                              _Th('Country'),
                              _Th('State'),
                              _Th('Tagline'),
                              _Th('Status'),
                              _Th('Actions'),
                            ],
                          ),
                          for (var i = 0; i < rows.length; i++)
                            _cityRow(
                              c: rows[i],
                              striped: i.isOdd,
                              busy: _busy.contains(
                                (rows[i]['id'] as num?)?.toInt(),
                              ),
                              onToggle: () => _toggle(rows[i]),
                              onEdit: () => _openCityForm(city: rows[i]),
                              onDelete: () => _delete(rows[i]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

TableRow _cityRow({
  required Map<String, dynamic> c,
  required bool striped,
  required bool busy,
  required VoidCallback onToggle,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final name = '${c['name'] ?? ''}';
  final image = '${c['image_url'] ?? ''}';
  final active = c['active'] != false;

  return TableRow(
    decoration: BoxDecoration(
      color: striped ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
      border: Border(
        bottom: BorderSide(
          color: AdminTheme.glassStroke.withValues(alpha: 0.55),
        ),
      ),
    ),
    children: [
      _Td(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image.isEmpty
                  ? Container(
                      width: 48,
                      height: 48,
                      color: AdminTheme.soft,
                      child: const Icon(Icons.location_city_outlined, size: 20),
                    )
                  : Image.network(
                      image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 48,
                        height: 48,
                        color: AdminTheme.soft,
                        child: const Icon(Icons.broken_image_outlined, size: 20),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      _Td(
        child: Text(
          '${c['country_name'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      _Td(
        child: Text(
          '${c['state_name'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      _Td(
        child: Text(
          '${c['tagline'] ?? ''}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AdminTheme.slate.withValues(alpha: 0.98),
          ),
        ),
      ),
      _Td(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? 'Active' : 'Deactive',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? AdminTheme.teal : AdminTheme.rose,
                fontSize: 12,
              ),
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Switch.adaptive(
                value: active,
                activeTrackColor: AdminTheme.teal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => onToggle(),
              ),
          ],
        ),
      ),
      _Td(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              color: AdminTheme.ocean,
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AdminTheme.rose,
            ),
          ],
        ),
      ),
    ],
  );
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: AdminTheme.ink,
        ),
      ),
    );
  }
}

class _Td extends StatelessWidget {
  final Widget child;
  const _Td({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: child,
    );
  }
}
