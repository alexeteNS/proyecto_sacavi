import 'package:equatable/equatable.dart';
import '../../../../shared/models/vehicle_model.dart';

sealed class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;

  const VehicleLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
