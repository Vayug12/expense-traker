import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionProvider>().loadTransactions();
        context.read<BudgetProvider>().loadBudget();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardHome(),
      const TransactionListScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    final budget = budgetProvider.currentBudget;
    final monthlyExpense = txProvider.currentMonthExpenses;
    final budgetRemaining = budget != null ? budget.amount - monthlyExpense : null;
    final budgetWarning = budget != null && monthlyExpense > budget.amount;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Expense Manager'),
          actions: [
            IconButton(
              icon: Icon(
                context.watch<ThemeProvider>().isDark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(txProvider.balance),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: txProvider.balance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(
                                label: 'Income',
                                amount: txProvider.totalIncome,
                                color: Colors.green,
                                icon: Icons.arrow_upward,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _SummaryItem(
                                label: 'Expenses',
                                amount: txProvider.totalExpense,
                                color: Colors.red,
                                icon: Icons.arrow_downward,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Budget Progress
                if (budget != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monthly Budget',
                                style: theme.textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const BudgetScreen()),
                                ),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (monthlyExpense / budget.amount).clamp(0.0, 1.0),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: budgetWarning ? Colors.red : Colors.blue,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent: ${currencyFormat.format(monthlyExpense)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                'Budget: ${currencyFormat.format(budget.amount)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          if (budgetWarning)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Budget exceeded!',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          if (!budgetWarning && budgetRemaining != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Remaining: ${currencyFormat.format(budgetRemaining)}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Smart Insights
                if (txProvider.allTransactions.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                'Smart Insights',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InsightTile(
                            icon: Icons.trending_up,
                            text: txProvider.thisWeekExpenses > txProvider.lastWeekExpenses
                                ? 'You spent ${(((txProvider.thisWeekExpenses - txProvider.lastWeekExpenses) / (txProvider.lastWeekExpenses == 0 ? 1 : txProvider.lastWeekExpenses)) * 100).toStringAsFixed(0)}% more this week'
                                : txProvider.thisWeekExpenses < txProvider.lastWeekExpenses
                                    ? 'You spent ${(((txProvider.lastWeekExpenses - txProvider.thisWeekExpenses) / (txProvider.lastWeekExpenses == 0 ? 1 : txProvider.lastWeekExpenses)) * 100).toStringAsFixed(0)}% less this week'
                                    : 'Spending is consistent this week',
                          ),
                          const SizedBox(height: 8),
                          _InsightTile(
                            icon: Icons.category,
                            text: _getTopCategory(txProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recent Transactions
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (txProvider.recentTransactions.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No transactions yet',
                        style: TextStyle(color: Colors.grey)),
                    Text('Tap + to add one',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = txProvider.recentTransactions[index];
                return _TransactionTile(transaction: tx);
              },
              childCount: txProvider.recentTransactions.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  String _getTopCategory(TransactionProvider txProvider) {
    final categories = txProvider.categoryExpenses;
    if (categories.isEmpty) return 'No expenses yet';
    final top = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${top.first.key} is your top expense';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  currencyFormat.format(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InsightTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final ExpenseTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');
    final isExpense = transaction.type == 'expense';
    final color = isExpense ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(transaction.category),
      subtitle: Text(transaction.note.isNotEmpty ? transaction.note : ''),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            DateFormat('MMM dd').format(transaction.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
