import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = '₹', String currencyCode = 'INR'}) {
    if (symbol == '₹' || currencyCode == 'INR') {
      return formatIndianCurrency(amount, symbol: symbol);
    } else {
      final formatter = NumberFormat.currency(
        symbol: '$symbol ',
        decimalDigits: amount % 1 == 0 ? 0 : 2,
      );
      return formatter.format(amount);
    }
  }

  static String formatIndianCurrency(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(absAmount % 1 == 0 ? 0 : 2).split('.');
    
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (integerPart.length > 3) {
      String lastThree = integerPart.substring(integerPart.length - 3);
      String remaining = integerPart.substring(0, integerPart.length - 3);
      
      final regExp = RegExp(r'(\d+?)(?=(\d{2})+$)');
      remaining = remaining.replaceAllMapped(regExp, (Match m) => '${m[1]},');
      integerPart = '$remaining,$lastThree';
    }

    final formatted = '$symbol$integerPart$decimalPart';
    return isNegative ? '-$formatted' : formatted;
  }
}
