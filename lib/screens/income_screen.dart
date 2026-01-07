import 'package:flutter/material.dart';

import '../widgets/income_screen/income_fetcher.dart';
import '../widgets/income_screen/income_form.dart';
import '../widgets/common/main_drawer.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});
  static const name = '/income_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      drawer: const MainDrawer(),
      body: const IncomeFetcher(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const IncomeForm(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
    );
  }
}
