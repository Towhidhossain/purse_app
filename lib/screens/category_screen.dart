import 'package:flutter/material.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';
import '../screens/income_screen.dart';
import '../screens/transactions_screen.dart';
import '../widgets/common/theme_toggle.dart';
import '../widgets/common/main_drawer.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static const name = '/category_screen'; // for routes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          const ThemeToggleAction(),
          IconButton(
            tooltip: 'Transactions',
            icon: const Icon(Icons.swap_vert_circle_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(TransactionsScreen.name);
            },
          ),
          IconButton(
            tooltip: 'Income',
            icon: const Icon(Icons.trending_up),
            onPressed: () {
              Navigator.of(context).pushNamed(IncomeScreen.name);
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: const CategoryFetcher(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ExpenseForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
