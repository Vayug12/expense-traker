import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<ExpenseTransaction> _transactions = [];
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterType;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  List<ExpenseTransaction> get transactions => _filteredTransactions();

  List<ExpenseTransaction> _filteredTransactions() {
    var list = List<ExpenseTransaction>.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) => t.note.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterCategory != null) {
      list = list.where((t) => t.category == _filterCategory).toList();
    }
    if (_filterType != null) {
      list = list.where((t) => t.type == _filterType).toList();
    }
    if (_filterStartDate != null) {
      list = list.where((t) => t.date.isAfter(_filterStartDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_filterEndDate != null) {
      list = list.where((t) => t.date.isBefore(_filterEndDate!.add(const Duration(days: 1)))).toList();
    }

    return list;
  }

  List<ExpenseTransaction> get allTransactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<ExpenseTransaction> get recentTransactions =>
      _transactions.take(10).toList();

  double get currentMonthExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<ExpenseTransaction> get monthlyTransactions {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
  }

  Map<String, double> get categoryExpenses {
    final now = DateTime.now();
    final monthly = _transactions.where(
        (t) => t.type == 'expense' && t.date.month == now.month && t.date.year == now.year);
    final map = <String, double>{};
    for (final t in monthly) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double get thisWeekExpenses {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            t.date.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get lastWeekExpenses {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
            t.date.isBefore(startOfThisWeek))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterType(String? type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    _filterType = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    final newTransaction = transaction.copyWith(id: const Uuid().v4());
    await DatabaseHelper.instance.insertTransaction(newTransaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }
}
