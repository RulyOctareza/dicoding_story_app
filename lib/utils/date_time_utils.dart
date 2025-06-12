import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateTimeUtils {
  static String formatDateTime(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', locale);
    return formatter.format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final locale = Localizations.localeOf(context).languageCode;

    if (difference.inDays > 7) {
      return formatDateTime(dateTime, locale: locale);
    } else if (difference.inDays > 0) {
      if (locale == 'id') {
        return '${difference.inDays} hari yang lalu';
      }
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      if (locale == 'id') {
        return '${difference.inHours} jam yang lalu';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      if (locale == 'id') {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inMinutes} minutes ago';
    } else {
      return locale == 'id' ? 'Baru saja' : 'Just now';
    }
  }
}
