import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import './expense_list.dart';
import './expense_chart.dart';
import '../common/shimmer_block.dart';
import './expense_summary_header.dart';

class ExpenseFetcher extends StatefulWidget {
  final String? category;
  const ExpenseFetcher(this.category, {super.key});

  @override
  State<ExpenseFetcher> createState() => _ExpenseFetcherState();
}

class _ExpenseFetcherState extends State<ExpenseFetcher> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    if (widget.category != null) {
      await provider.fetchExpenses(widget.category!);
    } else {
      await provider.fetchAllExpenses();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 12)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _SummarySkeleton()),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(child: _ChartSkeleton()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            sliver: const ExpenseList(isLoading: true),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ExpenseSummaryHeader(category: widget.category),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 240,
                  child: ExpenseChart(widget.category),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          sliver: const ExpenseList(),
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            ShimmerBlock(height: 18, width: 120),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ShimmerBlock(height: 14, width: 100)),
                SizedBox(width: 12),
                ShimmerBlock(height: 36, width: 140),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBlock(height: 18, width: 120),
            SizedBox(height: 16),
            ShimmerBlock(height: 160),
          ],
        ),
      ),
    );
  }
}

