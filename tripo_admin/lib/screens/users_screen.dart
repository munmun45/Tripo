import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final id = u['id'] as int?;
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

  String _daysLabel(int days) {
    if (days <= 1) return '1 day';
    return '$days days';
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final wide = MediaQuery.sizeOf(context).width >= 820;

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
            ..._users.map((u) {
              final name = '${u['name'] ?? ''}';
              final phone = '${u['phone'] ?? ''}';
              final admin = u['is_admin'] == true;
              final active = u['is_active'] != false;
              final days = (u['days_on_app'] as num?)?.toInt() ?? 0;
              final id = (u['id'] as num?)?.toInt();
              DateTime? created;
              try {
                created = DateTime.parse('${u['created_at']}');
              } catch (_) {}
              final joinText =
                  created == null ? '—' : df.format(created.toLocal());

              return GlassPanel(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                radius: 18,
                child: wide
                    ? Row(
                        children: [
                          _Avatar(name: name, active: active),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (admin) ...[
                                      const SizedBox(width: 8),
                                      const _Pill(
                                        label: 'Admin',
                                        color: AdminTheme.ocean,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    color: AdminTheme.slate
                                        .withValues(alpha: 0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _InfoCol(
                              label: 'Join date',
                              value: joinText,
                              icon: Icons.event_rounded,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _InfoCol(
                              label: 'On app',
                              value: _daysLabel(days),
                              icon: Icons.timelapse_rounded,
                            ),
                          ),
                          _StatusToggle(
                            active: active,
                            loading: id != null && _toggling.contains(id),
                            onChanged: () => _toggleActive(u),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Avatar(name: name, active: active),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        color: AdminTheme.slate
                                            .withValues(alpha: 0.95),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (admin)
                                const _Pill(
                                  label: 'Admin',
                                  color: AdminTheme.ocean,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCol(
                                  label: 'Join date',
                                  value: joinText,
                                  icon: Icons.event_rounded,
                                ),
                              ),
                              Expanded(
                                child: _InfoCol(
                                  label: 'On app',
                                  value: _daysLabel(days),
                                  icon: Icons.timelapse_rounded,
                                ),
                              ),
                              _StatusToggle(
                                active: active,
                                loading: id != null && _toggling.contains(id),
                                onChanged: () => _toggleActive(u),
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            }),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final bool active;

  const _Avatar({required this.name, required this.active});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: (active ? AdminTheme.ocean : AdminTheme.slate)
          .withValues(alpha: 0.16),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: active ? AdminTheme.ocean : AdminTheme.slate,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCol({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminTheme.slate),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AdminTheme.slate.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AdminTheme.ink,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final bool active;
  final bool loading;
  final VoidCallback onChanged;

  const _StatusToggle({
    required this.active,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Pill(
          label: active ? 'Active' : 'Deactive',
          color: active ? AdminTheme.teal : AdminTheme.rose,
        ),
        const SizedBox(height: 4),
        if (loading)
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
            onChanged: (_) => onChanged(),
          ),
      ],
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
