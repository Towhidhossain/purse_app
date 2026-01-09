import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/database_provider.dart';
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
  final _formKey = GlobalKey<FormState>();

  DateTime? _date;
  String? _selectedCategory;
  bool _loadingCategories = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _title.text = widget.expense!.title;
      _amount.text = widget.expense!.amount.toString();
      _date = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }

    _loadingCategories = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = context.read<DatabaseProvider>();
      await db.fetchCategories();
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        if (_selectedCategory == null && db.categories.isNotEmpty) {
          _selectedCategory = db.categories.first.title;
        }
      });
    });
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
      setState(() => _date = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseProvider>();
    final isEditing = widget.expense != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _title,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Title of expense',
                  helperText: 'Letters only',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount of expense',
                  helperText: 'Numbers only (e.g., 25.50)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(value);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _date != null
                          ? DateFormat('MMMM dd, yyyy').format(_date!)
                          : 'Select Date',
                    ),
                  ),
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_loadingCategories)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add category'),
                      onPressed: () => _showAddCategoryDialog(db),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (db.categories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: const Text('No categories yet. Add one to start.'),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: db.categories
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.title,
                            child: Text(c.title, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (v) => (v == null || v.isEmpty) ? 'Select a category' : null,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: db.categories
                        .map((c) => InputChip(
                              label: Text(c.title),
                              onDeleted: () => _confirmDeleteCategory(context, db, c.title),
                            ))
                        .toList(),
                  ),
                ],
              ],
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  if (_title.text != '' && _amount.text != '' && (_selectedCategory?.isNotEmpty ?? false)) {
                    final file = Expense(
                      id: widget.expense?.id ?? 0,
                      title: _title.text,
                      amount: double.parse(_amount.text),
                      date: _date ?? DateTime.now(),
                      category: _selectedCategory!,
                    );
                    if (isEditing) {
                      db.updateExpense(file, widget.expense!);
                    } else {
                      db.addExpense(file);
                    }
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(isEditing ? Icons.check : Icons.add),
                label: Text(isEditing ? 'Update Expense' : 'Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(DatabaseProvider db) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g., Groceries'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final ok = await db.addCategory(name);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category already exists or invalid.')),
                );
                return;
              }
              if (mounted) setState(() => _selectedCategory = name);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, DatabaseProvider db, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category'),
        content: Text('Delete "$name"? Expenses will be marked as Uncategorized.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    await db.deleteCategory(name);
    if (mounted && _selectedCategory == name) {
      setState(() => _selectedCategory = null);
    }
  }
}
