import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/filter_bottom_sheet.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (var expense in expenses) {
      final key = DateFormatter.formatDateHeader(expense.date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(expense);
    }
    return grouped;
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredExpenses = provider.filteredExpenses;
    final groupedExpenses = _groupExpensesByDate(filteredExpenses);

    final bool hasActiveFilters = provider.dateFilter != 'All' ||
        provider.paymentFilter != 'All' ||
        provider.categoryFilter != 'All' ||
        provider.searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _openFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search description, category...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _openFilterBottomSheet(context),
                  icon: const Icon(Icons.tune_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: hasActiveFilters
                        ? const Color(0xFF6366F1)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    foregroundColor: hasActiveFilters ? Colors.white : const Color(0xFF6366F1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Filter Summary Chips
          if (hasActiveFilters)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (provider.dateFilter != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text('Date: ${provider.dateFilter}'),
                        onDeleted: () => provider.setDateFilter('All'),
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
                      ),
                    ),
                  if (provider.paymentFilter != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text('Payment: ${provider.paymentFilter}'),
                        onDeleted: () => provider.setPaymentFilter('All'),
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
                      ),
                    ),
                  if (provider.categoryFilter != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text('Category: ${provider.categoryFilter}'),
                        onDeleted: () => provider.setCategoryFilter('All'),
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      provider.resetFilters();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Grouped Expense List or Empty State
          Expanded(
            child: filteredExpenses.isEmpty
                ? EmptyState(
                    title: hasActiveFilters ? 'No matching expenses' : 'No expenses yet',
                    message: hasActiveFilters
                        ? 'Try adjusting your search or filter settings.'
                        : 'Start tracking your spending by adding your first expense.',
                    showAddButton: !hasActiveFilters,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: groupedExpenses.length,
                    itemBuilder: (context, index) {
                      final header = groupedExpenses.keys.elementAt(index);
                      final dayExpenses = groupedExpenses[header]!;
                      final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Group Header
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  header,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Total: ${provider.currencySymbol}${dayTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Expenses under this date
                          ...dayExpenses.map((exp) => ExpenseTile(expense: exp)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
