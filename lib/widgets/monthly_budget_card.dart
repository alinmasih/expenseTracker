import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class MonthlyBudgetCard extends StatelessWidget {
  const MonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final monthTotal = provider.getMonthTotal();
    final budget = provider.monthlyBudget;
    final remaining = provider.getRemainingBudget();
    final currentMonthName = DateFormat('MMMM').format(DateTime.now());

    double progress = budget > 0 ? (monthTotal / budget).clamp(0.0, 1.0) : 0.0;
    bool isExceeded = monthTotal > budget;
    bool isWarning = !isExceeded && progress >= 0.8;

    Color progressColor = isExceeded
        ? const Color(0xFFEF4444)
        : (isWarning ? const Color(0xFFF97316) : const Color(0xFF10B981));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentMonthName Spending',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isExceeded
                      ? Colors.red.withOpacity(0.25)
                      : (isWarning
                          ? Colors.orange.withOpacity(0.25)
                          : Colors.green.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: progressColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  isExceeded
                      ? '⚠️ Over Budget'
                      : (isWarning ? '⚡ Near Limit' : '✓ On Track'),
                  style: TextStyle(
                    color: isExceeded
                        ? const Color(0xFFFCA5A5)
                        : (isWarning
                            ? const Color(0xFFFDBA74)
                            : const Color(0xFF6EE7B7)),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(
                  monthTotal,
                  symbol: provider.currencySymbol,
                  currencyCode: provider.currencyCode,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${CurrencyFormatter.format(budget, symbol: provider.currencySymbol, currencyCode: provider.currencyCode)}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExceeded
                    ? 'Exceeded by ${CurrencyFormatter.format(remaining.abs(), symbol: provider.currencySymbol, currencyCode: provider.currencyCode)}'
                    : '${CurrencyFormatter.format(remaining, symbol: provider.currencySymbol, currencyCode: provider.currencyCode)} remaining',
                style: TextStyle(
                  color: isExceeded ? const Color(0xFFFCA5A5) : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
