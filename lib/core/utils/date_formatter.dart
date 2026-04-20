import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String format(DateTime date, {String locale = 'en'}) {
    final fmt = DateFormat.yMMMd(locale);
    return fmt.format(date);
  }

  static String formatShort(DateTime date, {String locale = 'en'}) {
    final fmt = DateFormat.yMd(locale);
    return fmt.format(date);
  }

  static String formatFull(DateTime date, {String locale = 'en'}) {
    final fmt = DateFormat.yMMMMd(locale);
    return fmt.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  static String monthYear(DateTime date, {String locale = 'en'}) {
    return DateFormat.yMMM(locale).format(date);
  }
}
