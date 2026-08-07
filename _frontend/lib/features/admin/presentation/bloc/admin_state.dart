import 'package:equatable/equatable.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final DeviceStatusModel? deviceStatus;

  const AdminDashboardLoaded({this.deviceStatus});

  @override
  List<Object?> get props => [deviceStatus];
}

class DeviceRegistered extends AdminState {
  final DeviceModel device;

  const DeviceRegistered(this.device);

  @override
  List<Object?> get props => [device];
}

class RoleChanged extends AdminState {
  final UserModel user;

  const RoleChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
