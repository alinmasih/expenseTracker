import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class DailyBarChart extends StatelessWidget {
  final int month;
  final int year;

  const DailyBarChart({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<int, double> dailyTotals = {};
    for (int i = 1; i <= daysInMonth; i++) {
      dailyTotals[i] = 0.0;
    }

    for (var expense in provider.expenses) {
      if (expense.date.month == month && expense.date.year == year) {
        final day = expense.date.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0.0) + expense.amount;
      }
    }

    final maxSpent = dailyTotals.values.fold(0.0, (max, val) => val > max ? val : max);

    if (maxSpent == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No daily spending recorded for this month',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxSpent * 1.25,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = group.x.toInt();
                  final amount = rod.toY;
                  return BarTooltipItem(
                    'Day $day\n',
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
                          color: Color(0xFF818CF8),
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
                    final day = value.toInt();
                    if (day % 5 == 1 || day == daysInMonth) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
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
            barGroups: dailyTotals.entries.map((entry) {
              final isPositive = entry.value > 0;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: isPositive ? const Color(0xFF6366F1) : Colors.transparent,
                    width: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
