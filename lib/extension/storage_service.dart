import 'dart:html' as html;
import 'dart:convert';

class StorageService {
  static const String _storageKey = 'purse_expenses';

  // Get all expenses from Chrome storage
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      final storage = html.window.localStorage;
      final data = storage[_storageKey];
      
      if (data == null) return [];
      
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>().toList()
        ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Add a new expense
  Future<void> addExpense(Map<String, dynamic> expense) async {
    try {
      final expenses = await getExpenses();
      expenses.insert(0, expense);
      
      // Keep only last 100 expenses to avoid storage issues
      if (expenses.length > 100) {
        expenses.removeRange(100, expenses.length);
      }
      
      final storage = html.window.localStorage;
      storage[_storageKey] = jsonEncode(expenses);
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  // Clear all expenses (optional - for testing)
  Future<void> clearExpenses() async {
    final storage = html.window.localStorage;
    storage.remove(_storageKey);
  }
}
