import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';
import 'package_form_dialog.dart';
import 'package_view_dialog.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _packages = [];
  final Set<String> _busy = {};

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
      final q = _search.text.trim();
      final url = q.isEmpty
          ? ApiConfig.packages
          : '${ApiConfig.packages}?q=${Uri.encodeQueryComponent(q)}';
      final data = await ApiClient.instance.get(url, auth: true);
      if (!mounted) return;
      setState(() {
        _packages = ((data['packages'] as List?) ?? [])
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

  Future<void> _view(Map<String, dynamic> package) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PackageViewDialog(package: package),
    );
  }

  Future<void> _openForm({Map<String, dynamic>? package}) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PackageFormDialog(package: package),
    );
    if (payload == null || !mounted) return;
    try {
      final res = await ApiClient.instance.post(
        ApiConfig.packageSave,
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
        SnackBar(
          content: Text(e.message),
          backgroundColor: AdminTheme.rose,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggle(Map<String, dynamic> p) async {
    final id = '${p['id']}';
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      final res = await ApiClient.instance.post(
        ApiConfig.packageToggle,
        body: {'id': id},
        auth: true,
      );
      if (!mounted) return;
      setState(() {
        final i = _packages.indexWhere((e) => '${e['id']}' == id);
        if (i >= 0) _packages[i]['active'] = res['active'] == true;
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

  Future<void> _delete(Map<String, dynamic> p) async {
    final id = '${p['id']}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete package?'),
        content: Text('Remove "${p['title']}" permanently?'),
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
        ApiConfig.packageDelete,
        body: {'id': id},
        auth: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package deleted'),
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

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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
                            'Travel packages',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AdminTheme.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage catalog · city dropdown from app destinations',
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
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'Create new',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          hintText: 'Search title / city / category',
                          prefixIcon: Icon(Icons.search_rounded),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _load(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AdminTheme.glassStroke),
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      child: FilledButton(
                        onPressed: _load,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AdminTheme.ink,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
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
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          else if (_packages.isEmpty)
            const GlassPanel(
              child: Center(child: Text('No packages found')),
            )
          else
            GlassPanel(
              padding: EdgeInsets.zero,
              radius: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minW =
                      constraints.maxWidth < 980 ? 980.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: minW),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(2.6),
                          1: FlexColumnWidth(1.3),
                          2: FlexColumnWidth(1.1),
                          3: FlexColumnWidth(1.0),
                          4: FlexColumnWidth(1.0),
                          5: FlexColumnWidth(1.3),
                          6: FlexColumnWidth(1.9),
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
                              _Th('Package'),
                              _Th('City'),
                              _Th('Category'),
                              _Th('Days'),
                              _Th('Avg budget/head'),
                              _Th('Status'),
                              _Th('Actions'),
                            ],
                          ),
                          for (var i = 0; i < _packages.length; i++)
                            _pkgRow(
                              p: _packages[i],
                              money: money,
                              striped: i.isOdd,
                              busy: _busy.contains('${_packages[i]['id']}'),
                              onToggle: () => _toggle(_packages[i]),
                              onView: () => _view(_packages[i]),
                              onEdit: () => _openForm(package: _packages[i]),
                              onDelete: () => _delete(_packages[i]),
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

TableRow _pkgRow({
  required Map<String, dynamic> p,
  required NumberFormat money,
  required bool striped,
  required bool busy,
  required VoidCallback onToggle,
  required VoidCallback onView,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final title = '${p['title'] ?? ''}';
  final city = '${p['city'] ?? ''}';
  final country = '${p['country'] ?? ''}';
  final category = '${p['category'] ?? ''}';
  final days = (p['duration_days'] as num?)?.toInt() ?? 0;
  final price = (p['price'] as num?)?.toDouble() ?? 0;
  final active = p['active'] != false;
  final image = '${p['image_url'] ?? ''}';

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
                      child: const Icon(Icons.image_outlined, size: 20),
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
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AdminTheme.ink,
                ),
              ),
            ),
          ],
        ),
      ),
      _Td(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(
              country,
              style: TextStyle(
                fontSize: 12,
                color: AdminTheme.slate.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
      _Td(
        child: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      _Td(
        child: Text(
          '${days}D',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      _Td(
        child: Text(
          money.format(price),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AdminTheme.ocean,
          ),
        ),
      ),
      _Td(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (active ? AdminTheme.teal : AdminTheme.rose)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: (active ? AdminTheme.teal : AdminTheme.rose)
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                active ? 'Active' : 'Deactive',
                style: TextStyle(
                  color: active ? AdminTheme.teal : AdminTheme.rose,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (busy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch.adaptive(
                value: active,
                activeThumbColor: Colors.white,
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
              tooltip: 'View',
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined),
              color: AdminTheme.teal,
            ),
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
          letterSpacing: 0.3,
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
