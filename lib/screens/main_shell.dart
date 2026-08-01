import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/dummy_weather.dart';
import '../services/auth_service.dart';
import '../services/saved_packages_store.dart';
import '../theme/app_theme.dart';
import '../theme/glass.dart';
import '../widgets/app_drawer.dart';
import '../widgets/premium_bottom_nav.dart';
import '../widgets/sticky_top_bar.dart';
import '../widgets/tools_sheet.dart';
import 'auth/login_screen.dart';
import 'docs/docs_screen.dart';
import 'home/home_screen.dart';
import 'legal/help_screen.dart';
import 'map/map_screen.dart';
import 'packages/packages_screen.dart';
import 'profile/profile_screen.dart';
import 'search_screen.dart';
import 'split/split_home_screen.dart';
import 'tools/compass_screen.dart';
import 'tools/currency_screen.dart';
import 'tools/emergency_screen.dart';
import 'tools/notes_screen.dart';
import 'tools/todo_screen.dart';
import 'tools/translate_screen.dart';
import 'tools/world_clock_screen.dart';
import 'weather/weather_detail_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  bool _loggedIn = false;
  bool _authChecked = false;
  String _userName = '';
  String _userPhone = '';

  /// 0 Home · 1 Trips · 2 Map · 3 Split · 4 Docs · 5 Profile
  final List<Widget?> _pages = List<Widget?>.filled(6, null);

  static const _titles = [
    'Tripo',
    'Trips',
    'Map',
    'Split',
    'Docs',
    'Profile',
  ];
  static const _subtitles = [
    'Travel beautifully',
    'Travel beautifully',
    'Travel beautifully',
    'Groups & shared expenses',
    'Upload & store travel files',
    'Travel beautifully',
  ];

  @override
  void initState() {
    super.initState();
    _refreshAuth();
  }

  Future<void> _refreshAuth() async {
    await AuthService.restoreSession();
    final loggedIn = await AuthService.isLoggedIn();
    final user = loggedIn ? await AuthService.currentUser() : null;
    if (!mounted) return;
    setState(() {
      _loggedIn = loggedIn;
      _authChecked = true;
      _userName = user?['name'] ?? '';
      _userPhone = user?['phone'] ?? '';
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    await _refreshAuth();
  }

  Widget _pageAt(int i) {
    return _pages[i] ??= switch (i) {
      0 => const HomeScreen(),
      1 => const PackagesScreen(),
      2 => const MapScreen(),
      3 => const SplitHomeScreen(embedded: true),
      4 => const DocsScreen(standalone: false),
      _ => const ProfileScreen(),
    };
  }

  void _openSearch([String query = '']) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: query),
      ),
    );
  }

  Future<void> _openWeather() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeatherDetailScreen(
          initial: DummyWeather.currentLocationDemo(),
        ),
      ),
    );
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    await _refreshAuth();
  }

  void _openMore() {
    ToolsSheet.show(context, onSelect: _handleTool);
  }

  void _openDocs() {
    setState(() => _index = 4);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleTool(TravelTool tool) {
    switch (tool) {
      case TravelTool.myPackages:
        SavedPackagesStore.instance.requestShowSavedOnly();
        setState(() => _index = 1);
        return;
      case TravelTool.planPackage:
      case TravelTool.createTrip:
        setState(() => _index = 1);
        return;
      case TravelTool.map:
        setState(() => _index = 2);
        return;
      case TravelTool.weather:
        _openWeather();
        return;
      case TravelTool.compass:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CompassScreen()),
        );
        return;
      case TravelTool.splitMoney:
      case TravelTool.expenses:
        setState(() => _index = 3);
        return;
      case TravelTool.emergency:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
        );
        return;
      case TravelTool.documents:
        _openDocs();
        return;
      case TravelTool.tripNotes:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotesScreen()),
        );
        return;
      case TravelTool.todo:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TodoScreen()),
        );
        return;
      case TravelTool.packingList:
        _toast('Packing list — coming soon');
        return;
      case TravelTool.currency:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CurrencyScreen()),
        );
        return;
      case TravelTool.translator:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TranslateScreen()),
        );
        return;
      case TravelTool.trekking:
        _toast('Trekking guides — coming soon');
        return;
      case TravelTool.worldClock:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorldClockScreen()),
        );
        return;
      case TravelTool.flashlight:
        _toast('Flashlight — use phone Quick Settings');
        return;
      case TravelTool.tools:
        return;
    }
  }

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit Tripo?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Do you want to close the app?',
          style: TextStyle(color: AppColors.slate, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ocean,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (ok == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Back from other tabs → Home first.
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }
        await _confirmExit();
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      extendBody: true,
      drawer: AppDrawer(
        currentIndex: _index == 5 ? 3 : (_index > 2 ? 0 : _index),
        loggedIn: _loggedIn,
        userName: _userName,
        userPhone: _userPhone,
        onNavigate: (i) {
          // Drawer: 0 Home, 1 Packages, 2 Map, 3 Profile
          setState(() => _index = i == 3 ? 5 : i);
        },
        onWeather: _openWeather,
        onLogin: _openLogin,
        onLogout: _logout,
        onTools: _openMore,
        onTool: _handleTool,
        onHelp: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
        },
      ),
      body: GlassBackground(
        child: Column(
          children: [
            StickyTopBar(
              title: _titles[_index],
              subtitle: _subtitles[_index],
              profileInitial: _loggedIn && _userName.trim().isNotEmpty
                  ? _userName.trim()[0]
                  : null,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onNotificationTap: _openWeather,
              onSearchTap: () => _openSearch(),
              onProfileTap: () async {
                setState(() => _index = 5);
                await _refreshAuth();
              },
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: List.generate(6, (i) {
                  if (_pages[i] == null && i != _index) {
                    return const SizedBox.shrink();
                  }
                  return _pageAt(i);
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_authChecked && !_loggedIn) _LoginPromptBanner(onLogin: _openLogin),
          PremiumBottomNav(
            currentIndex: _index <= 4 ? _index : -1,
            onTap: (i) async {
              setState(() => _index = i);
              await _refreshAuth();
            },
            onMoreTap: _openMore,
          ),
        ],
      ),
    ),
    );
  }
}

class _LoginPromptBanner extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoginPromptBanner({required this.onLogin});

  static const _red = Color(0xFFE23D4A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _red,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.login_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: const Text(
                      'Please sign in to sync and save your data to the cloud',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: onLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
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
