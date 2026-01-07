import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../constants/icons.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.expense});

  final Expense? expense;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;
  String _initialValue = 'Other';

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _title.text = widget.expense!.title;
      _amount.text = widget.expense!.amount.toString();
      _date = widget.expense!.date;
      _initialValue = widget.expense!.category;
    }
  }

  //
  _pickDate() async {
    final now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _date ?? now,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year + 1, 12, 31));

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final isEditing = widget.expense != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // amount
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // date picker
            Row(
              children: [
                Expanded(
                  child: Text(_date != null
                      ? DateFormat('MMMM dd, yyyy').format(_date!)
                      : 'Select Date'),
                ),
                IconButton(
                  onPressed: () => _pickDate(),
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // category
            Row(
              children: [
                const Expanded(child: Text('Category')),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      items: icons.keys
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      value: _initialValue,
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setState(() {
                          _initialValue = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_title.text != '' && _amount.text != '') {
                  // create an expense
                  final file = Expense(
                    id: widget.expense?.id ?? 0,
                    title: _title.text,
                    amount: double.parse(_amount.text),
                    date: _date != null ? _date! : DateTime.now(),
                    category: _initialValue,
                  );
                  if (isEditing) {
                    provider.updateExpense(file, widget.expense!);
                  } else {
                    provider.addExpense(file);
                  }
                  // close the bottomsheet
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(isEditing ? Icons.check : Icons.add),
              label: Text(isEditing ? 'Update Expense' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
