import '../models/expense.dart';

class SampleData {
  static List<Expense> getSampleExpenses() {
    final now = DateTime.now();
    
    return [
      Expense(
        id: 'sample_1',
        amount: 250,
        description: 'Dinner at restaurant',
        category: 'Food',
        paymentMethod: 'UPI',
        date: now,
        notes: 'Dinner with friends at Royal Bistro',
      ),
      Expense(
        id: 'sample_2',
        amount: 120,
        description: 'Auto rickshaw ride',
        category: 'Transport',
        paymentMethod: 'Cash',
        date: now,
        notes: 'Commute to main office',
      ),
      Expense(
        id: 'sample_3',
        amount: 850,
        description: 'Cotton T-Shirt & Jeans',
        category: 'Shopping',
        paymentMethod: 'Debit Card',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Weekend shopping sale',
      ),
      Expense(
        id: 'sample_4',
        amount: 300,
        description: 'Cinema tickets',
        category: 'Entertainment',
        paymentMethod: 'UPI',
        date: now.subtract(const Duration(days: 1)),
        notes: 'PVR IMAX weekend show',
      ),
      Expense(
        id: 'sample_5',
        amount: 1200,
        description: 'Weekly grocery store',
        category: 'Groceries',
        paymentMethod: 'Cash',
        date: now.subtract(const Duration(days: 2)),
        notes: 'Vegetables, milk, fruits',
      ),
      Expense(
        id: 'sample_6',
        amount: 1800,
        description: 'Electricity & Broadband Bill',
        category: 'Bills',
        paymentMethod: 'UPI',
        date: now.subtract(const Duration(days: 3)),
        notes: 'Monthly utility payments',
      ),
      Expense(
        id: 'sample_7',
        amount: 450,
        description: 'Medicines & Supplements',
        category: 'Health',
        paymentMethod: 'Credit Card',
        date: now.subtract(const Duration(days: 4)),
        notes: 'Apollo Pharmacy order',
      ),
      Expense(
        id: 'sample_8',
        amount: 2500,
        description: 'Flutter Advanced Course',
        category: 'Education',
        paymentMethod: 'Bank Transfer',
        date: now.subtract(const Duration(days: 5)),
        notes: 'Udemy online certification',
      ),
      Expense(
        id: 'sample_9',
        amount: 3200,
        description: 'Weekend getaway flight',
        category: 'Travel',
        paymentMethod: 'Credit Card',
        date: now.subtract(const Duration(days: 7)),
        notes: 'IndiGo flight booking',
      ),
      Expense(
        id: 'sample_10',
        amount: 150,
        description: 'Notebooks & Pens',
        category: 'Other',
        paymentMethod: 'Cash',
        date: now.subtract(const Duration(days: 8)),
        notes: 'Stationery shop',
      ),
    ];
  }
}
