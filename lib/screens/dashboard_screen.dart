import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/monthly_budget_card.dart';
import '../widgets/payment_breakdown_card.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentExpenses = provider.expenses.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh if needed
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Greeting Section
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.getGreeting(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SpendTrack',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF6366F1),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('SpendTrack is up to date!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Monthly Budget Card
                const MonthlyBudgetCard(),

                // Summary Stats Cards (Today, Week, Month)
                const SummaryCard(),

                const SizedBox(height: 12),

                // Payment Breakdown Card (Cash vs Online)
                const PaymentBreakdownCard(),

                const SizedBox(height: 16),

                // Recent Transactions Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      if (provider.expenses.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            if (onNavigateTab != null) {
                              onNavigateTab!(1); // Navigate to Expenses tab
                            }
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Recent Transactions List or Empty State
                if (recentExpenses.isEmpty)
                  const EmptyState(
                    title: 'No expenses yet',
                    message: 'Start tracking your spending by adding your first expense.',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentExpenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseTile(expense: recentExpenses[index]);
                    },
                  ),

                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}
