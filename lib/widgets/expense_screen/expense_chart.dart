import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';

class ExpenseChart extends StatelessWidget {
  final String? category;
  const ExpenseChart(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final data = db.calculateWeekExpenses(category);

        final hasData = data.any((e) => (e['amount'] as double) > 0);
        if (!hasData) return const _ChartEmptyState();

        final maxY = data.fold<double>(
          0,
          (p, e) => math.max(p, e['amount'] as double),
        );

        final chartMax = maxY <= 0 ? 10.0 : maxY * 1.25;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: chartMax,
              alignment: BarChartAlignment.spaceAround,

              barGroups: List.generate(data.length, (i) {
                final value = data[i]['amount'] as double;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: value <= 0 ? 0.01 : value,
                      width: 14,
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.primaryContainer,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: chartMax,
                        color: scheme.surfaceVariant.withOpacity(0.25),
                      ),
                    ),
                  ],
                );
              }),

              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: chartMax / 4,
                    reservedSize: 42,
                    getTitlesWidget: (v, _) => Text(
                      '৳${v.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) return const SizedBox();

                      // Show fewer labels when many days are in range
                      final step = math.max(1, (data.length / 7).ceil());
                      final isLast = i == data.length - 1;
                      if (i % step != 0 && !isLast) {
                        return const SizedBox.shrink();
                      }

                      final day = data[i]['day'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.Md().format(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: chartMax / 4,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: scheme.outlineVariant.withOpacity(0.4),
                  strokeWidth: 1,
                ),
              ),

              borderData: FlBorderData(show: false),
            ),
            swapAnimationDuration: const Duration(milliseconds: 600),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        );
      },
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No expense data for this week',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
