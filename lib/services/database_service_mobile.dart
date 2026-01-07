import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/icons.dart' as app_icons;
import '../models/expense.dart';
import '../models/income.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  static const iTable = 'incomeTable';
  static const tTable = 'transactionTable';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbDirectory = await getDatabasesPath();
    const dbName = 'expense_tc.db';
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');

      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');

      await txn.execute('''CREATE TABLE $iTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount TEXT,
        source TEXT,
        date TEXT,
        note TEXT
      )''');

      await txn.execute('''CREATE TABLE $tTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        amount TEXT,
        label TEXT,
        date TEXT,
        note TEXT,
        category TEXT,
        linkId INTEGER,
        linkType TEXT
      )''');

      for (int i = 0; i < app_icons.icons.length; i++) {
        await txn.insert(cTable, {
          'title': app_icons.icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''CREATE TABLE $iTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount TEXT,
        source TEXT,
        date TEXT,
        note TEXT
      )''');
    }
    if (oldVersion < 3) {
      await db.execute('''CREATE TABLE $tTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        amount TEXT,
        label TEXT,
        date TEXT,
        note TEXT,
        category TEXT,
        linkId INTEGER,
        linkType TEXT
      )''');

      final expensesData = await db.query(eTable);
      for (final row in expensesData) {
        await db.insert(tTable, {
          'type': 'expense',
          'amount': row['amount'],
          'label': row['title'],
          'date': row['date'],
          'note': '',
          'category': row['category'],
          'linkId': row['id'],
          'linkType': 'expense',
        });
      }

      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [iTable]);
      if (tables.isNotEmpty) {
        final incomesData = await db.query(iTable);
        for (final row in incomesData) {
          await db.insert(tTable, {
            'type': 'income',
            'amount': row['amount'],
            'label': row['source'],
            'date': row['date'],
            'note': row['note'],
            'category': null,
            'linkId': row['id'],
            'linkType': 'income',
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final db = await database;
    return await db.transaction((txn) async =>
        List<Map<String, dynamic>>.from(await txn.query(cTable)));
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        cTable,
        {
          'entries': nEntries,
          'totalAmount': nTotalAmount.toString(),
        },
        where: 'title == ?',
        whereArgs: [category],
      );
    });
  }

  Future<int> insertExpense(Expense exp) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert(
        eTable,
        exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteExpense(int expId) async {
    final db = await database;
    await db.transaction(
      (txn) async => txn.delete(eTable, where: 'id == ?', whereArgs: [expId]),
    );
  }

  Future<void> updateExpense(Expense updated, int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        eTable,
        updated.toMap(),
        where: 'id == ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<Map<String, dynamic>>> fetchExpenses([String? category]) async {
    final db = await database;
    return await db.transaction((txn) async {
      final data = category == null
          ? await txn.query(eTable)
          : await txn.query(eTable, where: 'category == ?', whereArgs: [category]);
      return List<Map<String, dynamic>>.from(data);
    });
  }

  Future<List<Map<String, dynamic>>> fetchIncomes() async {
    final db = await database;
    return await db.transaction((txn) async {
      final data = await txn.query(iTable);
      return List<Map<String, dynamic>>.from(data);
    });
  }

  Future<int> insertIncome(Income income) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert(
        iTable,
        income.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteIncome(int incomeId) async {
    final db = await database;
    await db.transaction(
      (txn) async => txn.delete(iTable, where: 'id == ?', whereArgs: [incomeId]),
    );
  }

  Future<void> updateIncome(Income updated, int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        iTable,
        updated.toMap(),
        where: 'id == ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> insertTransaction(Map<String, dynamic> map) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert(tTable, map);
    });
  }

  Future<void> updateTransaction(
    Map<String, dynamic> map,
    int linkId,
    String linkType,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        tTable,
        map,
        where: 'linkId == ? AND linkType == ?',
        whereArgs: [linkId, linkType],
      );
    });
  }

  Future<void> deleteTransaction(int linkId, String linkType) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        tTable,
        where: 'linkId == ? AND linkType == ?',
        whereArgs: [linkId, linkType],
      );
    });
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await database;
    return await db.transaction((txn) async {
      final data = await txn.query(tTable, orderBy: 'date DESC');
      return List<Map<String, dynamic>>.from(data);
    });
  }
}
