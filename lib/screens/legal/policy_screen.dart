import 'package:flutter/material.dart';

import '../../data/app_policies.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class PolicyScreen extends StatelessWidget {
  final AppPolicy policy;

  const PolicyScreen({super.key, required this.policy});

  static Future<void> open(BuildContext context, AppPolicy policy) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PolicyScreen(policy: policy)),
    );
  }

  static Future<void> openById(BuildContext context, String id) {
    final p = AppPolicies.byId(id);
    if (p == null) return Future.value();
    return open(context, p);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: policy.title,
      subtitle: policy.subtitle,
      backgroundColor: AppColors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softSky,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.policy_rounded,
                      color: AppColors.ocean, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        policy.subtitle,
                        style: const TextStyle(
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
          const SizedBox(height: 16),
          Text(
            policy.body.trim(),
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class PoliciesListScreen extends StatelessWidget {
  const PoliciesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Policies',
      subtitle: 'Legal & app information',
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        itemCount: AppPolicies.all.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final p = AppPolicies.all[i];
          return Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => PolicyScreen.open(context, p),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.softSky,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconFor(p.id),
                        size: 20,
                        color: AppColors.ocean,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          Text(
                            p.subtitle,
                            style: const TextStyle(
                              color: AppColors.slate,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.slate),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static IconData _iconFor(String id) {
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
