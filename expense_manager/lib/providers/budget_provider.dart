import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  Budget? _currentBudget;
  Budget? get currentBudget => _currentBudget;

  double get remaining {
    if (_currentBudget == null) return 0;
    return 0; // Will be calculated in screen using TransactionProvider
  }

  bool get hasBudget => _currentBudget != null;

  Future<void> loadBudget() async {
    final now = DateTime.now();
    _currentBudget = await DatabaseHelper.instance.getBudget(now.month, now.year);
    notifyListeners();
  }

  Future<void> setBudget(double amount) async {
    final now = DateTime.now();
    final budget = Budget(
      id: _currentBudget?.id ?? const Uuid().v4(),
      amount: amount,
      month: now.month,
      year: now.year,
    );
    await DatabaseHelper.instance.insertBudget(budget);
    await loadBudget();
  }

  Future<List<Budget>> getAllBudgets() async {
    return await DatabaseHelper.instance.getAllBudgets();
  }
}
