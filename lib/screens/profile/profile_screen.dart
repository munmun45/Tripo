import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/pull_refresh.dart';
import '../../widgets/skeletons/skeleton.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  bool _loggedIn = false;
  String _name = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool showSkeleton = true}) async {
    if (!mounted) return;
    if (showSkeleton) setState(() => _loading = true);
    try {
      final user = await AuthService.currentUser()
          .timeout(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _loggedIn = user != null;
        _name = user?['name'] ?? '';
        _phone = user?['phone'] ?? '';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() => _load(showSkeleton: false);

  Future<void> _openLogin() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (ok == true) _load();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSkeleton();
    }

    return PullRefresh(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: Glass.panel(radius: 18, opacity: 0.88),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.mist,
                  child: Icon(
                    _loggedIn ? Icons.person_rounded : Icons.person_outline,
                    size: 34,
                    color: AppColors.ocean,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loggedIn ? _name : 'Guest traveler',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _loggedIn
                            ? (_phone.isEmpty ? 'Signed in' : _phone)
                            : 'App is open without login',
                        style: const TextStyle(color: AppColors.slate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_loggedIn)
            ElevatedButton(
              onPressed: _openLogin,
              child: const Text('Login / Sign up'),
            )
          else
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coral,
                side: const BorderSide(color: AppColors.coral),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          const SizedBox(height: 28),
          const Text(
            'Preferences',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _tile(Icons.bookmark_border_rounded, 'Saved packages',
              'Coming with database'),
          _tile(Icons.history_rounded, 'Booking history',
              'Coming with database'),
          _tile(Icons.notifications_none_rounded, 'Alerts',
              'Weather & trip reminders'),
          _tile(Icons.info_outline_rounded, 'About Tripo',
              'Premium travel demo v1.0'),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: Glass.panel(radius: 14, opacity: 0.86),
      child: ListTile(
        leading: Icon(icon, color: AppColors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title — demo placeholder'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
