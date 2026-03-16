import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

/// Weekly activity graph showing searches, audits, and outreach as grouped bars
class WeeklyActivityGraph extends StatelessWidget {
  final Map<String, List<int>> data; // {day: [searches, audits, outreach]}

  const WeeklyActivityGraph({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    final resolvedSurface = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final resolvedBorder = CupertinoColors.separator.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: resolvedSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(color: resolvedBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Activity',
                style: AppTypography.titleLarge,
              ),
              _Legend(context: context),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
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
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
            begin: 0.02,
            duration: 400.ms,
            curve: Curves.easeOutQuart);
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context, int today) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const barWidth = 6.0;
    const radius = BorderRadius.vertical(top: Radius.circular(3));

    final primaryColor = CupertinoColors.systemBlue.resolveFrom(context);
    final secondaryColor = CupertinoColors.systemIndigo.resolveFrom(context);
    final successColor = CupertinoColors.systemGreen.resolveFrom(context);

    return List.generate(7, (i) {
      final dayData = data[days[i]] ?? [0, 0, 0];
      final isToday = i == today;

      return BarChartGroupData(
        x: i,
        barRods: [
          // Searches
          BarChartRodData(
            toY: dayData[0].toDouble(),
            color: isToday
                ? primaryColor
                : primaryColor.withValues(alpha: 0.5),
            width: barWidth,
            borderRadius: radius,
          ),
          // Audits
          BarChartRodData(
            toY: dayData[1].toDouble(),
            color: isToday
                ? secondaryColor
                : secondaryColor.withValues(alpha: 0.5),
            width: barWidth,
            borderRadius: radius,
          ),
          // Outreach
          BarChartRodData(
            toY: dayData[2].toDouble(),
            color: isToday
                ? successColor
                : successColor.withValues(alpha: 0.5),
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
      for (final value in values) {
        if (value > max) max = value.toDouble();
      }
    });
    return (max * 1.2).ceilToDouble();
  }

  Widget _bottomTitle(BuildContext context, double value, int today) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final index = value.toInt();
    if (index < 0 || index >= days.length) return const SizedBox();

    final isToday = index == today;

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
              color: isToday
                  ? CupertinoColors.label.resolveFrom(context)
                  : CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.resolveFrom(context),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Legend for graph
class _Legend extends StatelessWidget {
  final BuildContext context;

  const _Legend({required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: CupertinoColors.systemBlue.resolveFrom(context), label: 'Search'),
        const SizedBox(width: 12),
        _LegendItem(color: CupertinoColors.systemIndigo.resolveFrom(context), label: 'Audit'),
        const SizedBox(width: 12),
        _LegendItem(color: CupertinoColors.systemGreen.resolveFrom(context), label: 'Outreach'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }
}
