import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final budget = context.read<BudgetProvider>().currentBudget;
    if (budget != null) {
      _budgetController.text = budget.amount.toString();
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final amount = double.tryParse(_budgetController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    context.read<BudgetProvider>().setBudget(amount);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');
    final theme = Theme.of(context);

    final budget = budgetProvider.currentBudget;
    final monthlyExpense = txProvider.currentMonthExpenses;
    final remaining = budget != null ? budget.amount - monthlyExpense : 0.0;
    final isOverBudget = budget != null && monthlyExpense > budget.amount;
    final percentage = budget != null ? (monthlyExpense / budget.amount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Budget Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    if (budget != null) ...[
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: percentage,
                                  strokeWidth: 12,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: isOverBudget ? Colors.red : Colors.blue,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(0)}%',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isOverBudget ? Colors.red : Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    'used',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _BudgetRow(
                        label: 'Budget',
                        amount: budget.amount,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _BudgetRow(
                        label: 'Spent',
                        amount: monthlyExpense,
                        color: isOverBudget ? Colors.red : Colors.orange,
                      ),
                      const Divider(height: 24),
                      _BudgetRow(
                        label: remaining >= 0 ? 'Remaining' : 'Over Budget',
                        amount: remaining.abs(),
                        color: remaining >= 0 ? Colors.green : Colors.red,
                        showPrefix: false,
                      ),
                      if (isOverBudget)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You have exceeded your budget by ${currencyFormat.format(remaining.abs())}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ] else ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No budget set',
                                  style: TextStyle(color: Colors.grey)),
                              Text('Set a budget to track your spending',
                                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Set Budget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Monthly Budget',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Budget Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _saveBudget,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Budget'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool showPrefix;

  const _BudgetRow({
    required this.label,
    required this.amount,
    required this.color,
    this.showPrefix = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          '${showPrefix ? '' : ''}${currencyFormat.format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
