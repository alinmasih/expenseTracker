import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ExpenseCategory> categories = [
    ExpenseCategory(name: 'Food', icon: Icons.fastfood_rounded, color: Color(0xFFFF6B6B)),
    ExpenseCategory(name: 'Transport', icon: Icons.directions_car_rounded, color: Color(0xFF4ECDC4)),
    ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFFFFBE0B)),
    ExpenseCategory(name: 'Education', icon: Icons.school_rounded, color: Color(0xFF3A86FF)),
    ExpenseCategory(name: 'Entertainment', icon: Icons.movie_rounded, color: Color(0xFF8338EC)),
    ExpenseCategory(name: 'Health', icon: Icons.medical_services_rounded, color: Color(0xFF06D6A0)),
    ExpenseCategory(name: 'Bills', icon: Icons.receipt_long_rounded, color: Color(0xFFFB5607)),
    ExpenseCategory(name: 'Groceries', icon: Icons.local_grocery_store_rounded, color: Color(0xFF2A9D8F)),
    ExpenseCategory(name: 'Travel', icon: Icons.flight_takeoff_rounded, color: Color(0xFF9C27B0)),
    ExpenseCategory(name: 'Other', icon: Icons.category_rounded, color: Color(0xFF6C757D)),
  ];

  static ExpenseCategory getByName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => categories.last,
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final bool isOnline;

  const PaymentMethod({
    required this.name,
    required this.icon,
    required this.isOnline,
  });

  static const List<PaymentMethod> methods = [
    PaymentMethod(name: 'Cash', icon: Icons.payments_rounded, isOnline: false),
    PaymentMethod(name: 'UPI', icon: Icons.qr_code_scanner_rounded, isOnline: true),
    PaymentMethod(name: 'Debit Card', icon: Icons.credit_card_rounded, isOnline: true),
    PaymentMethod(name: 'Credit Card', icon: Icons.credit_score_rounded, isOnline: true),
    PaymentMethod(name: 'Bank Transfer', icon: Icons.account_balance_rounded, isOnline: true),
    PaymentMethod(name: 'Other', icon: Icons.more_horiz_rounded, isOnline: true),
  ];

  static PaymentMethod getByName(String name) {
    return methods.firstWhere(
      (m) => m.name.toLowerCase() == name.toLowerCase(),
      orElse: () => methods.first,
    );
  }

  static bool isPaymentOnline(String name) {
    final method = getByName(name);
    return method.isOnline;
  }
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOnline => PaymentMethod.isPaymentOnline(paymentMethod);
  bool get isCash => !isOnline;

  ExpenseCategory get categoryDetails => ExpenseCategory.getByName(category);
  PaymentMethod get paymentDetails => PaymentMethod.getByName(paymentMethod);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      category: map['category'] as String,
      paymentMethod: map['paymentMethod'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
