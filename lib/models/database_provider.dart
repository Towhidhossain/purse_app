import 'package:flutter/material.dart';

import '../services/database_service.dart';
import './ex_category.dart';
import './expense.dart';
import './income.dart';
import './transaction.dart';

enum FilterPeriod { week, month, custom }

class DatabaseProvider with ChangeNotifier {
  DatabaseProvider() : _dbService = DatabaseService();

  final DatabaseService _dbService;
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  FilterPeriod _period = FilterPeriod.month;
  DateTimeRange? _customRange;


  FilterPeriod get period => _period;
  DateTimeRange? get customRange => _customRange;

  void setPeriod(FilterPeriod value) {
    _period = value;
    if (value != FilterPeriod.custom) {
      _customRange = null;
    }
    notifyListeners();
  }

  void setCustomRange(DateTimeRange? range) {
    _customRange = range;
    _period = range == null ? FilterPeriod.week : FilterPeriod.custom;
    notifyListeners();
  }

  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<FinanceTransaction> _transactions = [];
  String _transactionFilterTag = 'all';

  // Getter for expenses that respects search, time range, and current list
  List<Expense> get expenses {
    Iterable<Expense> results = _expenses;

    if (_searchText.isNotEmpty) {
      results = results.where(
        (e) => e.title.toLowerCase().contains(_searchText.toLowerCase()),
      );
    }

    results = results.where((e) => _isInRange(e.date));

    return results.toList();
  }

  // CALCULATE TOTAL FOR THE CURRENT VIEW
  // This is what your ExpenseSummaryHeader should call
  double get totalExpensesForCurrentList {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  List<Expense> get allExpensesUnfiltered {
    Iterable<Expense> results = _expenses;
    if (_searchText.isNotEmpty) {
      results = results.where(
        (e) => e.title.toLowerCase().contains(_searchText.toLowerCase()),
      );
    }
    return results.toList();
  }

  List<Income> get incomes {
    Iterable<Income> results = _incomes;
    if (_searchText.isNotEmpty) {
      results = results.where(
        (i) =>
            i.source.toLowerCase().contains(_searchText.toLowerCase()) ||
            (i.note ?? '').toLowerCase().contains(_searchText.toLowerCase()),
      );
    }
    results = results.where((i) => _isInRange(i.date));
    return results.toList();
  }

  List<FinanceTransaction> get transactions {
    Iterable<FinanceTransaction> results = _transactions;

    if (_searchText.isNotEmpty) {
      results = results.where(
        (t) => t.label.toLowerCase().contains(_searchText.toLowerCase()) ||
            (t.note ?? '').toLowerCase().contains(_searchText.toLowerCase()),
      );
    }

    results = results.where((t) => _isInRange(t.date));

    if (_transactionFilterTag != 'all') {
      if (_transactionFilterTag.startsWith('exp:')) {
        final cat = _transactionFilterTag.substring(4);
        results = results.where(
            (t) => t.type == TransactionType.expense && t.category == cat);
      } else if (_transactionFilterTag.startsWith('inc:')) {
        final source = _transactionFilterTag.substring(4).toLowerCase();
        results = results.where((t) =>
            t.type == TransactionType.income &&
            t.label.toLowerCase() == source);
      }
    }

    return results.toList();
  }

  String get transactionFilterTag => _transactionFilterTag;
  void setTransactionFilterTag(String tag) {
    _transactionFilterTag = tag;
    notifyListeners();
  }

  Future<List<ExpenseCategory>> fetchCategories() async {
    final data = await _dbService.fetchCategories();
    final nList = List.generate(
      data.length,
      (index) => ExpenseCategory.fromString(data[index]),
    );
    _categories = nList;
    return _categories;
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    await _dbService.updateCategory(category, nEntries, nTotalAmount);
    try {
      var file = _categories.firstWhere((element) => element.title == category);
      file.entries = nEntries;
      file.totalAmount = nTotalAmount;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> addExpense(Expense exp) async {
    final generatedId = await _dbService.insertExpense(exp);
    final file = Expense(
        id: generatedId,
        title: exp.title,
        amount: exp.amount,
        date: exp.date,
        category: exp.category);

    _expenses.add(file);

    try {
      var ex = findCategory(exp.category);
      updateCategory(exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
    } catch (_) {}

    await _dbService.insertTransaction({
      'type': 'expense',
      'amount': exp.amount.toString(),
      'label': exp.title,
      'date': exp.date.toIso8601String(),
      'note': '',
      'category': exp.category,
      'linkId': file.id,
      'linkType': 'expense',
    });
    
    _transactions.add(
      FinanceTransaction(
        id: 0,
        type: TransactionType.expense,
        amount: exp.amount,
        label: exp.title,
        date: exp.date,
        note: '',
        category: exp.category,
        linkId: file.id,
        linkType: 'expense',
      ),
    );
    notifyListeners();
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    try {
      await _dbService.deleteExpense(expId);
      _expenses.removeWhere((element) => element.id == expId);

      try {
        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      } catch (e) {}

      await _dbService.deleteTransaction(expId, 'expense');
      _transactions.removeWhere(
        (t) => t.linkId == expId && t.linkType == 'expense',
      );
      notifyListeners();
    } catch (e) {}
  }

  Future<void> updateExpense(Expense updated, Expense original) async {
    await _dbService.updateExpense(updated, original.id);

    final newExp = Expense(
      id: original.id,
      title: updated.title,
      amount: updated.amount,
      date: updated.date,
      category: updated.category,
    );

    final index = _expenses.indexWhere((element) => element.id == original.id);
    if (index != -1) {
      _expenses[index] = newExp;
    }

    if (updated.category != original.category) {
      final prev = findCategory(original.category);
      final next = findCategory(updated.category);

      updateCategory(original.category, prev.entries - 1, prev.totalAmount - original.amount);
      updateCategory(updated.category, next.entries + 1, next.totalAmount + updated.amount);
    } else {
      final cat = findCategory(updated.category);
      updateCategory(updated.category, cat.entries, cat.totalAmount - original.amount + updated.amount);
    }

    await _dbService.updateTransaction({
      'amount': updated.amount.toString(),
      'label': updated.title,
      'date': updated.date.toIso8601String(),
      'category': updated.category,
    }, original.id, 'expense');

    notifyListeners();
  }

  // MODIFIED TO HANDLE 'All' CATEGORY
  Future<List<Expense>> fetchExpenses(String category) async {
    List<Map<String, dynamic>> data;
    if (category == 'All') {
      data = await _dbService.fetchExpenses(); // Fetch all if category is 'All'
    } else {
      data = await _dbService.fetchExpenses(category);
    }
    
    _expenses = List.generate(data.length, (index) => Expense.fromString(data[index]));
    notifyListeners();
    return _expenses;
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final data = await _dbService.fetchExpenses();
    _expenses = List.generate(data.length, (index) => Expense.fromString(data[index]));
    notifyListeners();
    return _expenses;
  }

  Future<List<Income>> fetchIncomes() async {
    final data = await _dbService.fetchIncomes();
    _incomes = List.generate(data.length, (index) => Income.fromString(data[index]));
    notifyListeners();
    return _incomes;
  }

  Future<List<FinanceTransaction>> fetchTransactions() async {
    final data = await _dbService.fetchTransactions();
    _transactions = List.generate(
      data.length,
      (index) => FinanceTransaction.fromString(data[index]),
    );
    notifyListeners();
    return _transactions;
  }

  Future<void> addIncome(Income income) async {
    final generatedId = await _dbService.insertIncome(income);
    final file = Income(
      id: generatedId,
      amount: income.amount,
      source: income.source,
      date: income.date,
      note: income.note,
    );
    _incomes.add(file);

    await _dbService.insertTransaction({
      'type': 'income',
      'amount': income.amount.toString(),
      'label': income.note ?? 'Income',
      'date': income.date.toIso8601String(),
      'note': income.note ?? '',
      'category': '',
      'linkId': file.id,
      'linkType': 'income',
    });

    _transactions.add(
      FinanceTransaction(
        id: 0,
        type: TransactionType.income,
        amount: income.amount,
        label: income.note ?? 'Income',
        date: income.date,
        note: income.note ?? '',
        category: '',
        linkId: file.id,
        linkType: 'income',
      ),
    );
    notifyListeners();
  }

  Future<void> updateIncome(Income updated, Income original) async {
    await _dbService.updateIncome(updated, original.id);
    
    // Find and update the income in the list
    final index = _incomes.indexWhere((element) => element.id == original.id);
    if (index != -1) {
      _incomes[index] = updated;
    }

    await _dbService.updateTransaction({
      'amount': updated.amount.toString(),
      'label': updated.note ?? 'Income',
      'date': updated.date.toIso8601String(),
      'note': updated.note ?? '',
    }, original.id, 'income');

    notifyListeners();
  }

  Future<void> deleteIncome(int incomeId) async {
    try {
      await _dbService.deleteIncome(incomeId);
      _incomes.removeWhere((element) => element.id == incomeId);
      
      // Delete associated transaction
      _transactions.removeWhere(
        (t) => t.linkId == incomeId && t.linkType == 'income',
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  double periodIncomeTotal() {
    return _transactions
        .where((t) => t.type == TransactionType.income && _isInRange(t.date))
        .fold(0.0, (prev, t) => prev + t.amount);
  }

  double periodExpenseTotal() {
    return _transactions
        .where((t) => t.type == TransactionType.expense && _isInRange(t.date))
        .fold(0.0, (prev, t) => prev + t.amount);
  }

  double periodBalance() {
    return periodIncomeTotal() - periodExpenseTotal();
  }

  Map<String, double> periodExpenseByCategory() {
    final Map<String, double> breakdown = {};
    for (final t in _transactions.where(
        (t) => t.type == TransactionType.expense && _isInRange(t.date))) {
      breakdown.update(t.category ?? '', (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }
    return breakdown;
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = expenses.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }
    return {'entries': list.length, 'totalAmount': total};
  }

  Map<String, dynamic> calculateTotalEntriesAndAmount() {
    double total = 0.0;
    for (final i in expenses) {
      total += i.amount;
    }
    return {'entries': expenses.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    return _categories.fold(
        0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  double calculateTotalIncome() {
    return _incomes.fold(0.0, (prev, income) => prev + income.amount);
  }

  double calculateBalance() {
    return calculateTotalIncome() - calculateTotalExpenses();
  }

  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  bool _isInRange(DateTime date) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_period == FilterPeriod.custom && _customRange != null) {
      start = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
      end = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
    } else if (_period == FilterPeriod.month) {
      start = end.subtract(const Duration(days: 29));
    } else {
      start = end.subtract(const Duration(days: 6));
    }
    
    // Normalize the date to compare (remove time component)
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  List<Map<String, dynamic>> calculateWeekExpenses([String? category]) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    DateTime end = DateTime(now.year, now.month, now.day);
    DateTime start = _period == FilterPeriod.month 
        ? end.subtract(const Duration(days: 29)) 
        : end.subtract(const Duration(days: 6));

    if (_period == FilterPeriod.custom && _customRange != null) {
      start = _customRange!.start;
      end = _customRange!.end;
    }

    for (DateTime day = start; !day.isAfter(end); day = day.add(const Duration(days: 1))) {
      double total = 0.0;
      for (final exp in _expenses) {
        if (exp.date.year == day.year &&
            exp.date.month == day.month &&
            exp.date.day == day.day &&
            (category == null || category == 'All' || exp.category == category)) {
          total += exp.amount;
        }
      }
      data.add({'day': day, 'amount': total});
    }
    return data.reversed.toList();
  }
}