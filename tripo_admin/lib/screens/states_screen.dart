import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';

class StatesScreen extends StatefulWidget {
  const StatesScreen({super.key});

  @override
  State<StatesScreen> createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];

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
        _states = ((data['states'] as List?) ?? [])
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
        _error = 'Failed to load states';
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    if (_countries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a country first (Countries page)')),
      );
      return;
    }
    final nameCtrl = TextEditingController();
    int? countryId = (_countries.first['id'] as num?)?.toInt();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add state',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Country *',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: countryId,
                decoration: const InputDecoration(hintText: 'Select country'),
                items: _countries
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num).toInt(),
                        child: Text('${c['name']}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setLocal(() => countryId = v),
              ),
              const SizedBox(height: 14),
              const Text(
                'State name *',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Maharashtra',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AdminTheme.ocean),
              child: const Text('Add state'),
            ),
          ],
        ),
      ),
    );
    final name = nameCtrl.text.trim();
    nameCtrl.dispose();
    if (ok != true || name.isEmpty || countryId == null || !mounted) return;
    try {
      await ApiClient.instance.post(
        ApiConfig.stateSave,
        body: {'name': name, 'country_id': countryId},
        auth: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('State added'),
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

  Future<void> _delete(Map<String, dynamic> s) async {
    final id = (s['id'] as num?)?.toInt();
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete state?'),
        content: Text(
          'Remove "${s['name']}"?\nCities under this state will also be deleted.',
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
        ApiConfig.stateDelete,
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
                        'States',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: AdminTheme.ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add states separately — pick country from dropdown',
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
                      'Add state',
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
          else if (_states.isEmpty)
            const GlassPanel(child: Center(child: Text('No states yet')))
          else
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _states.length; i++)
                    ListTile(
                      tileColor: i.isOdd
                          ? Colors.white.withValues(alpha: 0.18)
                          : null,
                      leading: CircleAvatar(
                        backgroundColor:
                            AdminTheme.teal.withValues(alpha: 0.14),
                        child: const Icon(
                          Icons.map_outlined,
                          color: AdminTheme.teal,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '${_states[i]['name']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        'Country: ${_states[i]['country_name'] ?? ''}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _delete(_states[i]),
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
