import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/expense_screen/expense_fetcher.dart';
import '../widgets/common/main_drawer.dart';
import '../models/database_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  static const name = '/expense_screen';

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    await db.fetchCategories();
    await db.fetchAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: _initFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const ExpenseFetcher(null);
        },
      ),
    );
  }
}
