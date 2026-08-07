import 'package:equatable/equatable.dart';
import 'package:sacavi_app/shared/models/access_record_model.dart';
import 'package:sacavi_app/shared/models/device_model.dart';
import 'package:sacavi_app/shared/models/vehicle_request_model.dart';

class DashboardSummary extends Equatable {
  final int users;
  final int vehicles;
  final int vehicleRequestsPending;
  final int vehicleRequestsInRevision;
  final int devicesOnline;
  final int accessToday;
  final int entriesToday;
  final int exitsToday;

  const DashboardSummary({
    required this.users,
    required this.vehicles,
    required this.vehicleRequestsPending,
    required this.vehicleRequestsInRevision,
    required this.devicesOnline,
    required this.accessToday,
    required this.entriesToday,
    required this.exitsToday,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      users: json['users'] ?? 0,
      vehicles: json['vehicles'] ?? 0,
      vehicleRequestsPending: json['vehicle_requests_pending'] ?? 0,
      vehicleRequestsInRevision: json['vehicle_requests_in_revision'] ?? 0,
      devicesOnline: json['devices_online'] ?? 0,
      accessToday: json['access_today'] ?? 0,
      entriesToday: json['entries_today'] ?? 0,
      exitsToday: json['exits_today'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        users,
        vehicles,
        vehicleRequestsPending,
        vehicleRequestsInRevision,
        devicesOnline,
        accessToday,
        entriesToday,
        exitsToday,
      ];
}

class DashboardDto extends Equatable {
  final DashboardSummary summary;
  final List<AccessRecordModel> recentAccess;
  final List<VehicleRequest> pendingRequests;
  final List<DeviceModel> devices;

  const DashboardDto({
    required this.summary,
    required this.recentAccess,
    required this.pendingRequests,
    required this.devices,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    return DashboardDto(
      summary: DashboardSummary.fromJson(json['summary']),
      recentAccess: (json['recent_access'] as List)
          .map((item) => AccessRecordModel.fromJson(item))
          .toList(),
      pendingRequests: (json['pending_requests'] as List)
          .map((item) => VehicleRequest.fromJson(item))
          .toList(),
      devices: (json['devices'] as List)
          .map((item) => DeviceModel.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [summary, recentAccess, pendingRequests, devices];
}
