import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/page_scaffold.dart';

class _CityClock {
  final String city;
  final String country;
  /// ISO 3166-1 alpha-2 for flagcdn.com
  final String countryCode;
  final Duration offsetFromUtc;

  const _CityClock(
    this.city,
    this.country,
    this.countryCode,
    this.offsetFromUtc,
  );
}

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  static const _cities = <_CityClock>[
    _CityClock('New Delhi', 'India', 'in', Duration(hours: 5, minutes: 30)),
    _CityClock('Dubai', 'UAE', 'ae', Duration(hours: 4)),
    _CityClock('London', 'UK', 'gb', Duration(hours: 0)),
    _CityClock('Paris', 'France', 'fr', Duration(hours: 1)),
    _CityClock('New York', 'USA', 'us', Duration(hours: -5)),
    _CityClock('Tokyo', 'Japan', 'jp', Duration(hours: 9)),
    _CityClock('Singapore', 'Singapore', 'sg', Duration(hours: 8)),
    _CityClock('Sydney', 'Australia', 'au', Duration(hours: 10)),
  ];

  Timer? _timer;
  DateTime _nowUtc = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _nowUtc = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time12 = DateFormat('hh:mm:ss a');
    final time24 = DateFormat('HH:mm:ss');
    final dateFmt = DateFormat('EEE, dd MMM');

    return PageScaffold(
      title: 'World Clock',
      subtitle: '12-hour & 24-hour',
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: _cities.length,
        separatorBuilder: (c, i) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = _cities[i];
          final local = _nowUtc.add(c.offsetFromUtc);
          final diffH = c.offsetFromUtc.inMinutes / 60.0;
          final sign = diffH >= 0 ? '+' : '';
          return GlassCard(
            enableBlur: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _FlagBadge(countryCode: c.countryCode),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.city,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      Text(
                        '${c.country} · UTC$sign${diffH.toStringAsFixed(diffH.abs() % 1 == 0 ? 0 : 1)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time12.format(local),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ocean,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${time24.format(local)} · 24h',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      dateFmt.format(local),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  final String countryCode;

  const _FlagBadge({required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.softSky,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        'https://flagcdn.com/w80/$countryCode.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.flag_rounded, size: 18, color: AppColors.ocean),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}
