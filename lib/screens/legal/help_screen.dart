import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import 'policy_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'How do I open travel tools?',
      'Tap More on the bottom bar, or open the side menu → Tools. You will find Notes, Todo, Compass, Currency, World Clock, and more.'
    ),
    (
      'Why does weather need location?',
      'Location helps show local conditions. You can also pick a city manually. Deny permission anytime in phone settings.'
    ),
    (
      'Are currency rates live?',
      'Yes — Currency uses Frankfurter (ECB) when online. Tap refresh if rates look stale. Offline shows sample rates.'
    ),
    (
      'Where are my notes and todos saved?',
      'On this device only (local storage). Clearing app data or uninstalling may remove them.'
    ),
    (
      'How does Split Money work?',
      'Create a group, add members and expenses, then settle. Totals are for tracking — not real bank transfers in this demo.'
    ),
    (
      'Docs vault files?',
      'Files you upload are copied into the app’s local documents folder on this device. Open, rename, or delete from Docs.'
    ),
    (
      'Compass not moving?',
      'Hold the phone flat and calibrate with a figure-8 motion. Some devices need a hot restart after installing sensors.'
    ),
    (
      'Where are Privacy & Terms?',
      'Side menu → Policies, or open All policies for the full list.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Help',
      subtitle: 'FAQ & support tips',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softSky,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.ocean),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Quick answers for Tripo travel tools, weather, and policies.',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._faqs.map((faq) {
            final (q, a) = faq;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    leading: const Icon(Icons.help_outline_rounded,
                        color: AppColors.ocean, size: 22),
                    title: Text(
                      q,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          a,
                          style: const TextStyle(
                            color: AppColors.slate,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PoliciesListScreen()),
              );
            },
            icon: const Icon(Icons.policy_outlined),
            label: const Text('View all policies'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ocean,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
