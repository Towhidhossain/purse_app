import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './total_chart.dart';
import './category_list.dart';
import './dashboard_overview.dart';

class CategoryFetcher extends StatefulWidget {
  const CategoryFetcher({super.key});

  @override
  State<CategoryFetcher> createState() => _CategoryFetcherState();
}

class _CategoryFetcherState extends State<CategoryFetcher> {
  late Future<void> _categoryList;

  Future<void> _getCategoryList() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    await Future.wait([
      db.fetchCategories(),
      db.fetchIncomes(),
      db.fetchTransactions(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _categoryList = _getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _categoryList,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              const DashboardOverview(),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 220,
                    child: const TotalChart(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Expenses',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 300, child: CategoryList()),
            ],
          ),
        );
      },
    );
  }
}
