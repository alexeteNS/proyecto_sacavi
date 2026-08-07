import 'package:equatable/equatable.dart';

sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final String plate;
  final String brand;
  final String model;
  final String color;

  const AddVehicle({required this.plate, required this.brand, required this.model, required this.color});

  @override
  List<Object?> get props => [plate, brand, model, color];
}

class DeleteVehicle extends VehicleEvent {
  final int id;

  const DeleteVehicle(this.id);

  @override
  List<Object?> get props => [id];
}
