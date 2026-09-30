import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart' if (dart.library.io) '../services/database_helper.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../utils/date_formatter.dart';
import '../utils/sample_data.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  bool _isLoading = true;
  
  double _monthlyBudget = 10000.0;
  String _currencySymbol = '₹';
  String _currencyCode = 'INR';

  // Search and Filter fields
  String _searchQuery = '';
  String _dateFilter = 'All'; // All, Today, Yesterday, This Week, This Month, Custom
  String _paymentFilter = 'All'; // All, Cash, UPI, Debit Card, Credit Card, Bank Transfer, Other
  String _categoryFilter = 'All';
  DateTimeRange? _customDateRange;

  // Selected Analytics Month & Year
  int _analyticsMonth = DateTime.now().month;
  int _analyticsYear = DateTime.now().year;

  ExpenseProvider() {
    _initData();
  }

  // Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  double get monthlyBudget => _monthlyBudget;
  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;

  String get searchQuery => _searchQuery;
  String get dateFilter => _dateFilter;
  String get paymentFilter => _paymentFilter;
  String get categoryFilter => _categoryFilter;
  DateTimeRange? get customDateRange => _customDateRange;

  int get analyticsMonth => _analyticsMonth;
  int get analyticsYear => _analyticsYear;

  // --- INITIALIZATION ---

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _currencySymbol = prefs.getString('currency_symbol') ?? '₹';
      _currencyCode = prefs.getString('currency_code') ?? 'INR';
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? 10000.0;

      final fetchedExpenses = await DatabaseHelper.instance.getExpenses();
      
      if (fetchedExpenses.isEmpty) {
        // Automatically populate sample data on first launch for rich preview
        final samples = SampleData.getSampleExpenses();
        for (var sample in samples) {
          await DatabaseHelper.instance.insertExpense(sample);
        }
        _expenses.addAll(samples);
      } else {
        _expenses.addAll(fetchedExpenses);
      }

      final now = DateTime.now();
      final budgetObj = await DatabaseHelper.instance.getBudget(now.month, now.year);
      if (budgetObj != null) {
        _monthlyBudget = budgetObj.amount;
      }
    } catch (e) {
      debugPrint('Error initializing expense data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD OPERATIONS ---

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    notifyListeners();
    await DatabaseHelper.instance.insertExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
      await DatabaseHelper.instance.updateExpense(expense);
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteExpense(id);
  }

  Future<void> setMonthlyBudget(double amount, [int? month, int? year]) async {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    _monthlyBudget = amount;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', amount);

    final budget = Budget(
      id: 'b_${targetYear}_$targetMonth',
      amount: amount,
      month: targetMonth,
      year: targetYear,
    );
    await DatabaseHelper.instance.setBudget(budget);
  }

  Future<void> setCurrency(String symbol, String code) async {
    _currencySymbol = symbol;
    _currencyCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    await prefs.setString('currency_code', code);
  }

  Future<void> loadSampleData() async {
    await DatabaseHelper.instance.clearAllExpenses();
    _expenses.clear();
    final samples = SampleData.getSampleExpenses();
    for (var sample in samples) {
      await DatabaseHelper.instance.insertExpense(sample);
    }
    _expenses.addAll(samples);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await DatabaseHelper.instance.clearAllExpenses();
    _expenses.clear();
    notifyListeners();
  }

  // --- FILTER & SEARCH SETTERS ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateFilter(String filter, [DateTimeRange? range]) {
    _dateFilter = filter;
    _customDateRange = range;
    notifyListeners();
  }

  void setPaymentFilter(String filter) {
    _paymentFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String filter) {
    _categoryFilter = filter;
    notifyListeners();
  }

  void setAnalyticsMonth(int month, int year) {
    _analyticsMonth = month;
    _analyticsYear = year;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _dateFilter = 'All';
    _paymentFilter = 'All';
    _categoryFilter = 'All';
    _customDateRange = null;
    notifyListeners();
  }

  // --- FILTERED EXPENSES LIST ---

  List<Expense> get filteredExpenses {
    return _expenses.where((expense) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDesc = expense.description.toLowerCase().contains(query);
        final matchesCategory = expense.category.toLowerCase().contains(query);
        final matchesPayment = expense.paymentMethod.toLowerCase().contains(query);
        final matchesNotes = (expense.notes ?? '').toLowerCase().contains(query);
        if (!matchesDesc && !matchesCategory && !matchesPayment && !matchesNotes) {
          return false;
        }
      }

      // 2. Category Filter
      if (_categoryFilter != 'All' && expense.category != _categoryFilter) {
        return false;
      }

      // 3. Payment Filter
      if (_paymentFilter != 'All') {
        if (_paymentFilter == 'Cash' && !expense.isCash) return false;
        if (_paymentFilter == 'Online' && !expense.isOnline) return false;
        if (_paymentFilter != 'Cash' && _paymentFilter != 'Online' && expense.paymentMethod != _paymentFilter) {
          return false;
        }
      }

      // 4. Date Filter
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);

      if (_dateFilter == 'Today') {
        if (!DateFormatter.isSameDay(expenseDate, today)) return false;
      } else if (_dateFilter == 'Yesterday') {
        final yesterday = today.subtract(const Duration(days: 1));
        if (!DateFormatter.isSameDay(expenseDate, yesterday)) return false;
      } else if (_dateFilter == 'This Week') {
        final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
        if (expenseDate.isBefore(firstDayOfWeek)) return false;
      } else if (_dateFilter == 'This Month') {
        if (expenseDate.year != now.year || expenseDate.month != now.month) return false;
      } else if (_dateFilter == 'Custom' && _customDateRange != null) {
        final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
        final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
        if (expense.date.isBefore(start) || expense.date.isAfter(end)) return false;
      }

      return true;
    }).toList();
  }

  // --- CALCULATION HELPER FUNCTIONS ---

  double getTodayTotal() {
    final now = DateTime.now();
    return _expenses
        .where((e) => DateFormatter.isSameDay(e.date, now))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getWeekTotal() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return _expenses
        .where((e) => !e.date.isBefore(firstDayOfWeek))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getMonthTotal([int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return _expenses
        .where((e) => e.date.month == targetMonth && e.date.year == targetYear)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getMonthlyTotal(int year, int month) {
    return getMonthTotal(month, year);
  }

  double getCategoryTotal(String category, [int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return _expenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase() &&
            e.date.month == targetMonth && e.date.year == targetYear)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryTotals([int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;
    final Map<String, double> totals = {};

    for (var expense in _expenses) {
      if (expense.date.month == targetMonth && expense.date.year == targetYear) {
        totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
      }
    }
    return totals;
  }

  double getPaymentMethodTotal(String paymentMethod, [int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return _expenses
        .where((e) => e.paymentMethod.toLowerCase() == paymentMethod.toLowerCase() &&
            e.date.month == targetMonth && e.date.year == targetYear)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getPaymentMethodTotals([int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;
    final Map<String, double> totals = {};

    for (var expense in _expenses) {
      if (expense.date.month == targetMonth && expense.date.year == targetYear) {
        totals[expense.paymentMethod] = (totals[expense.paymentMethod] ?? 0.0) + expense.amount;
      }
    }
    return totals;
  }

  double getCashTotal([int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return _expenses
        .where((e) => e.isCash && e.date.month == targetMonth && e.date.year == targetYear)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getOnlineTotal([int? month, int? year]) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return _expenses
        .where((e) => e.isOnline && e.date.month == targetMonth && e.date.year == targetYear)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getRemainingBudget([int? month, int? year]) {
    final spent = getMonthTotal(month, year);
    return _monthlyBudget - spent;
  }

  List<Expense> getExpensesForDate(DateTime date) {
    return _expenses.where((e) => DateFormatter.isSameDay(e.date, date)).toList();
  }
}
