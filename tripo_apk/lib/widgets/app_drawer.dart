import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/app_policies.dart';
import '../screens/legal/policy_screen.dart';
import '../theme/app_theme.dart';
import '../theme/glass.dart';
import 'tools_sheet.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback? onWeather;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  final VoidCallback? onTools;
  final VoidCallback? onHelp;
  final ValueChanged<TravelTool>? onTool;
  final bool loggedIn;
  final String userName;
  final String userPhone;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.onWeather,
    this.onLogin,
    this.onLogout,
    this.onTools,
    this.onHelp,
    this.onTool,
    this.loggedIn = false,
    this.userName = '',
    this.userPhone = '',
  });

  void _openPolicy(BuildContext context, AppPolicy policy) {
    Navigator.pop(context);
    PolicyScreen.open(context, policy);
  }

  void _openAllPolicies(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PoliciesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  AppColors.glassTint.withValues(alpha: 0.88),
                  AppColors.softMint.withValues(alpha: 0.55),
                ],
              ),
              border: Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.95),
                                AppColors.softSky,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            boxShadow: Glass.softShadow,
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppColors.ocean,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tripo',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Travel companion',
                                style: TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context);
                          if (loggedIn) {
                            onNavigate(3);
                          } else {
                            onLogin?.call();
                          }
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.9),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: loggedIn
                                      ? AppColors.ocean
                                      : AppColors.softSky,
                                ),
                                child: loggedIn && userName.trim().isNotEmpty
                                    ? Text(
                                        userName.trim()[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      )
                                    : Icon(
                                        loggedIn
                                            ? Icons.person_rounded
                                            : Icons.person_outline_rounded,
                                        color: loggedIn
                                            ? Colors.white
                                            : AppColors.ocean,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loggedIn
                                          ? (userName.trim().isEmpty
                                              ? 'Traveler'
                                              : userName.trim())
                                          : 'Guest traveler',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      loggedIn
                                          ? (userPhone.trim().isEmpty
                                              ? 'View profile'
                                              : userPhone.trim())
                                          : 'Tap to sign in',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.slate,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                loggedIn
                                    ? Icons.chevron_right_rounded
                                    : Icons.login_rounded,
                                color: AppColors.slate,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      children: [
                        const _SectionLabel('Navigate'),
                        _NavItem(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          selected: currentIndex == 0,
                          onTap: () {
                            Navigator.pop(context);
                            onNavigate(0);
                          },
                        ),
                        _NavItem(
                          icon: Icons.explore_rounded,
                          label: 'Packages',
                          selected: currentIndex == 1,
                          onTap: () {
                            Navigator.pop(context);
                            onNavigate(1);
                          },
                        ),
                        _NavItem(
                          icon: Icons.map_rounded,
                          label: 'Map',
                          selected: currentIndex == 2,
                          onTap: () {
                            Navigator.pop(context);
                            onNavigate(2);
                          },
                        ),
                        _NavItem(
                          icon: Icons.person_rounded,
                          label: 'Profile',
                          selected: currentIndex == 3,
                          onTap: () {
                            Navigator.pop(context);
                            onNavigate(3);
                          },
                        ),
                        const SizedBox(height: 8),
                        const _SectionLabel('Tools'),
                        ...TravelTools.all.map(
                          (t) => _NavItem(
                            icon: t.icon,
                            label: t.label,
                            selected: false,
                            dense: true,
                            onTap: () {
                              Navigator.pop(context);
                              onTool?.call(t.tool);
                            },
                          ),
                        ),
                        _NavItem(
                          icon: Icons.apps_rounded,
                          label: 'All tools',
                          selected: false,
                          dense: true,
                          onTap: () {
                            Navigator.pop(context);
                            onTools?.call();
                          },
                        ),
                        const SizedBox(height: 8),
                        const _SectionLabel('Policies'),
                        _NavItem(
                          icon: Icons.policy_outlined,
                          label: 'Policy',
                          selected: false,
                          onTap: () => _openAllPolicies(context),
                        ),
                        ...AppPolicies.all.map(
                          (p) => _NavItem(
                            icon: _policyIcon(p.id),
                            label: p.title,
                            selected: false,
                            dense: true,
                            onTap: () => _openPolicy(context, p),
                          ),
                        ),
                        _NavItem(
                          icon: Icons.library_books_outlined,
                          label: 'All policies',
                          selected: false,
                          dense: true,
                          onTap: () => _openAllPolicies(context),
                        ),
                        const SizedBox(height: 8),
                        const _SectionLabel('Quick links'),
                        _NavItem(
                          icon: Icons.wb_cloudy_rounded,
                          label: 'Weather',
                          selected: false,
                          onTap: () {
                            Navigator.pop(context);
                            onWeather?.call();
                          },
                        ),
                        _NavItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Help',
                          selected: false,
                          onTap: () {
                            Navigator.pop(context);
                            onHelp?.call();
                          },
                        ),
                        if (loggedIn)
                          _NavItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            selected: false,
                            onTap: () {
                              Navigator.pop(context);
                              onLogout?.call();
                            },
                          )
                        else
                          _NavItem(
                            icon: Icons.login_rounded,
                            label: 'Login',
                            selected: false,
                            onTap: () {
                              Navigator.pop(context);
                              onLogin?.call();
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Text(
                      'Tripo v1.0 · Policies & demo build',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.slate,
                      ),
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

  static IconData _policyIcon(String id) {
    switch (id) {
      case 'privacy':
        return Icons.privacy_tip_outlined;
      case 'terms':
        return Icons.description_outlined;
      case 'cookies':
        return Icons.cookie_outlined;
      case 'refund':
        return Icons.receipt_long_outlined;
      case 'community':
        return Icons.groups_outlined;
      case 'permissions':
        return Icons.security_outlined;
      case 'about':
        return Icons.info_outline_rounded;
      default:
        return Icons.policy_outlined;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.slate,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.softSky : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: dense ? 9 : 11,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: dense ? 20 : 22,
                  color: selected ? AppColors.ocean : AppColors.slate,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: dense ? 13.5 : 14.5,
                      color: selected ? AppColors.ocean : AppColors.ink,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.ocean,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (dense)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.slate,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
