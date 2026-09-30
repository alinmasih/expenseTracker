import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayExpenses = provider.getExpensesForDate(_selectedDate);
    final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
      ),
      body: Column(
        children: [
          // Month Selector Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Calendar Grid Widget
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                // Weekday Headers (Mo Tu We Th Fr Sa Su)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) {
                    return SizedBox(
                      width: 36,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 6),

                // Days Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: 42, // 6 rows of 7
                  itemBuilder: (context, index) {
                    final dayOffset = index - (startingWeekday - 1);
                    if (dayOffset < 0 || dayOffset >= daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = dayOffset + 1;
                    final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
                    final isSelected = DateFormatter.isSameDay(cellDate, _selectedDate);
                    final isToday = DateFormatter.isSameDay(cellDate, DateTime.now());

                    final hasExpenses = provider.expenses.any((e) => DateFormatter.isSameDay(e.date, cellDate));

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = cellDate;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : (isToday
                                  ? const Color(0xFF6366F1).withOpacity(0.15)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(10),
                          border: isToday && !isSelected
                              ? Border.all(color: const Color(0xFF6366F1), width: 1.5)
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                fontSize: 14,
                              ),
                            ),
                            if (hasExpenses)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selected Day Total Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${DateFormatter.formatFullDate(_selectedDate)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Spent: ${CurrencyFormatter.format(dayTotal, symbol: provider.currencySymbol, currencyCode: provider.currencyCode)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Expenses for Selected Day
          Expanded(
            child: dayExpenses.isEmpty
                ? const EmptyState(
                    title: 'No expenses on this date',
                    message: 'Tap the + button to log expenses for this day.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: dayExpenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseTile(expense: dayExpenses[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
