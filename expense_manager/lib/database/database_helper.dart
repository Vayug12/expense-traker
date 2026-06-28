import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        UNIQUE(month, year)
      )
    ''');
  }

  Future<void> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => ExpenseTransaction.fromMap(map)).toList();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Budget?> getBudget(int month, int year) async {
    final db = await database;
    final result = await db.query('budgets',
        where: 'month = ? AND year = ?', whereArgs: [month, year]);
    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final result = await db.query('budgets');
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> exportTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<List<Map<String, dynamic>>> exportBudgets() async {
    final db = await database;
    return await db.query('budgets');
  }

  Future<void> restoreTransactions(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('transactions');
    for (final item in data) {
      batch.insert('transactions', item);
    }
    await batch.commit(noResult: true);
  }

  Future<void> restoreBudgets(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('budgets');
    for (final item in data) {
      batch.insert('budgets', item);
    }
    await batch.commit(noResult: true);
  }
}
