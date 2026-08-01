import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';

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
      final stats = await ApiClient.instance.get(ApiConfig.stats, auth: true);
      if (!mounted) return;
      setState(() {
        _users = ((data['users'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _stats = (stats['stats'] as Map?)?.cast<String, dynamic>();
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

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_stats != null)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatChip(label: 'Users', value: '${_stats!['users'] ?? 0}'),
                _StatChip(label: 'Admins', value: '${_stats!['admins'] ?? 0}'),
                _StatChip(
                    label: 'Packages', value: '${_stats!['packages'] ?? 0}'),
                _StatChip(label: 'Cities', value: '${_stats!['cities'] ?? 0}'),
              ],
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
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: AdminTheme.ocean,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          else if (_users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No users found')),
            )
          else
            ..._users.map((u) {
              final name = '${u['name'] ?? ''}';
              final phone = '${u['phone'] ?? ''}';
              final admin = u['is_admin'] == true;
              DateTime? created;
              try {
                created = DateTime.parse('${u['created_at']}');
              } catch (_) {}
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AdminTheme.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AdminTheme.ocean,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    [
                      phone,
                      if (created != null) 'Joined ${df.format(created)}',
                    ].join(' · '),
                  ),
                  trailing: admin
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTheme.ocean.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: AdminTheme.ocean,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : Text(
                          '#${u['id']}',
                          style: const TextStyle(color: AdminTheme.slate),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AdminTheme.slate, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AdminTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
