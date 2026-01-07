import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import '../../models/expense.dart';
import '../../models/income.dart';

class ConfirmBox extends StatelessWidget {
  const ConfirmBox({
    Key? key,
    this.exp,
    this.income,
  }) : super(key: key);

  final Expense? exp;
  final Income? income;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final title = exp != null 
      ? exp!.title 
      : (income!.note?.isNotEmpty == true ? income!.note : 'Income');
    
    return AlertDialog(
      title: Text('Delete $title?'),
      content: Text('Are you sure you want to delete this ${exp != null ? 'expense' : 'income'}?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (exp != null) {
              await provider.deleteExpense(exp!.id, exp!.category, exp!.amount);
            } else if (income != null) {
              await provider.deleteIncome(income!.id);
            }
            Navigator.of(context).pop(true);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
