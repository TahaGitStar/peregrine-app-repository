import 'package:intl/intl.dart';

class DateFormatter {
  // Arabic month names
  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'اليوم ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'أمس ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
    }
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
  
  /// Format a date range in Arabic
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    // Format dates in Arabic style
    final startDay = startDate.day;
    final startMonth = _arabicMonths[startDate.month - 1];
    final startYear = startDate.year;
    
    final endDay = endDate.day;
    final endMonth = _arabicMonths[endDate.month - 1];
    final endYear = endDate.year;
    
    // Check if dates are in the same year
    if (startYear == endYear) {
      // Check if dates are in the same month
      if (startDate.month == endDate.month) {
        return '$startDay - $endDay $startMonth $startYear';
      } else {
        return '$startDay $startMonth - $endDay $endMonth $startYear';
      }
    } else {
      return '$startDay $startMonth $startYear - $endDay $endMonth $endYear';
    }
  }
  
  /// Format a single date in Arabic
  static String formatDate(DateTime date) {
    final day = date.day;
    final month = _arabicMonths[date.month - 1];
    final year = date.year;
    
    return '$day $month $year';
  }
}