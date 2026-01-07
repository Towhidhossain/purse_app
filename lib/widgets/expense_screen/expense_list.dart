import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './expense_card.dart';
import '../common/shimmer_block.dart';
import '../expense_form.dart';
import '../common/empty_state.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _ExpenseListSkeleton();
    }

    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        final exList = db.expenses;

        if (exList.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.wallet_rounded,
              title: 'No expenses added yet',
              message: 'Track your spending to see weekly and monthly insights.',
              actionLabel: 'Add expense',
              onAction: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const ExpenseForm(),
                  ),
                );
              },
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 12 : 0,
                bottom: i == exList.length - 1 ? 12 : 8,
              ),
              child: ExpenseCard(
                exp: exList[i],
                onEdit: () {
                  showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    builder: (_) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewInsets.bottom,
                      ),
                      child: ExpenseForm(expense: exList[i]),
                    ),
                  );
                },
              ),
            ),
            childCount: exList.length,
          ),
        );
      },
    );
  }
}

class _ExpenseListSkeleton extends StatelessWidget {
  const _ExpenseListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => Padding(
          padding: EdgeInsets.only(
            top: i == 0 ? 12 : 0,
            bottom: i == 5 ? 12 : 8,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Row(
                children: const [
                  ShimmerBlock(
                    height: 44,
                    width: 44,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBlock(height: 14, width: 160),
                        SizedBox(height: 10),
                        ShimmerBlock(height: 12, width: 110),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  ShimmerBlock(height: 16, width: 64),
                ],
              ),
            ),
          ),
        ),
        childCount: 6,
      ),
    );
  }
}
