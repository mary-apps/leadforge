import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

/// Weekly activity graph showing total daily activity as single bars
class WeeklyActivityGraph extends StatelessWidget {
  final Map<String, List<int>> data; // {day: [searches, audits, outreach]}

  const WeeklyActivityGraph({
    super.key,
    required this.data,
  });

  bool get _hasActivity {
    return data.values.any((vals) => vals.any((v) => v > 0));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    final hasData = _hasActivity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKLY ACTIVITY',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
              AppColors.textSecondary,
              context,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: hasData ? 120 : 60,
          child: hasData
              ? BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(),
              barTouchData: BarTouchData(enabled: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) =>
                        _bottomTitle(context, value, today),
                  ),
                ),
              ),
              barGroups: _buildBarGroups(context, today),
            ),
          )
              : Center(
                  child: Text(
                    'No activity this week',
                    style: AppTypography.labelLarge(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary,
                        context,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    )
        .animate()
        .slideY(
            begin: 0.02,
            duration: 400.ms,
            curve: Curves.easeOutQuart);
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context, int today) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const barWidth = 8.0;
    const radius = BorderRadius.vertical(top: Radius.circular(3));

    final activeColor =
        CupertinoDynamicColor.resolve(AppColors.chartActive, context);
    final inactiveColor =
        CupertinoDynamicColor.resolve(AppColors.chartInactive, context);

    return List.generate(7, (i) {
      final dayData = data[days[i]] ?? [0, 0, 0];
      final total = dayData.fold<int>(0, (sum, v) => sum + v);
      final isToday = i == today;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            color: isToday ? activeColor : inactiveColor,
            width: barWidth,
            borderRadius: radius,
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    double max = 5;
    data.forEach((day, values) {
      final total = values.fold<int>(0, (sum, v) => sum + v);
      if (total > max) max = total.toDouble();
    });
    return (max * 1.2).ceilToDouble();
  }

  Widget _bottomTitle(BuildContext context, double value, int today) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final index = value.toInt();
    if (index < 0 || index >= days.length) return const SizedBox();

    final isToday = index == today;
    final tertiaryColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            days[index],
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              color: isToday ? accentColor : tertiaryColor,
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
