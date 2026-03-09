import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../config/theme.dart';

/// Weekly activity graph showing searches, audits, and outreach
class WeeklyActivityGraph extends StatelessWidget {
  final Map<String, List<int>> data; // {day: [searches, audits, outreach]}
  
  const WeeklyActivityGraph({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Activity',
                style: AppTypography.titleLarge,
              ),
              _Legend(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: _bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: _leftTitleWidgets,
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: [
                  // Searches line
                  LineChartBarData(
                    spots: _getSpots(0), // index 0 = searches
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  
                  // Audits line
                  LineChartBarData(
                    spots: _getSpots(1), // index 1 = audits
                    isCurved: true,
                    color: AppColors.info,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.info,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                  ),
                  
                  // Outreach line
                  LineChartBarData(
                    spots: _getSpots(2), // index 2 = outreach
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.success,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<FlSpot> _getSpots(int dataIndex) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final spots = <FlSpot>[];
    
    for (int i = 0; i < days.length; i++) {
      final dayData = data[days[i]] ?? [0, 0, 0];
      spots.add(FlSpot(i.toDouble(), dayData[dataIndex].toDouble()));
    }
    
    return spots;
  }
  
  double _getMaxY() {
    double max = 5; // Minimum max
    
    data.forEach((day, values) {
      for (final value in values) {
        if (value > max) max = value.toDouble();
      }
    });
    
    return (max * 1.2).ceilToDouble(); // Add 20% padding
  }
  
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final index = value.toInt();
    
    if (index < 0 || index >= days.length) {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        days[index],
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
  
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: AppTypography.mono.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
      ),
      textAlign: TextAlign.right,
    );
  }
}

/// Legend for graph
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _LegendItem(color: AppColors.primary, label: 'Searches'),
        const SizedBox(height: 4),
        _LegendItem(color: AppColors.info, label: 'Audits'),
        const SizedBox(height: 4),
        _LegendItem(color: AppColors.success, label: 'Outreach'),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
