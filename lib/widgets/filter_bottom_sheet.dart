import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedDate;
  late String _selectedPayment;
  late String _selectedCategory;
  DateTimeRange? _customRange;

  final List<String> dateOptions = ['All', 'Today', 'Yesterday', 'This Week', 'This Month', 'Custom'];
  final List<String> paymentOptions = ['All', 'Cash', 'UPI', 'Debit Card', 'Credit Card', 'Bank Transfer', 'Other'];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    _selectedDate = provider.dateFilter;
    _selectedPayment = provider.paymentFilter;
    _selectedCategory = provider.categoryFilter;
    _customRange = provider.customDateRange;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = 'All';
                      _selectedPayment = 'All';
                      _selectedCategory = 'All';
                      _customRange = null;
                    });
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Date Filter Section
            _buildSectionTitle('Date Range', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dateOptions.map((opt) {
                final isSelected = _selectedDate == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (selected) {
                      if (opt == 'Custom') {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _customRange,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = 'Custom';
                            _customRange = picked;
                          });
                        }
                      } else {
                        setState(() {
                          _selectedDate = opt;
                          _customRange = null;
                        });
                      }
                    }
                  },
                  selectedColor: const Color(0xFF6366F1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Payment Filter Section
            _buildSectionTitle('Payment Method', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paymentOptions.map((opt) {
                final isSelected = _selectedPayment == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPayment = opt);
                    }
                  },
                  selectedColor: const Color(0xFF6366F1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Category Filter Section
            _buildSectionTitle('Category', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == 'All',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = 'All');
                  },
                  selectedColor: const Color(0xFF6366F1),
                  labelStyle: TextStyle(
                    color: _selectedCategory == 'All' ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                  ),
                ),
                ...ExpenseCategory.categories.map((cat) {
                  final isSelected = _selectedCategory == cat.name;
                  return ChoiceChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat.name);
                    },
                    selectedColor: cat.color,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  provider.setDateFilter(_selectedDate, _customRange);
                  provider.setPaymentFilter(_selectedPayment);
                  provider.setCategoryFilter(_selectedCategory);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[300] : const Color(0xFF334155),
      ),
    );
  }
}
