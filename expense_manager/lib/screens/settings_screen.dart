import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(themeProvider.isDark ? 'Dark theme active' : 'Light theme active'),
                      secondary: Icon(
                        themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                      ),
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Management
                  Text(
                    'Data Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: const Text('Export to JSON'),
                          subtitle: const Text('Save your data as a JSON file'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _exportData(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('Import from JSON'),
                          subtitle: const Text('Restore data from a JSON file'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _importData(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: const Text('Share Backup'),
                          subtitle: const Text('Share your data as a JSON file'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _shareData(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Expense Manager'),
                          subtitle: Text('Version 1.0.0'),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.phone_android),
                          title: Text('Offline First'),
                          subtitle: Text('All data stored locally on device'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final transactions = await DatabaseHelper.instance.exportTransactions();
      final budgets = await DatabaseHelper.instance.exportBudgets();

      final data = {
        'transactions': transactions,
        'budgets': budgets,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup.json');
      await file.writeAsString(jsonEncode(data));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to: ${file.path}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup.json');

      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No backup file found')),
          );
        }
        return;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      final transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      final budgets = List<Map<String, dynamic>>.from(data['budgets'] ?? []);

      await DatabaseHelper.instance.restoreTransactions(transactions);
      await DatabaseHelper.instance.restoreBudgets(budgets);

      if (context.mounted) {
        context.read<TransactionProvider>().loadTransactions();
        context.read<BudgetProvider>().loadBudget();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored ${transactions.length} transactions and ${budgets.length} budgets'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _shareData(BuildContext context) async {
    try {
      final transactions = await DatabaseHelper.instance.exportTransactions();
      final budgets = await DatabaseHelper.instance.exportBudgets();

      final data = {
        'transactions': transactions,
        'budgets': budgets,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup.json');
      await file.writeAsString(jsonEncode(data));

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Expense Manager Backup',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }
}
