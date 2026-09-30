class Budget {
  final String id;
  final double amount;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  Budget copyWith({
    String? id,
    double? amount,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
