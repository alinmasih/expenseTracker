import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/daily_bar_chart.dart';
import '../widgets/payment_method_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  void _showMonthYearPicker(BuildContext context, ExpenseProvider provider) async {
    final now = DateTime.now();
    int selectedMonth = provider.analyticsMonth;
    int selectedYear = provider.analyticsYear;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Month & Year'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          items: List.generate(12, (i) => i + 1).map((m) {
                            return DropdownMenuItem<int>(
                              value: m,
                              child: Text(DateFormat('MMMM').format(DateTime(2026, m))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedMonth = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          items: [now.year - 1, now.year, now.year + 1].map((y) {
                            return DropdownMenuItem<int>(
                              value: y,
                              child: Text('$y'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedYear = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.setAnalyticsMonth(selectedMonth, selectedYear);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMonth = provider.analyticsMonth;
    final selectedYear = provider.analyticsYear;
    final monthTotal = provider.getMonthTotal(selectedMonth, selectedYear);
    final monthName = DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _showMonthYearPicker(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector & Total Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            monthName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white70, size: 20),
                            onPressed: () => _showMonthYearPicker(context, provider),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Monthly Spending',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(
                      monthTotal,
                      symbol: provider.currencySymbol,
                      currencyCode: provider.currencyCode,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 1. Spending by Category (Pie Chart)
            _buildChartSectionCard(
              context,
              title: 'Spending by Category',
              subtitle: 'Breakdown across expense categories',
              icon: Icons.pie_chart_rounded,
              isDark: isDark,
              child: CategoryPieChart(month: selectedMonth, year: selectedYear),
            ),

            const SizedBox(height: 16),

            // 2. Daily Spending (Bar Chart)
            _buildChartSectionCard(
              context,
              title: 'Daily Spending Trend',
              subtitle: 'Expenses logged day by day',
              icon: Icons.bar_chart_rounded,
              isDark: isDark,
              child: DailyBarChart(month: selectedMonth, year: selectedYear),
            ),

            const SizedBox(height: 16),

            // 3. Payment Method Comparison Chart
            _buildChartSectionCard(
              context,
              title: 'Payment Method Breakdown',
              subtitle: 'Comparing Cash vs UPI, Cards & Bank Transfer',
              icon: Icons.payments_rounded,
              isDark: isDark,
              child: PaymentMethodChart(month: selectedMonth, year: selectedYear),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
