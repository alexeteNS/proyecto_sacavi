import 'package:equatable/equatable.dart';

class DeviceInfoModel extends Equatable {
  final int idDevice;
  final String name;
  final String location;

  const DeviceInfoModel({
    required this.idDevice,
    required this.name,
    required this.location,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) => DeviceInfoModel(
        idDevice: json['id_device'] as int,
        name: json['name'] as String,
        location: json['location'] as String,
      );

  @override
  List<Object?> get props => [idDevice, name, location];
}

class VehicleInfoModel extends Equatable {
  final int idVehicle;
  final String plate;
  final String brand;
  final String model;
  final String color;

  const VehicleInfoModel({
    required this.idVehicle,
    required this.plate,
    required this.brand,
    required this.model,
    required this.color,
  });

  factory VehicleInfoModel.fromJson(Map<String, dynamic> json) => VehicleInfoModel(
        idVehicle: json['id_vehicle'] as int,
        plate: json['plate'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        color: json['color'] as String,
      );

  @override
  List<Object?> get props => [idVehicle, plate, brand, model, color];
}

class OwnerInfoModel extends Equatable {
  final int idUser;
  final String name;
  final String email;
  final String role;

  const OwnerInfoModel({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
  });

  factory OwnerInfoModel.fromJson(Map<String, dynamic> json) => OwnerInfoModel(
        idUser: json['id_user'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );

  @override
  List<Object?> get props => [idUser, name, email, role];
}

class AccessHistoryModel extends Equatable {
  final int idRecord;
  final String dateTime;
  final String type;
  final String status;
  final DeviceInfoModel? device;
  final VehicleInfoModel vehicle;
  final OwnerInfoModel owner;

  const AccessHistoryModel({
    required this.idRecord,
    required this.dateTime,
    required this.type,
    required this.status,
    this.device,
    required this.vehicle,
    required this.owner,
  });

  factory AccessHistoryModel.fromJson(Map<String, dynamic> json) => AccessHistoryModel(
        idRecord: json['id_record'] as int,
        dateTime: json['date_time'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        device: json['device'] != null ? DeviceInfoModel.fromJson(json['device'] as Map<String, dynamic>) : null,
        vehicle: VehicleInfoModel.fromJson(json['vehicle'] as Map<String, dynamic>),
        owner: OwnerInfoModel.fromJson(json['owner'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [idRecord, dateTime, type, status, device, vehicle, owner];
}

class AccessStatsModel extends Equatable {
  final int todayTotal;
  final int entradas;
  final int salidas;
  final int denied;
  final String avgTime;
  final int activeEsp32;

  const AccessStatsModel({
    required this.todayTotal,
    required this.entradas,
    required this.salidas,
    required this.denied,
    required this.avgTime,
    required this.activeEsp32,
  });

  factory AccessStatsModel.fromJson(Map<String, dynamic> json) => AccessStatsModel(
        todayTotal: json['today_total'] as int,
        entradas: json['entradas'] as int,
        salidas: json['salidas'] as int,
        denied: json['denied'] as int,
        avgTime: json['avg_time'] as String,
        activeEsp32: json['active_esp32'] as int,
      );

  @override
  List<Object?> get props => [todayTotal, entradas, salidas, denied, avgTime, activeEsp32];
}
