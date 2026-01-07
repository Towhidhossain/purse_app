import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';

class TransactionsFilters extends StatelessWidget {
  const TransactionsFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _PeriodToggle(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  SizedBox(width: 200, child: _DateRangePicker()),
                  SizedBox(width: 12),
                  SizedBox(width: 220, child: _CategorySourceFilter()),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Weekly/Monthly toggles use relative dates. Custom date range overrides them.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final selected = db.period == FilterPeriod.month
            ? FilterPeriod.month
            : FilterPeriod.week;
        return SegmentedButton<FilterPeriod>(
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
          selected: {selected},
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          onSelectionChanged: (value) {
            db.setPeriod(value.first);
          },
        );
      },
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  const _DateRangePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final range = db.customRange;
        final label = range == null
            ? 'Custom date range'
            : '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM').format(range.end)}';
        return OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              initialDateRange: range ?? DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 6)),
                end: DateTime.now(),
              ),
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            db.setCustomRange(picked);
          },
          icon: const Icon(Icons.date_range),
          label: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (range != null)
                  GestureDetector(
                    onTap: () => db.setCustomRange(null),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.close, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySourceFilter extends StatelessWidget {
  const _CategorySourceFilter();

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, db, __) {
      final options = <String>['all'];
      options.addAll(db.categories.map((c) => 'exp:${c.title}'));
      options.add('inc:income');

      String labelFor(String tag) {
        if (tag == 'all') return 'All categories';
        if (tag.startsWith('exp:')) return 'Category: ${tag.substring(4)}';
        if (tag.startsWith('inc:')) return 'Income';
        return tag;
      }

      return DropdownButtonFormField<String>(
        value: db.transactionFilterTag,
        isDense: true,
        isExpanded: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.filter_alt_outlined),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        items: options
            .map(
              (o) => DropdownMenuItem<String>(
                value: o,
                child: SizedBox(
                  width: 180,
                  child: Text(
                    labelFor(o),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          db.setTransactionFilterTag(value ?? 'all');
        },
      );
    });
  }
}
