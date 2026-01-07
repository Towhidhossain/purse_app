import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final incomeTotal = db.periodIncomeTotal();
        final expenseTotal = db.periodExpenseTotal();
        final balance = db.periodBalance();

        final selectedPeriod = db.period == FilterPeriod.week
            ? FilterPeriod.week
            : FilterPeriod.month;

        final balanceColor =
            balance >= 0 ? colorScheme.primary : colorScheme.error;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- HEADER FIXED ----------
                LayoutBuilder(
                  builder: (context, box) {
                    return Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 10,
                      children: [
                        Text(
                          'Dashboard',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        SegmentedButton<FilterPeriod>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: FilterPeriod.week,
                              label: Text('Weekly'),
                              icon: Icon(Icons.calendar_view_week),
                            ),
                            ButtonSegment(
                              value: FilterPeriod.month,
                              label: Text('Monthly'),
                              icon: Icon(Icons.calendar_month),
                            ),
                          ],
                          selected: {selectedPeriod},
                          onSelectionChanged: (value) =>
                              db.setPeriod(value.first),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),

                /// ---------- SUMMARY CARDS ----------
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Total Income',
                        value: currency.format(incomeTotal),
                        color: colorScheme.tertiary,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Total Expense',
                        value: currency.format(expenseTotal),
                        color: colorScheme.secondary,
                        icon: Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        emphasize: true,
                        label: 'Remaining Balance',
                        value: currency.format(balance),
                        color: balanceColor,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final background = emphasize ? color.withOpacity(0.08) : null;
    final borderColor =
        emphasize ? color.withOpacity(0.4) : color.withOpacity(0.25);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),

      /// Prevents clipping / overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 4),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
