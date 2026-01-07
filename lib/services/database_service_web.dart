import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/icons.dart' as app_icons;
import '../models/expense.dart';
import '../models/income.dart';

class DatabaseService {
  DatabaseService._internal() {
    _initializeCategories();
  }
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  static const iTable = 'incomeTable';
  static const tTable = 'transactionTable';

  SharedPreferences? _prefs;
  int _nextExpenseId = 1;
  int _nextIncomeId = 1;
  int _nextTransactionId = 1;

  Future<SharedPreferences> get _preferences async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    _nextExpenseId = _prefs!.getInt('nextExpenseId') ?? 1;
    _nextIncomeId = _prefs!.getInt('nextIncomeId') ?? 1;
    _nextTransactionId = _prefs!.getInt('nextTransactionId') ?? 1;
    return _prefs!;
  }

  Future<void> _initializeCategories() async {
    final prefs = await _preferences;
    final existing = prefs.getStringList(cTable);
    if (existing == null || existing.isEmpty) {
      final categories = app_icons.icons.keys.map((title) {
        return jsonEncode({
          'title': title,
          'entries': 0,
          'totalAmount': '0.0',
        });
      }).toList();
      await prefs.setStringList(cTable, categories);
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final prefs = await _preferences;
    final data = prefs.getStringList(cTable) ?? [];
    return data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(cTable) ?? [];
    final updated = data.map((e) {
      final map = jsonDecode(e);
      if (map['title'] == category) {
        map['entries'] = nEntries;
        map['totalAmount'] = nTotalAmount.toString();
      }
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(cTable, updated);
  }

  Future<int> insertExpense(Expense exp) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(eTable) ?? [];
    final id = _nextExpenseId++;
    await prefs.setInt('nextExpenseId', _nextExpenseId);
    
    final map = exp.toMap();
    map['id'] = id;
    data.add(jsonEncode(map));
    await prefs.setStringList(eTable, data);
    return id;
  }

  Future<void> deleteExpense(int expId) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(eTable) ?? [];
    final filtered = data.where((e) {
      final map = jsonDecode(e);
      final id = map['id'];
      // Handle both int and String comparison
      return id != expId && id.toString() != expId.toString();
    }).toList();
    await prefs.setStringList(eTable, filtered);
  }

  Future<void> updateExpense(Expense updated, int id) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(eTable) ?? [];
    final updatedData = data.map((e) {
      final map = jsonDecode(e);
      if (map['id'] == id) {
        final newMap = updated.toMap();
        newMap['id'] = id;
        return jsonEncode(newMap);
      }
      return e;
    }).toList();
    await prefs.setStringList(eTable, updatedData);
  }

  Future<List<Map<String, dynamic>>> fetchExpenses([String? category]) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(eTable) ?? [];
    final expenses = data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    
    if (category == null) return expenses;
    return expenses.where((e) => e['category'] == category).toList();
  }

  Future<List<Map<String, dynamic>>> fetchIncomes() async {
    final prefs = await _preferences;
    final data = prefs.getStringList(iTable) ?? [];
    return data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  Future<int> insertIncome(Income income) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(iTable) ?? [];
    final id = _nextIncomeId++;
    await prefs.setInt('nextIncomeId', _nextIncomeId);
    
    final map = income.toMap();
    map['id'] = id;
    data.add(jsonEncode(map));
    await prefs.setStringList(iTable, data);
    return id;
  }

  Future<void> deleteIncome(int incomeId) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(iTable) ?? [];
    final filtered = data.where((e) {
      final map = jsonDecode(e);
      final id = map['id'];
      // Handle both int and String comparison
      return id != incomeId && id.toString() != incomeId.toString();
    }).toList();
    await prefs.setStringList(iTable, filtered);
  }

  Future<void> updateIncome(Income updated, int id) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(iTable) ?? [];
    final updatedData = data.map((e) {
      final map = jsonDecode(e);
      if (map['id'] == id) {
        final newMap = updated.toMap();
        newMap['id'] = id;
        return jsonEncode(newMap);
      }
      return e;
    }).toList();
    await prefs.setStringList(iTable, updatedData);
  }

  Future<int> insertTransaction(Map<String, dynamic> map) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(tTable) ?? [];
    final id = _nextTransactionId++;
    await prefs.setInt('nextTransactionId', _nextTransactionId);
    
    map['id'] = id;
    data.add(jsonEncode(map));
    await prefs.setStringList(tTable, data);
    return id;
  }

  Future<void> updateTransaction(
    Map<String, dynamic> map,
    int linkId,
    String linkType,
  ) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(tTable) ?? [];
    final updatedData = data.map((e) {
      final txn = jsonDecode(e);
      if (txn['linkId'] == linkId && txn['linkType'] == linkType) {
        txn.addAll(map);
        return jsonEncode(txn);
      }
      return e;
    }).toList();
    await prefs.setStringList(tTable, updatedData);
  }

  Future<void> deleteTransaction(int linkId, String linkType) async {
    final prefs = await _preferences;
    final data = prefs.getStringList(tTable) ?? [];
    final filtered = data.where((e) {
      final map = jsonDecode(e);
      final id = map['linkId'];
      final type = map['linkType'];
      // Handle both int and String comparison for linkId
      return !(((id == linkId) || (id.toString() == linkId.toString())) && type == linkType);
    }).toList();
    await prefs.setStringList(tTable, filtered);
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final prefs = await _preferences;
    final data = prefs.getStringList(tTable) ?? [];
    final transactions = data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    
    // Sort by date DESC
    transactions.sort((a, b) {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateB.compareTo(dateA);
    });
    
    return transactions;
  }
}
