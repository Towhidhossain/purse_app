import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import '../../models/expense.dart';
import '../../models/income.dart';
import '../../models/transaction.dart';
import '../expense_form.dart';
import '../income_screen/income_form.dart';
import '../expense_screen/confirm_box.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final transactions = db.transactions;
        if (transactions.isEmpty) {
          return const _EmptyTransactions();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final tx = transactions[i];
            final colorScheme = Theme.of(ctx).colorScheme;
            final isIncome = tx.type == TransactionType.income;
            final amount = NumberFormat.currency(symbol: '৳', decimalDigits: 0)
                .format(tx.amount);

            return Dismissible(
              key: ValueKey('tx-${tx.id}-${tx.linkId}-${tx.type.name}'),
              background: const _SwipeBackground(isStart: true),
              secondaryBackground: const _SwipeBackground(isStart: false),
              confirmDismiss: (_) async {
                final income = isIncome ? _findIncome(db, tx) : null;
                final expense = !isIncome ? _findExpense(db, tx) : null;
                if (income == null && expense == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Item no longer exists.')),
                  );
                  return false;
                }
                return await showDialog<bool>(
                  context: ctx,
                  builder: (dialogCtx) => ConfirmBox(exp: expense, income: income),
                );
              },
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _handleEdit(ctx, db, tx),
                  leading: _LeadingBadge(isIncome: isIncome),
                  title: Text(
                    tx.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _buildSubtitle(tx),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        isIncome ? '+$amount' : '-$amount',
                        style: TextStyle(
                          color: isIncome
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleEdit(
    BuildContext context,
    DatabaseProvider db,
    FinanceTransaction tx,
  ) async {
    if (tx.type == TransactionType.income) {
      final income = _findIncome(db, tx);
      if (income == null) {
        _showMissing(context);
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => IncomeForm(income: income),
      );
      return;
    }

    final expense = _findExpense(db, tx);
    if (expense == null) {
      _showMissing(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseForm(expense: expense),
    );
  }

  Income? _findIncome(DatabaseProvider db, FinanceTransaction tx) {
    if (tx.linkType != 'income' || tx.linkId == null) return null;
    try {
      return db.incomes.firstWhere((i) => i.id == tx.linkId);
    } catch (_) {
      return null;
    }
  }

  Expense? _findExpense(DatabaseProvider db, FinanceTransaction tx) {
    if (tx.linkType != 'expense' || tx.linkId == null) return null;
    try {
      return db.expenses.firstWhere((e) => e.id == tx.linkId);
    } catch (_) {
      return null;
    }
  }

  String _buildSubtitle(FinanceTransaction tx) {
    final dateLabel = DateFormat('MMM dd, yyyy').format(tx.date);
    if (tx.type == TransactionType.expense) {
      return tx.category != null
          ? '${tx.category} • $dateLabel'
          : dateLabel;
    }
    // For income, show note with date if available, otherwise just date
    return tx.note?.isNotEmpty == true 
        ? '${tx.note} • $dateLabel'
        : dateLabel;
  }

  void _showMissing(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Original item missing. Please refresh.')),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({required this.isIncome});

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isIncome ? colorScheme.primary : colorScheme.error;
    final bg = isIncome
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final icon = isIncome ? Icons.south_west_rounded : Icons.north_east_rounded;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Icon(icon, color: color),
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

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sync_alt_rounded,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Add an income or expense to see it here.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
