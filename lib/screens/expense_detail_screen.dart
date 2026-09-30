import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'add_edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
  });

  void _showDeleteConfirmation(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete "${expense.description}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              provider.deleteExpense(expense.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense deleted'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenseList = provider.expenses.where((e) => e.id == expenseId).toList();
    if (expenseList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense Details')),
        body: const Center(child: Text('Expense not found')),
      );
    }

    final expense = expenseList.first;
    final category = expense.categoryDetails;
    final payment = expense.paymentDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditExpenseScreen(expenseToEdit: expense),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: () => _showDeleteConfirmation(context, expense),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount & Category Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, size: 32, color: category.color),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    expense.description,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(
                      expense.amount,
                      symbol: provider.currencySymbol,
                      currencyCode: provider.currencyCode,
                    ),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detailed Property List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Category',
                    value: expense.category,
                    icon: category.icon,
                    iconColor: category.color,
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    label: 'Payment Method',
                    value: expense.paymentMethod,
                    icon: payment.icon,
                    iconColor: expense.isCash ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    badge: expense.isOnline ? 'Online' : 'Cash',
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    label: 'Date',
                    value: DateFormatter.formatFullDate(expense.date),
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF6366F1),
                    isDark: isDark,
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Notes',
                      value: expense.notes!,
                      icon: Icons.note_alt_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons (Edit & Delete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, expense),
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                    label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditExpenseScreen(expenseToEdit: expense),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    String? badge,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
      ],
    );
  }
}
