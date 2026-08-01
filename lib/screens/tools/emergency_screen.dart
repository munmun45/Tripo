import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String _query = '';

  static const _contacts = <(String, String, String, IconData, Color)>[
    (
      'SOS / Emergency',
      '112',
      'India national emergency',
      Icons.sos_rounded,
      Color(0xFFD32F2F),
    ),
    (
      'Police',
      '100',
      'Local police',
      Icons.local_police_rounded,
      Color(0xFF1A4F9C),
    ),
    (
      'Ambulance',
      '108',
      'Medical emergency',
      Icons.medical_services_rounded,
      Color(0xFF2E7D32),
    ),
    (
      'Fire',
      '101',
      'Fire brigade',
      Icons.local_fire_department_rounded,
      Color(0xFFE65100),
    ),
    (
      'Women helpline',
      '1091',
      'Women in distress',
      Icons.support_agent_rounded,
      Color(0xFF7B1FA2),
    ),
    (
      'Child helpline',
      '1098',
      'Child in need of care',
      Icons.child_care_rounded,
      Color(0xFFE91E63),
    ),
    (
      'Tourist helpline',
      '1363',
      'Ministry of Tourism',
      Icons.travel_explore_rounded,
      Color(0xFF00838F),
    ),
    (
      'Disaster management',
      '1078',
      'NDRF / natural disaster',
      Icons.warning_amber_rounded,
      Color(0xFFBF360C),
    ),
    (
      'Highway / road accident',
      '1073',
      'NHAI road emergency',
      Icons.directions_car_filled_rounded,
      Color(0xFF455A64),
    ),
    (
      'Railway helpline',
      '139',
      'Train enquiry & help',
      Icons.train_rounded,
      Color(0xFF1565C0),
    ),
    (
      'Cyber crime',
      '1930',
      'Online / financial fraud',
      Icons.security_rounded,
      Color(0xFF4527A0),
    ),
    (
      'Senior citizen',
      '14567',
      'Elder care helpline',
      Icons.elderly_rounded,
      Color(0xFF6D4C41),
    ),
    (
      'Gas leak / LPG',
      '1906',
      'LPG emergency',
      Icons.propane_tank_rounded,
      Color(0xFFEF6C00),
    ),
    (
      'Coast Guard',
      '1554',
      'Sea / coastal rescue',
      Icons.sailing_rounded,
      Color(0xFF0277BD),
    ),
  ];

  List<(String, String, String, IconData, Color)> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts
        .where(
          (c) =>
              c.$1.toLowerCase().contains(q) ||
              c.$2.contains(q) ||
              c.$3.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not dial $number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _filtered;

    return PageScaffold(
      title: 'Emergency',
      subtitle: 'Quick dial help numbers',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'In danger, call 112 first. Numbers below are common India helplines — verify locally when abroad.',
              style: TextStyle(height: 1.4, color: AppColors.ink),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search name or number',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () => setState(() => _query = ''),
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: AppColors.softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          if (contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No matching helpline',
                  style: TextStyle(color: AppColors.slate),
                ),
              ),
            )
          else
            ...contacts.map((c) {
              final (title, number, sub, icon, color) = c;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _call(context, number),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: color.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Icon(icon, color: color, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: color.withValues(alpha: 0.95),
                                  ),
                                ),
                                Text(
                                  sub,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.slate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.call_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  number,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
