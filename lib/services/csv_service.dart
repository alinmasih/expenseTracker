import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/expense.dart';

class CsvService {
  static String generateCsvString(List<Expense> expenses) {
    List<List<dynamic>> rows = [
      ['Date', 'Amount', 'Description', 'Category', 'Payment Method', 'Notes'],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (var expense in expenses) {
      rows.add([
        dateFormat.format(expense.date),
        expense.amount,
        expense.description,
        expense.category,
        expense.paymentMethod,
        expense.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static Future<void> exportAndShareCsv(List<Expense> expenses) async {
    final csvContent = generateCsvString(expenses);

    if (kIsWeb) {
      // Web handle sharing/downloading csv content string
      await Share.share(csvContent, subject: 'SpendTrack_Expenses.csv');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/SpendTrack_Expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvContent);

      final xFile = XFile(path);
      await Share.shareXFiles([xFile], text: 'SpendTrack Expenses CSV Report');
    } catch (e) {
      debugPrint('Error sharing CSV file: $e');
      // Fallback share text directly if file system writing fails
      await Share.share(csvContent, subject: 'SpendTrack_Expenses.csv');
    }
  }
}
