import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _relativeDate = DateFormat('dd MMM', 'id_ID');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return _relativeDate.format(date);
  }

  static String formatMemberSince(DateTime date) {
    return 'Anggota sejak ${_dateFormat.format(date)}';
  }
}
