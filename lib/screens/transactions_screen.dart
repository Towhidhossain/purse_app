import 'package:flutter/material.dart';

import '../widgets/transactions/transactions_fetcher.dart';
import '../widgets/common/main_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});
  static const name = '/transactions';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _TransactionsAppBar(),
      drawer: MainDrawer(),
      body: TransactionsFetcher(),
    );
  }
}

class _TransactionsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TransactionsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Transactions'),
    );
  }
}
