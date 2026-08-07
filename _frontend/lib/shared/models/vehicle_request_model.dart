import 'package:equatable/equatable.dart';

class VehicleRequest extends Equatable {
  final int idRequest;
  final int idUser;
  final String plate;
  final String brand;
  final String model;
  final String color;
  final String status; // PENDIENTE, EN_REVISION, APROBADO, RECHAZADO
  final String createdAt;
  final String? updatedAt;

  const VehicleRequest({
    required this.idRequest,
    required this.idUser,
    required this.plate,
    required this.brand,
    required this.model,
    required this.color,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) {
    return VehicleRequest(
      idRequest: json['id_request'],
      idUser: json['id_user'],
      plate: json['plate'],
      brand: json['brand'],
      model: json['model'],
      color: json['color'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_request': idRequest,
      'id_user': idUser,
      'plate': plate,
      'brand': brand,
      'model': model,
      'color': color,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  VehicleRequest copyWith({
    int? idRequest,
    int? idUser,
    String? plate,
    String? brand,
    String? model,
    String? color,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return VehicleRequest(
      idRequest: idRequest ?? this.idRequest,
      idUser: idUser ?? this.idUser,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        idRequest,
        idUser,
        plate,
        brand,
        model,
        color,
        status,
        createdAt,
        updatedAt,
      ];
}
