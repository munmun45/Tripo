import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';
import '../services/api_config.dart';
import '../theme/admin_theme.dart';
import '../widgets/glass.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _d;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient.instance.get(ApiConfig.dashboard, auth: true);
      if (!mounted) return;
      setState(() {
        _d = (data['dashboard'] as Map?)?.cast<String, dynamic>();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load dashboard';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminTheme.ocean),
      );
    }
    if (_error != null) {
      return Center(
        child: GlassPanel(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: AdminTheme.rose)),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final d = _d ?? {};
    final daily = ((d['daily'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final monthly = ((d['monthly'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final yearly = ((d['yearly'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final recent = ((d['recent_users'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return RefreshIndicator(
      color: AdminTheme.ocean,
      onRefresh: _load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final chartWide = w >= 900;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _KpiGrid(
                items: [
                  _KpiData(
                    title: 'Active today',
                    value: '${d['active_today'] ?? 0}',
                    subtitle: 'People using the app',
                    icon: Icons.bolt_rounded,
                    color: AdminTheme.teal,
                  ),
                  _KpiData(
                    title: 'Total users',
                    value: '${d['total_users'] ?? 0}',
                    subtitle: 'All registered accounts',
                    icon: Icons.groups_rounded,
                    color: AdminTheme.ocean,
                  ),
                  _KpiData(
                    title: 'New this month',
                    value: '${d['new_month'] ?? 0}',
                    subtitle: DateFormat('MMMM').format(DateTime.now()),
                    icon: Icons.calendar_month_rounded,
                    color: AdminTheme.amber,
                  ),
                  _KpiData(
                    title: 'New this year',
                    value: '${d['new_year'] ?? 0}',
                    subtitle: '${DateTime.now().year} signups',
                    icon: Icons.stacked_bar_chart_rounded,
                    color: AdminTheme.coral,
                  ),
                  _KpiData(
                    title: 'Active this week',
                    value: '${d['active_week'] ?? 0}',
                    subtitle: 'Last 7 days',
                    icon: Icons.timeline_rounded,
                    color: const Color(0xFF3A7CA5),
                  ),
                  _KpiData(
                    title: 'Packages',
                    value: '${d['packages'] ?? 0}',
                    subtitle:
                        '${d['cities'] ?? 0} cities · ${d['saved'] ?? 0} saves',
                    icon: Icons.luggage_rounded,
                    color: const Color(0xFF1F7A6C),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ChartShell(
                title: 'Daily app usage',
                subtitle: 'Active users & new signups · last 14 days',
                child: SizedBox(
                  height: chartWide ? 260 : 240,
                  child: _DailyChart(daily: daily),
                ),
              ),
              const SizedBox(height: 12),
              // Monthly + Yearly always 2-in-1-row (stack only on very small phones)
              if (w >= 640)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChartShell(
                        title: 'Monthly signups',
                        subtitle: 'New users · last 12 months',
                        child: SizedBox(
                          height: 240,
                          child: _MonthlyChart(monthly: monthly),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChartShell(
                        title: 'Yearly total users',
                        subtitle: 'Signups by year',
                        child: SizedBox(
                          height: 240,
                          child: _YearlyChart(yearly: yearly),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                _ChartShell(
                  title: 'Monthly signups',
                  subtitle: 'New users · last 12 months',
                  child: SizedBox(
                    height: 220,
                    child: _MonthlyChart(monthly: monthly),
                  ),
                ),
                const SizedBox(height: 12),
                _ChartShell(
                  title: 'Yearly total users',
                  subtitle: 'Signups by year',
                  child: SizedBox(
                    height: 220,
                    child: _YearlyChart(yearly: yearly),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _RecentUsers(users: recent),
            ],
          );
        },
      ),
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> items;

  const _KpiGrid({required this.items});

  int _columnsFor(double width) {
    if (width < 420) return 1;
    if (width < 700) return 2;
    if (width < 1100) return 3;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final cols = _columnsFor(constraints.maxWidth);
        final cardW =
            (constraints.maxWidth - gap * (cols - 1)) / cols;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: cardW,
                child: _Kpi(
                  title: item.title,
                  value: item.value,
                  subtitle: item.subtitle,
                  icon: item.icon,
                  color: item.color,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _Kpi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassIconBox(icon: icon, color: color),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AdminTheme.ink,
                height: 1,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AdminTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AdminTheme.slate.withValues(alpha: 0.95),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AdminTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: AdminTheme.slate.withValues(alpha: 0.95),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;
  const _DailyChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) {
      return const Center(child: Text('No daily data yet'));
    }
    final maxY = daily.fold<double>(1, (m, e) {
      final a = (e['active'] as num?)?.toDouble() ?? 0;
      final s = (e['signups'] as num?)?.toDouble() ?? 0;
      return [m, a, s].reduce((x, y) => x > y ? x : y);
    });

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.45),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.ink,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= daily.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${daily[i]['label']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AdminTheme.ink,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AdminTheme.ink,
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (spots) => spots.map((s) {
              final label = s.barIndex == 0 ? 'Active' : 'Signups';
              return LineTooltipItem(
                '$label  ${s.y.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < daily.length; i++)
                FlSpot(
                  i.toDouble(),
                  (daily[i]['active'] as num?)?.toDouble() ?? 0,
                ),
            ],
            isCurved: true,
            color: AdminTheme.teal,
            barWidth: 3.2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AdminTheme.teal.withValues(alpha: 0.16),
            ),
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < daily.length; i++)
                FlSpot(
                  i.toDouble(),
                  (daily[i]['signups'] as num?)?.toDouble() ?? 0,
                ),
            ],
            isCurved: true,
            color: AdminTheme.ocean,
            barWidth: 3.2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthly;
  const _MonthlyChart({required this.monthly});

  @override
  Widget build(BuildContext context) {
    if (monthly.isEmpty) {
      return const Center(child: Text('No monthly data yet'));
    }
    final maxY = monthly.fold<double>(1, (m, e) {
      final v = (e['signups'] as num?)?.toDouble() ?? 0;
      return v > m ? v : m;
    });

    return BarChart(
      BarChartData(
        maxY: maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.45),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AdminTheme.ink,
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = groupIndex >= 0 && groupIndex < monthly.length
                  ? '${monthly[groupIndex]['label']}'
                  : '';
              return BarTooltipItem(
                '$label\n${rod.toY.toInt()} signups',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.ink,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= monthly.length || i % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${monthly[i]['label']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AdminTheme.ink,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < monthly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (monthly[i]['signups'] as num?)?.toDouble() ?? 0,
                  width: 12,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AdminTheme.ocean, AdminTheme.teal],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _YearlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> yearly;
  const _YearlyChart({required this.yearly});

  @override
  Widget build(BuildContext context) {
    if (yearly.isEmpty) {
      return const Center(child: Text('No yearly data yet'));
    }
    final maxY = yearly.fold<double>(1, (m, e) {
      final v = (e['users'] as num?)?.toDouble() ?? 0;
      return v > m ? v : m;
    });

    return BarChart(
      BarChartData(
        maxY: maxY + 1,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.45),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AdminTheme.ink,
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final year = groupIndex >= 0 && groupIndex < yearly.length
                  ? '${yearly[groupIndex]['year']}'
                  : '';
              return BarTooltipItem(
                '$year\n${rod.toY.toInt()} users',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.ink,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= yearly.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${yearly[i]['year']}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AdminTheme.ink,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < yearly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (yearly[i]['users'] as num?)?.toDouble() ?? 0,
                  width: 28,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  color: AdminTheme.coral,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentUsers extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const _RecentUsers({required this.users});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM');
    return GlassPanel(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent users',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AdminTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Latest accounts that joined Tripo',
            style: TextStyle(
              color: AdminTheme.slate.withValues(alpha: 0.95),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No users yet'),
            )
          else
            ...users.map((u) {
              final name = '${u['name'] ?? ''}';
              DateTime? created;
              try {
                created = DateTime.parse('${u['created_at']}');
              } catch (_) {}
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AdminTheme.ocean.withValues(alpha: 0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AdminTheme.ocean,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${u['phone'] ?? ''}'),
                trailing: Text(
                  created == null ? '' : df.format(created),
                  style: const TextStyle(color: AdminTheme.slate, fontSize: 12),
                ),
              );
            }),
        ],
      ),
    );
  }
}
