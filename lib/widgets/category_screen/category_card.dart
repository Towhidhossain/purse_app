import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ex_category.dart';
import '../../screens/expense_screen.dart';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;

  const CategoryCard(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '৳');
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          ExpenseScreen.name,
          arguments: category.title,
        );
      },
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(category.icon),
      ),
      title: Text(
        category.title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('Entries: ${category.entries}'),
      trailing: Text(
        currency.format(category.totalAmount),
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
