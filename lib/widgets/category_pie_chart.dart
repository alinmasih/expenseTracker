import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class CategoryPieChart extends StatefulWidget {
  final int month;
  final int year;

  const CategoryPieChart({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryTotals = provider.getCategoryTotals(widget.month, widget.year);
    final totalSpent = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (totalSpent == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No expense data for this month',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final entries = categoryTotals.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: List.generate(entries.length, (i) {
                final isTouched = i == touchedIndex;
                final fontSize = isTouched ? 16.0 : 12.0;
                final radius = isTouched ? 58.0 : 50.0;
                final category = ExpenseCategory.getByName(entries[i].key);
                final percentage = (entries[i].value / totalSpent) * 100;

                return PieChartSectionData(
                  color: category.color,
                  value: entries[i].value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final category = ExpenseCategory.getByName(entry.key);
            final percentage = (entry.value / totalSpent) * 100;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(category.icon, size: 16, color: category.color),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(
                      entry.value,
                      symbol: provider.currencySymbol,
                      currencyCode: provider.currencyCode,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
