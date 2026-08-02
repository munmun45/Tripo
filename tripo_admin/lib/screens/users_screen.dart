import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _stats;
  final Set<int> _toggling = {};

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
          ? ApiConfig.users
          : '${ApiConfig.users}?q=${Uri.encodeQueryComponent(q)}';
      final data = await ApiClient.instance.get(url, auth: true);
      Map<String, dynamic>? statsMap;
      try {
        final stats = await ApiClient.instance.get(ApiConfig.stats, auth: true);
        statsMap = (stats['stats'] as Map?)?.cast<String, dynamic>();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _users = ((data['users'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _stats = statsMap;
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
        _error = 'Failed to load users';
        _loading = false;
      });
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> u) async {
    if (u['is_admin'] == true) return;
    final id = (u['id'] as num?)?.toInt();
    if (id == null || _toggling.contains(id)) return;
    setState(() => _toggling.add(id));
    try {
      final res = await ApiClient.instance.post(
        ApiConfig.userToggle,
        body: {'id': id},
        auth: true,
      );
      if (!mounted) return;
      final active = res['is_active'] == true;
      setState(() {
        final i = _users.indexWhere((e) => e['id'] == id);
        if (i >= 0) _users[i]['is_active'] = active;
        _toggling.remove(id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _toggling.remove(id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminTheme.rose,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _toggling.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'All registered users',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AdminTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _stats == null
                      ? 'Search and browse accounts'
                      : '${_stats!['users'] ?? _users.length} total · ${_stats!['admins'] ?? 0} admins',
                  style: TextStyle(
                    color: AdminTheme.slate.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          hintText: 'Search name / phone',
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
                        gradient: const LinearGradient(
                          colors: [AdminTheme.ocean, AdminTheme.teal],
                        ),
                      ),
                      child: FilledButton(
                        onPressed: _load,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
          else if (_users.isEmpty)
            const GlassPanel(
              child: Center(child: Text('No users found')),
            )
          else
            GlassPanel(
              padding: EdgeInsets.zero,
              radius: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableMin = constraints.maxWidth < 700 ? 700.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: tableMin),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(64),
                          1: FlexColumnWidth(2.4),
                          2: FlexColumnWidth(1.6),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.6),
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
                              _Th('ID'),
                              _Th('User'),
                              _Th('Phone'),
                              _Th('Role'),
                              _Th('Status'),
                            ],
                          ),
                          for (var i = 0; i < _users.length; i++)
                            _userRow(
                              u: _users[i],
                              striped: i.isOdd,
                              toggling: _toggling.contains(
                                (_users[i]['id'] as num?)?.toInt(),
                              ),
                              onToggle: () => _toggleActive(_users[i]),
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

TableRow _userRow({
  required Map<String, dynamic> u,
  required bool striped,
  required bool toggling,
  required VoidCallback onToggle,
}) {
  final name = '${u['name'] ?? ''}';
  final phone = '${u['phone'] ?? ''}';
  final admin = u['is_admin'] == true;
  final active = u['is_active'] != false;
  final id = (u['id'] as num?)?.toInt() ?? 0;

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
        child: Text(
          '#$id',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AdminTheme.slate,
          ),
        ),
      ),
      _Td(
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: (active ? AdminTheme.ocean : AdminTheme.slate)
                  .withValues(alpha: 0.16),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: active ? AdminTheme.ocean : AdminTheme.slate,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                name,
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
        child: Text(
          phone,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AdminTheme.slate.withValues(alpha: 0.98),
          ),
        ),
      ),
      _Td(
        child: Align(
          alignment: Alignment.centerLeft,
          child: _Pill(
            label: admin ? 'Admin' : 'User',
            color: admin ? AdminTheme.ocean : AdminTheme.slate,
          ),
        ),
      ),
      _Td(
        child: admin
            ? const Text(
                '—',
                style: TextStyle(
                  color: AdminTheme.slate,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Pill(
                    label: active ? 'Active' : 'Deactive',
                    color: active ? AdminTheme.teal : AdminTheme.rose,
                  ),
                  const SizedBox(width: 8),
                  if (toggling)
                    const SizedBox(
                      width: 22,
                      height: 22,
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
    ],
  );
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
