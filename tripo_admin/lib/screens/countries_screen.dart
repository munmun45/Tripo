import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _countries = [];

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
          await ApiClient.instance.get(ApiConfig.locations, auth: true);
      if (!mounted) return;
      setState(() {
        _countries = ((data['countries'] as List?) ?? [])
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
        _error = 'Failed to load countries';
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Add country',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Country name',
            hintText: 'e.g. India',
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AdminTheme.ocean),
            child: const Text('Add country'),
          ),
        ],
      ),
    );
    final name = ctrl.text.trim();
    ctrl.dispose();
    if (ok != true || name.isEmpty || !mounted) return;
    try {
      await ApiClient.instance.post(
        ApiConfig.countrySave,
        body: {'name': name},
        auth: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Country added'),
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

  Future<void> _delete(Map<String, dynamic> c) async {
    final id = (c['id'] as num?)?.toInt();
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete country?'),
        content: Text(
          'Remove "${c['name']}"?\nStates and cities under it will also be deleted.',
        ),
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
        ApiConfig.countryDelete,
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
    return RefreshIndicator(
      color: AdminTheme.ocean,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          GlassPanel(
            radius: 22,
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Countries',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: AdminTheme.ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add countries separately — used in State & City dropdowns',
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
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add country',
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
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
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
          else if (_countries.isEmpty)
            const GlassPanel(child: Center(child: Text('No countries yet')))
          else
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _countries.length; i++)
                    ListTile(
                      tileColor: i.isOdd
                          ? Colors.white.withValues(alpha: 0.18)
                          : null,
                      leading: CircleAvatar(
                        backgroundColor:
                            AdminTheme.ocean.withValues(alpha: 0.12),
                        child: Text(
                          '${_countries[i]['name']}'.isNotEmpty
                              ? '${_countries[i]['name']}'[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AdminTheme.ocean,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        '${_countries[i]['name']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('ID #${_countries[i]['id']}'),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _delete(_countries[i]),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: AdminTheme.rose,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
