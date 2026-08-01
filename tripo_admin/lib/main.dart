import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'services/admin_auth.dart';
import 'theme/admin_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  final loggedIn = await AdminAuth.instance.restore();
  runApp(TripoAdminApp(loggedIn: loggedIn));
}

class TripoAdminApp extends StatelessWidget {
  final bool loggedIn;

  const TripoAdminApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripo Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light,
      home: loggedIn ? const ShellScreen() : const LoginScreen(),
    );
  }
}
