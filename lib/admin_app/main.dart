import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Windows / desktop admin panel entry:
/// flutter run -d windows -t lib/admin_app/main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TripoAdminApp());
}

class TripoAdminApp extends StatelessWidget {
  const TripoAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripo Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.ocean,
          primary: AppColors.ocean,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const _AdminGate(),
    );
  }
}

class _AdminGate extends StatefulWidget {
  const _AdminGate();

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await AuthService.restoreSession();
    final loggedIn = await AuthService.isLoggedIn();
    var ok = false;
    if (loggedIn) {
      ok = await AuthService.isAdmin();
      // Do not wipe the mobile session if this account is not admin.
      if (!ok) {
        // Stay on login screen for admin app only.
      }
    }
    if (!mounted) return;
    setState(() {
      _authed = ok;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_authed) {
      return AdminLoginPage(onSuccess: () => setState(() => _authed = true));
    }
    return AdminShell(onLogout: () async {
      await AuthService.logout();
      if (!mounted) return;
      setState(() => _authed = false);
    });
  }
}

class AdminLoginPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const AdminLoginPage({super.key, required this.onSuccess});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AuthService.login(
      phone: _phone.text,
      password: _password.text,
    );
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }
    try {
      final me = await ApiClient.instance.get(ApiConfig.me, auth: true);
      final user = me['user'] as Map<String, dynamic>?;
      if (user?['is_admin'] != true) {
        // Do NOT logout — keep mobile app session on same device.
        setState(() {
          _loading = false;
          _error = 'This account is not an admin';
        });
        return;
      }
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tripo Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Windows panel · phone + password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Admin phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _login(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ocean,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  final Future<void> Function() onLogout;

  const AdminShell({super.key, required this.onLogout});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _users = [];
  bool _busy = false;
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final statsRes =
          await ApiClient.instance.get(ApiConfig.adminStats, auth: true);
      final usersUrl = _query.trim().isEmpty
          ? ApiConfig.adminUsers
          : '${ApiConfig.adminUsers}?q=${Uri.encodeQueryComponent(_query.trim())}';
      final usersRes = await ApiClient.instance.get(usersUrl, auth: true);
      if (!mounted) return;
      setState(() {
        _stats = (statsRes['stats'] as Map?)?.cast<String, dynamic>();
        _users = ((usersRes['users'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final id = user['id'];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Remove ${user['name']} (${user['phone']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiClient.instance.post(
        ApiConfig.adminUserDelete,
        auth: true,
        body: {'id': id},
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: AppColors.ocean, size: 28),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('Users'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    tooltip: 'Logout',
                    onPressed: () => widget.onLogout(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Text(
                          _index == 0 ? 'Dashboard' : 'Users',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (_index == 1)
                          SizedBox(
                            width: 260,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search name / phone',
                                isDense: true,
                                prefixIcon: Icon(Icons.search, size: 20),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) => _query = v,
                              onSubmitted: (_) => _refresh(),
                            ),
                          ),
                        const SizedBox(width: 10),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: _busy ? null : _refresh,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                if (_error != null)
                  Material(
                    color: const Color(0xFFFFEBEE),
                    child: ListTile(
                      dense: true,
                      title: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                Expanded(
                  child: _busy && _stats == null && _users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : (_index == 0 ? _dashboard() : _usersTable()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final s = _stats ?? {};
    final cards = [
      ('Users', '${s['users'] ?? 0}', Icons.people_rounded, AppColors.ocean),
      ('Admins', '${s['admins'] ?? 0}', Icons.shield_rounded, const Color(0xFF7B1FA2)),
      ('Saved packages', '${s['saved_packages'] ?? 0}', Icons.bookmark_rounded,
          const Color(0xFFE06B1F)),
      ('Notes', '${s['notes'] ?? 0}', Icons.sticky_note_2_rounded,
          const Color(0xFFE6A100)),
      ('Active sessions', '${s['active_sessions'] ?? 0}', Icons.vpn_key_rounded,
          const Color(0xFF2E7D32)),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(c.$3, color: c.$4, size: 26),
                const Spacer(),
                Text(
                  c.$2,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  c.$1,
                  style: const TextStyle(color: AppColors.slate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _usersTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              AppColors.softSky.withValues(alpha: 0.55),
            ),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Joined')),
              DataColumn(label: Text('')),
            ],
            rows: [
              for (final u in _users)
                DataRow(
                  cells: [
                    DataCell(Text('${u['id']}')),
                    DataCell(Text('${u['name'] ?? ''}')),
                    DataCell(Text('${u['phone'] ?? ''}')),
                    DataCell(
                      Text(
                        u['is_admin'] == true ? 'Admin' : 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: u['is_admin'] == true
                              ? AppColors.ocean
                              : AppColors.slate,
                        ),
                      ),
                    ),
                    DataCell(Text('${u['created_at'] ?? ''}')),
                    DataCell(
                      u['is_admin'] == true
                          ? const SizedBox.shrink()
                          : IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _deleteUser(u),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
