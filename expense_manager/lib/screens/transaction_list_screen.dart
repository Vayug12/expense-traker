import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String? _selectedCategory;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;
    final currencyFormat = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Transactions'),
            actions: [
              IconButton(
                icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                    if (!_showFilters) {
                      _selectedCategory = null;
                      _selectedType = null;
                      _startDate = null;
                      _endDate = null;
                      provider.clearFilters();
                    }
                  });
                },
              ),
            ],
          ),

          // Filters
          if (_showFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Filter
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'all', label: Text('All')),
                        ButtonSegment(value: 'expense', label: Text('Expense')),
                        ButtonSegment(value: 'income', label: Text('Income')),
                      ],
                      selected: {_selectedType ?? 'all'},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _selectedType = selected.first == 'all' ? null : selected.first;
                          provider.setFilterType(_selectedType);
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Category Filter
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...ExpenseTransaction.categories.map(
                          (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                        provider.setFilterCategory(value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                                provider.setFilterDateRange(_startDate, _endDate);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _startDate != null
                                  ? DateFormat('MMM dd').format(_startDate!)
                                  : 'Start Date',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('to'),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                                provider.setFilterDateRange(_startDate, _endDate);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _endDate != null
                                  ? DateFormat('MMM dd').format(_endDate!)
                                  : 'End Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by note',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: provider.setSearchQuery,
                    ),
                  ],
                ),
              ),
            ),

          // Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${transactions.length} transactions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total: ${currencyFormat.format(transactions.fold(0.0, (sum, t) => sum + (t.type == 'expense' ? -t.amount : t.amount)))}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transaction List
          if (transactions.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No transactions found',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = transactions[index];
                  final isExpense = tx.type == 'expense';
                  final color = isExpense ? Colors.red : Colors.green;

                  return Dismissible(
                    key: Key(tx.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: const Text('Are you sure you want to delete this transaction?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      provider.deleteTransaction(tx.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction deleted')),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.1),
                        child: Icon(
                          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(tx.category),
                      subtitle: Text(
                        tx.note.isNotEmpty ? tx.note : DateFormat('MMM dd, yyyy').format(tx.date),
                      ),
                      trailing: Text(
                        '${isExpense ? '-' : '+'}${currencyFormat.format(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(transaction: tx),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: transactions.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
