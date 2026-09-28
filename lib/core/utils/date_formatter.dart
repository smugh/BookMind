import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> indonesianDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> indonesianMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  static String formatFullIndonesianDateTime(DateTime date) {
    final dayName = indonesianDays[(date.weekday - 1).clamp(0, 6)];
    final monthName = indonesianMonths[(date.month - 1).clamp(0, 11)];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dayName, ${date.day} $monthName ${date.year} · $hour:$minute WIB';
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
