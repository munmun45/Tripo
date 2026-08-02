import 'package:flutter/material.dart';

import '../services/admin_auth.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'packages_screen.dart';
import 'users_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _logout() async {
    await AdminAuth.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _go(int i) {
    setState(() => _index = i);
    Navigator.of(context).maybePop();
  }

  Widget _sidebar({required bool compactDrawer}) {
    final name = AdminAuth.instance.name.isEmpty
        ? 'Admin'
        : AdminAuth.instance.name;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 12),
      radius: compactDrawer ? 0 : 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compactDrawer)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AdminTheme.ocean, AdminTheme.teal],
                      ),
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tripo Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AdminTheme.ink,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            color: AdminTheme.slate,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          GlassNavTile(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
            selected: _index == 0,
            onTap: () => _go(0),
          ),
          GlassNavTile(
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
            label: 'Users',
            selected: _index == 1,
            onTap: () => _go(1),
          ),
          GlassNavTile(
            icon: Icons.luggage_outlined,
            selectedIcon: Icons.luggage_rounded,
            label: 'Packages',
            selected: _index == 2,
            onTap: () => _go(2),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdminTheme.slate.withValues(alpha: 0.9),
              ),
            ),
          ),
          GlassNavTile(
            icon: Icons.logout_rounded,
            selectedIcon: Icons.logout_rounded,
            label: 'Logout',
            selected: false,
            onTap: _logout,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final pages = const [
      DashboardScreen(),
      UsersScreen(),
      PackagesScreen(),
    ];
    final titles = ['Dashboard', 'Users', 'Packages'];

    return GlassBackground(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: wide
            ? null
            : Drawer(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: GlassBackground(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _sidebar(compactDrawer: true),
                    ),
                  ),
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: GlassPanel(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  radius: 20,
                  child: Row(
                    children: [
                      if (!wide)
                        IconButton(
                          tooltip: 'Menu',
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                          icon: const Icon(Icons.menu_rounded),
                          color: AdminTheme.ink,
                        ),
                      if (!wide) const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [AdminTheme.ocean, AdminTheme.teal],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AdminTheme.ocean.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tripo Admin',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: AdminTheme.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              titles[_index],
                              style: TextStyle(
                                color: AdminTheme.slate.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AdminTheme.glassStroke),
                        ),
                        child: Text(
                          AdminAuth.instance.name.isEmpty
                              ? 'Admin'
                              : AdminAuth.instance.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.ink,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 14),
                            child: SizedBox(
                              width: 210,
                              child: _sidebar(compactDrawer: false),
                            ),
                          ),
                          Expanded(child: pages[_index]),
                        ],
                      )
                    : pages[_index],
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  radius: 22,
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassNavTile(
                          compact: true,
                          icon: Icons.dashboard_outlined,
                          selectedIcon: Icons.dashboard_rounded,
                          label: 'Dashboard',
                          selected: _index == 0,
                          onTap: () => setState(() => _index = 0),
                        ),
                      ),
                      Expanded(
                        child: GlassNavTile(
                          compact: true,
                          icon: Icons.people_outline_rounded,
                          selectedIcon: Icons.people_rounded,
                          label: 'Users',
                          selected: _index == 1,
                          onTap: () => setState(() => _index = 1),
                        ),
                      ),
                      Expanded(
                        child: GlassNavTile(
                          compact: true,
                          icon: Icons.luggage_outlined,
                          selectedIcon: Icons.luggage_rounded,
                          label: 'Packages',
                          selected: _index == 2,
                          onTap: () => setState(() => _index = 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
