import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class AnalyticsProvider extends ChangeNotifier {
  List<ExpenseTransaction> _transactions = [];

  void updateTransactions(List<ExpenseTransaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  Map<String, double> get monthlyCategoryExpenses {
    final now = DateTime.now();
    final monthly = _transactions.where(
        (t) => t.type == 'expense' && t.date.month == now.month && t.date.year == now.year);
    final map = <String, double>{};
    for (final t in monthly) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> get monthlyCategoryIncome {
    final now = DateTime.now();
    final monthly = _transactions.where(
        (t) => t.type == 'income' && t.date.month == now.month && t.date.year == now.year);
    final map = <String, double>{};
    for (final t in monthly) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<int, double> get dailyExpensesThisMonth {
    final now = DateTime.now();
    final monthly = _transactions.where(
        (t) => t.type == 'expense' && t.date.month == now.month && t.date.year == now.year);
    final map = <int, double>{};
    for (final t in monthly) {
      map[t.date.day] = (map[t.date.day] ?? 0) + t.amount;
    }
    return map;
  }

  List<MapEntry<String, double>> get topExpenseCategories {
    final entries = monthlyCategoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String get weeklyComparison {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));

    final thisWeek = _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
            t.date.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);

    final lastWeek = _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
            t.date.isBefore(startOfThisWeek))
        .fold(0.0, (sum, t) => sum + t.amount);

    if (lastWeek == 0) return 'No data for comparison';
    final change = ((thisWeek - lastWeek) / lastWeek * 100);
    if (change > 0) {
      return 'You spent ${change.toStringAsFixed(0)}% more this week';
    } else if (change < 0) {
      return 'You spent ${change.abs().toStringAsFixed(0)}% less this week';
    }
    return 'Spending is the same as last week';
  }

  String get topExpenseCategory {
    final entries = topExpenseCategories;
    if (entries.isEmpty) return 'No expenses yet';
    return '${entries.first.key} is your top expense';
  }

  List<String> get insights {
    final List<String> result = [];
    result.add(weeklyComparison);
    result.add(topExpenseCategory);

    final now = DateTime.now();
    final monthlyTotal = _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (monthlyTotal > 0) {
      final avgDaily = monthlyTotal / now.day;
      result.add(
          'Average daily spend: ₹${avgDaily.toStringAsFixed(0)}');
    }

    final totalTransactions = _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .length;
    result.add('You made $totalTransactions transactions this month');

    return result;
  }
}
