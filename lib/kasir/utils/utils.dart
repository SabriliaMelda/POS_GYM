import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateTimeWithSeconds(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  static DateTime parseDate(String dateStr) {
    return DateFormat('dd/MM/yyyy').parse(dateStr);
  }

  static String getDayOfWeek(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static String getRelativeDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else {
      return formatDate(dateTime);
    }
  }
}

class CurrencyUtils {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  static String formatCurrencySimple(double amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  static double parseCurrency(String currencyStr) {
    return double.parse(currencyStr.replaceAll(RegExp(r'[^0-9.]'), ''));
  }
}

class StringUtils {
  static String generateMemberId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MBR-$timestamp';
  }

  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TRX-$timestamp';
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^(\+62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
}
