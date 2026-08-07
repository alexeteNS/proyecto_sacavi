import 'package:equatable/equatable.dart';
import '../../../../../shared/models/vehicle_request_model.dart';

abstract class AdminVehicleRequestState extends Equatable {
  const AdminVehicleRequestState();

  @override
  List<Object?> get props => [];
}

class AdminVehicleRequestInitial extends AdminVehicleRequestState {}

class AdminVehicleRequestLoading extends AdminVehicleRequestState {}

class AdminVehicleRequestsLoaded extends AdminVehicleRequestState {
  final List<VehicleRequest> requests;

  const AdminVehicleRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class AdminVehicleRequestActionSuccess extends AdminVehicleRequestState {
  final VehicleRequest request;
  final String action; // 'approved', 'rejected', 'in_revision'

  const AdminVehicleRequestActionSuccess(this.request, this.action);

  @override
  List<Object?> get props => [request, action];
}

class AdminVehicleRequestError extends AdminVehicleRequestState {
  final String message;

  const AdminVehicleRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
