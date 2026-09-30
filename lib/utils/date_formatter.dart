import 'package:intl/intl.dart';

class DateFormatter {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 👋';
    } else if (hour < 17) {
      return 'Good Afternoon 👋';
    } else {
      return 'Good Evening 👋';
    }
  }

  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    final dayMonthStr = DateFormat('d MMMM').format(date).toUpperCase();

    if (targetDate == today) {
      return 'TODAY — $dayMonthStr';
    } else if (targetDate == yesterday) {
      return 'YESTERDAY — $dayMonthStr';
    } else {
      return DateFormat('EEEE — d MMMM yyyy').format(date).toUpperCase();
    }
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatMonthYear(int month, int year) {
    final dateTime = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(dateTime);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
