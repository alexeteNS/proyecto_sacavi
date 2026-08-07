import 'package:equatable/equatable.dart';

/// Corresponde exactamente a [DeviceResponseDto] del backend.
/// Campos: id_device, name, location, device_key, status, last_connection
class DeviceModel extends Equatable {
  const DeviceModel({
    required this.idDevice,
    required this.name,
    required this.location,
    required this.deviceKey,
    required this.status,
    this.lastConnection,
  });

  final int idDevice;
  final String name;
  final String location;
  final String deviceKey;

  /// "ONLINE" | "OFFLINE"
  final String status;
  final String? lastConnection;

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        idDevice: json['id_device'] as int,
        name: json['name'] as String,
        location: json['location'] as String,
        deviceKey: json['device_key'] as String,
        status: json['status'] as String,
        lastConnection: json['last_connection'] as String?,
      );

  bool get isOnline => status == 'ONLINE';

  @override
  List<Object?> get props =>
      [idDevice, name, location, deviceKey, status, lastConnection];
}

/// Corresponde a [DeviceStatusResponse] del backend.
class DeviceStatusModel extends Equatable {
  const DeviceStatusModel({required this.online, required this.status});

  final bool online;
  final String status;

  factory DeviceStatusModel.fromJson(Map<String, dynamic> json) =>
      DeviceStatusModel(
        online: json['online'] as bool,
        status: json['status'] as String,
      );

  /// Alias para compatibilidad con código que usa isOnline
  bool get isOnline => online;

  @override
  List<Object?> get props => [online, status];
}
