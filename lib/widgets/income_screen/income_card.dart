import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/income.dart';
import '../expense_screen/confirm_box.dart';

class IncomeCard extends StatelessWidget {
  const IncomeCard({super.key, required this.income, this.onEdit});

  final Income income;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountLabel = NumberFormat.currency(
      symbol: '৳',
      decimalDigits: 0,
    ).format(income.amount);

    return Dismissible(
      key: ValueKey(income.id),
      background: const _SwipeBackground(isStart: true),
      secondaryBackground: const _SwipeBackground(isStart: false),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => ConfirmBox(exp: null, income: income),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: onEdit,
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.trending_up, color: colorScheme.primary),
          ),
          title: Text(
            income.note?.isNotEmpty == true ? income.note! : 'Income',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              DateFormat('MMM dd, yyyy').format(income.date),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                amountLabel,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.isStart});

  final bool isStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.delete_rounded,
        color: colorScheme.onErrorContainer,
      ),
    );
  }
}
