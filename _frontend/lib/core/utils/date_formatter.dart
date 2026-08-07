import 'package:intl/intl.dart';

/// Utilidades de formato de fecha para AccessRecord y demás modelos.
class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final _isoFormat2 = DateFormat("yyyy-MM-dd HH:mm:ss");

  /// Convierte el string del backend a DateTime local.
  /// El backend guarda en UTC sin marcador de zona ("2026-07-27T10:30:00"
  /// o "2026-07-27 10:30:00"), por lo que se parsea como UTC y se
  /// convierte a la zona horaria del dispositivo.
  static DateTime parse(String raw) {
    try {
      return _isoFormat.parse(raw, true).toLocal();
    } catch (_) {
      try {
        return _isoFormat2.parse(raw, true).toLocal();
      } catch (_) {
        final parsed = DateTime.tryParse(raw);
        if (parsed == null) return DateTime.now();
        return parsed.isUtc ? parsed.toLocal() : parsed;
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
