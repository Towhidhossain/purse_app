import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import './transactions_list.dart';
import './transactions_filters.dart';

class TransactionsFetcher extends StatefulWidget {
  const TransactionsFetcher({super.key});

  @override
  State<TransactionsFetcher> createState() => _TransactionsFetcherState();
}

class _TransactionsFetcherState extends State<TransactionsFetcher> {
  late Future _future;

  Future _load() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Future.wait([
      provider.fetchTransactions(),
      provider.fetchAllExpenses(),
      provider.fetchIncomes(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: const [
                TransactionsFilters(),
                SizedBox(height: 12),
                Expanded(child: TransactionsList()),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
