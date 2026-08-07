import 'package:equatable/equatable.dart';
import '../../core/utils/date_formatter.dart';

/// Corresponde exactamente a [AccessResponseDto] del backend.
/// Campos: id_record, vehicle_plate, date_time, type, status
class AccessRecordModel extends Equatable {
  const AccessRecordModel({
    required this.idRecord,
    required this.vehiclePlate,
    required this.dateTime,
    required this.type,
    required this.status,
  });

  final int idRecord;
  final String vehiclePlate;

  /// String ISO8601 tal como llega del backend.
  final String dateTime;

  /// "ENTRADA" | "SALIDA" | "MANUAL"
  final String type;

  /// "APROBADO"
  final String status;

  factory AccessRecordModel.fromJson(Map<String, dynamic> json) =>
      AccessRecordModel(
        idRecord: json['id_record'] as int,
        vehiclePlate: json['vehicle_plate'] as String,
        dateTime: json['date_time'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
      );

  /// DateTime parseado para mostrar en la UI.
  DateTime get parsedDateTime => DateFormatter.parse(dateTime);

  bool get isEntrada => type == 'ENTRADA';
  bool get isSalida => type == 'SALIDA';
  bool get isManual => type == 'MANUAL';

  @override
  List<Object?> get props => [idRecord, vehiclePlate, dateTime, type, status];
}
