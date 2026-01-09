import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class QuickExpenseScreen extends StatefulWidget {
  const QuickExpenseScreen({super.key});

  @override
  State<QuickExpenseScreen> createState() => _QuickExpenseScreenState();
}

class _QuickExpenseScreenState extends State<QuickExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _storageService = StorageService();
  
  String _selectedCategory = 'Food';
  List<Map<String, dynamic>> _recentExpenses = [];
  double _todayTotal = 0.0;
  bool _isLoading = true;

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    
    final expenses = await _storageService.getExpenses();
    final today = DateTime.now();
    
    // Calculate today's total
    double total = 0.0;
    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense['date']);
      if (expenseDate.year == today.year &&
          expenseDate.month == today.month &&
          expenseDate.day == today.day) {
        total += expense['amount'] as double;
      }
    }
    
    setState(() {
      _recentExpenses = expenses.take(5).toList();
      _todayTotal = total;
      _isLoading = false;
    });
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': _titleController.text.isEmpty 
          ? _selectedCategory 
          : _titleController.text,
      'amount': double.parse(_amountController.text),
      'category': _selectedCategory,
      'date': DateTime.now().toIso8601String(),
    };

    await _storageService.addExpense(expense);
    
    _amountController.clear();
    _titleController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    
    await _loadExpenses();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 400,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Expense',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Today's Total Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${_todayTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick Add Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Expense',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Amount Field
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value!);
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Title Field (Optional)
                        TextFormField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                            border: OutlineInputBorder(),
                            isDense: true,
                            helperText: 'Letters only',
                          ),
                          maxLength: 50,
                        ),
                        const SizedBox(height: 12),
                        
                        // Add Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _addExpense,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Expense'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Recent Expenses
                  Text(
                    'Recent',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: _recentExpenses.isEmpty
                        ? Center(
                            child: Text(
                              'No expenses yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recentExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = _recentExpenses[index];
                              final date = DateTime.parse(expense['date']);
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(
                                    expense['category'][0],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(expense['title']),
                                subtitle: Text(
                                  '${expense['category']} • ${_formatDate(date)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  '\$${expense['amount'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.year == now.year && 
               date.month == now.month && 
               date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
