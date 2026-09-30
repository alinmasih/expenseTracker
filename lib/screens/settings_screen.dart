import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../services/csv_service.dart';
import '../utils/currency_formatter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '${provider.currencySymbol} ',
            labelText: 'Budget Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text.trim());
              if (newBudget != null && newBudget > 0) {
                provider.setMonthlyBudget(newBudget);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Monthly budget updated!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, ExpenseProvider provider) {
    final currencies = [
      {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee (INR)'},
      {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar (USD)'},
      {'symbol': '€', 'code': 'EUR', 'name': 'Euro (EUR)'},
      {'symbol': '£', 'code': 'GBP', 'name': 'British Pound (GBP)'},
      {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen (JPY)'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((curr) {
            final isSelected = provider.currencySymbol == curr['symbol'];
            return ListTile(
              leading: Text(
                curr['symbol']!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              title: Text(curr['name']!),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF6366F1)) : null,
              onTap: () {
                provider.setCurrency(curr['symbol']!, curr['code']!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently erase all saved expenses from your local storage. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All expense data cleared'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SpendTrack',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.account_balance_wallet, color: Color(0xFF6366F1), size: 36),
      ),
      children: const [
        Text(
          'SpendTrack is a modern, offline-first personal expense tracker designed to help you manage budgets, analyze spending trends, and categorize cash vs online expenses cleanly.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preferences', isDark),
            const SizedBox(height: 8),
            _buildSettingCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6366F1)),
                  title: const Text('Monthly Budget'),
                  subtitle: Text(
                    CurrencyFormatter.format(
                      expenseProvider.monthlyBudget,
                      symbol: expenseProvider.currencySymbol,
                      currencyCode: expenseProvider.currencyCode,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showBudgetDialog(context, expenseProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_money_rounded, color: Color(0xFF10B981)),
                  title: const Text('Currency Symbol'),
                  subtitle: Text('${expenseProvider.currencySymbol} (${expenseProvider.currencyCode})'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showCurrencyDialog(context, expenseProvider),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('Dark Mode'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                  activeColor: const Color(0xFF6366F1),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Data & Exports', isDark),
            const SizedBox(height: 8),
            _buildSettingCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: Color(0xFF3B82F6)),
                  title: const Text('Export Data to CSV'),
                  subtitle: const Text('Generate and share CSV report of expenses'),
                  trailing: const Icon(Icons.share_rounded),
                  onTap: () async {
                    if (expenseProvider.expenses.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No expenses available to export')),
                      );
                      return;
                    }
                    await CsvService.exportAndShareCsv(expenseProvider.expenses);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFF59E0B)),
                  title: const Text('Load Sample Data'),
                  subtitle: const Text('Populate mock expenses for testing'),
                  onTap: () async {
                    await expenseProvider.loadSampleData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sample expenses generated successfully!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444)),
                  title: const Text('Clear All Data', style: TextStyle(color: Color(0xFFEF4444))),
                  subtitle: const Text('Delete all saved expenses'),
                  onTap: () => _showClearDataConfirmation(context, expenseProvider),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('About', isDark),
            const SizedBox(height: 8),
            _buildSettingCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF0EA5E9)),
                  title: const Text('About SpendTrack'),
                  subtitle: const Text('Version 1.0.0 — Offline Expense Tracker'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: children),
    );
  }
}
