import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';

class TotalChart extends StatefulWidget {
  const TotalChart({super.key});

  @override
  State<TotalChart> createState() => _TotalChartState();
}

class _TotalChartState extends State<TotalChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, db, __) {
      final data = db.periodExpenseByCategory();
      final entries = data.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = entries.fold<double>(0.0, (prev, e) => prev + e.value);
      final currency = NumberFormat.currency(locale: 'en_IN', symbol: '৳');

      if (entries.isEmpty) {
        return Center(
          child: Text(
            'No expenses in the selected period',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }

      return LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        final legend = Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses: ${currency.format(total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                ...entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: Colors.primaries[
                              entries.indexOf(e) % Colors.primaries.length],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            e.key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${((e.value / total) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final pie = SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 28.0,
              sections: total != 0
                  ? entries
                      .map(
                        (e) => PieChartSectionData(
                          showTitle: false,
                          value: e.value,
                          color: Colors.primaries[entries.indexOf(e) % Colors.primaries.length],
                        ),
                      )
                      .toList()
                  : entries
                      .map(
                        (e) => PieChartSectionData(
                          showTitle: false,
                          color: Colors.primaries[entries.indexOf(e) % Colors.primaries.length],
                        ),
                      )
                      .toList(),
            ),
          ),
        );

        if (isNarrow) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              legend,
              const SizedBox(width: 12),
              pie,
            ],
          );
        }

        return Row(
          children: [
            legend,
            const SizedBox(width: 12),
            Expanded(child: pie),
          ],
        );
      });
    });
  }
}
