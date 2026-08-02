import 'package:flutter/material.dart';

import '../services/admin_auth.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';
import 'cities_screen.dart';
import 'countries_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'packages_screen.dart';
import 'states_screen.dart';
import 'users_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  int _refreshTick = 0;
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

  void _refresh() {
    setState(() => _refreshTick++);
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
          Expanded(
            child: ListView(
              children: [
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
                  icon: Icons.public_outlined,
                  selectedIcon: Icons.public_rounded,
                  label: 'Countries',
                  selected: _index == 2,
                  onTap: () => _go(2),
                ),
                GlassNavTile(
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map_rounded,
                  label: 'States',
                  selected: _index == 3,
                  onTap: () => _go(3),
                ),
                GlassNavTile(
                  icon: Icons.location_city_outlined,
                  selectedIcon: Icons.location_city_rounded,
                  label: 'Cities',
                  selected: _index == 4,
                  onTap: () => _go(4),
                ),
                GlassNavTile(
                  icon: Icons.luggage_outlined,
                  selectedIcon: Icons.luggage_rounded,
                  label: 'Packages',
                  selected: _index == 5,
                  onTap: () => _go(5),
                ),
              ],
            ),
          ),
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
    final pages = [
      DashboardScreen(key: ValueKey('dash-$_refreshTick')),
      UsersScreen(key: ValueKey('users-$_refreshTick')),
      CountriesScreen(key: ValueKey('countries-$_refreshTick')),
      StatesScreen(key: ValueKey('states-$_refreshTick')),
      CitiesScreen(key: ValueKey('cities-$_refreshTick')),
      PackagesScreen(key: ValueKey('pkgs-$_refreshTick')),
    ];
    final titles = [
      'Dashboard',
      'Users',
      'Countries',
      'States',
      'Cities',
      'Packages',
    ];

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
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        color: AdminTheme.ink,
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  radius: 22,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final item in [
                          (0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
                          (1, Icons.people_outline_rounded, Icons.people_rounded, 'Users'),
                          (2, Icons.public_outlined, Icons.public_rounded, 'Country'),
                          (3, Icons.map_outlined, Icons.map_rounded, 'State'),
                          (4, Icons.location_city_outlined, Icons.location_city_rounded, 'City'),
                          (5, Icons.luggage_outlined, Icons.luggage_rounded, 'Package'),
                        ])
                          SizedBox(
                            width: 88,
                            child: GlassNavTile(
                              compact: true,
                              icon: item.$2,
                              selectedIcon: item.$3,
                              label: item.$4,
                              selected: _index == item.$1,
                              onTap: () => setState(() => _index = item.$1),
                            ),
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
