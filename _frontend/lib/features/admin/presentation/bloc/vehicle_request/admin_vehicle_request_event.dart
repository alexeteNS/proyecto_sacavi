import 'package:equatable/equatable.dart';

abstract class AdminVehicleRequestEvent extends Equatable {
  const AdminVehicleRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicleRequests extends AdminVehicleRequestEvent {}

class ApproveVehicleRequest extends AdminVehicleRequestEvent {
  final int id;
  const ApproveVehicleRequest(this.id);

  @override
  List<Object?> get props => [id];
}

class RejectVehicleRequest extends AdminVehicleRequestEvent {
  final int id;
  const RejectVehicleRequest(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkVehicleRequestInRevision extends AdminVehicleRequestEvent {
  final int id;
  const MarkVehicleRequestInRevision(this.id);

  @override
  List<Object?> get props => [id];
}
