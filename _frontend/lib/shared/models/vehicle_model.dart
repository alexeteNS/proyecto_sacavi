import 'package:equatable/equatable.dart';

/// Corresponde exactamente a [VehicleResponseDto] del backend.
/// Campos: id_vehicle, plate, brand, model, color
class VehicleModel extends Equatable {
  const VehicleModel({
    required this.idVehicle,
    required this.plate,
    required this.brand,
    required this.model,
    required this.color,
  });

  final int idVehicle;
  final String plate;
  final String brand;
  final String model;
  final String color;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        idVehicle: json['id_vehicle'] as int,
        plate: json['plate'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        color: json['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id_vehicle': idVehicle,
        'plate': plate,
        'brand': brand,
        'model': model,
        'color': color,
      };

  /// Nombre para mostrar en las tarjetas.
  String get displayName => '$brand $model';
  String get displayInfo => '$plate | $color';

  @override
  List<Object?> get props => [idVehicle, plate, brand, model, color];
}
