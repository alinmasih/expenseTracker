import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class PaymentMethodChart extends StatelessWidget {
  final int month;
  final int year;

  const PaymentMethodChart({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final paymentTotals = provider.getPaymentMethodTotals(month, year);
    final totalSpent = paymentTotals.values.fold(0.0, (sum, val) => sum + val);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (totalSpent == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No payment data recorded for this month',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final entries = paymentTotals.entries.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (paymentTotals.values.fold(0.0, (max, v) => v > max ? v : max)) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final methodName = entries[group.x.toInt()].key;
                      final amount = rod.toY;
                      return BarTooltipItem(
                        '$methodName\n',
                        const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.format(
                              amount,
                              symbol: provider.currencySymbol,
                              currencyCode: provider.currencyCode,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          final name = entries[idx].key;
                          final shortName = name.length > 6 ? '${name.substring(0, 5)}..' : name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              shortName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${provider.currencySymbol}${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final method = PaymentMethod.getByName(entry.key);
                  final isCash = !method.isOnline;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: isCash ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
