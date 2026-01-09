import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
import '../../models/income.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key, this.income});

  final Income? income;

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _amount.text = widget.income!.amount.toString();
      _note.text = widget.income!.note ?? '';
      _date = widget.income!.date;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void _submit() {
    if (_amount.text.isEmpty) return;
    final amount = double.tryParse(_amount.text);
    if (amount == null) return;

    final income = Income(
      id: widget.income?.id ?? 0,
      amount: amount,
      source: 'income',
      date: _date ?? DateTime.now(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );

    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    if (widget.income == null) {
      provider.addIncome(income);
    } else {
      provider.updateIncome(income, widget.income!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.income != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Income' : 'Add Income',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                helperText: 'Numbers only (e.g., 1000.50)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                helperText: 'Letters only',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _date != null
                        ? DateFormat('MMM dd, yyyy').format(_date!)
                        : 'Select date',
                  ),
                ),
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: Icon(isEditing ? Icons.check : Icons.add),
                label: Text(isEditing ? 'Update' : 'Add Income'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
