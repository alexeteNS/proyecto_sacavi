import 'package:intl/intl.dart';

/// Utilidades de formato de fecha para AccessRecord y demás modelos.
class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final _isoFormat2 = DateFormat("yyyy-MM-dd HH:mm:ss");

  /// Convierte el string ISO8601 del backend a DateTime.
  /// El backend puede devolver "2026-07-27T10:30:00" o "2026-07-27 10:30:00".
  static DateTime parse(String raw) {
    try {
      return _isoFormat.parse(raw);
    } catch (_) {
      try {
        return _isoFormat2.parse(raw);
      } catch (_) {
        return DateTime.tryParse(raw) ?? DateTime.now();
      }
    }
  }

  static String toDate(DateTime dt) => _dateFormat.format(dt);
  static String toTime(DateTime dt) => _timeFormat.format(dt);
  static String toDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// Tiempo relativo: "Hace 3 seg", "Hace 5 min", "Hace 2 hr"
  static String elapsed(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds} seg';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    return 'Hace ${diff.inHours} hr';
  }
}
