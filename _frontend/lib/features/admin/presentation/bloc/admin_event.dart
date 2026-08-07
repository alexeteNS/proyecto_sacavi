import 'package:equatable/equatable.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {}

class RegisterDevice extends AdminEvent {
  final String name;
  final String location;
  final String deviceKey;

  const RegisterDevice({required this.name, required this.location, required this.deviceKey});

  @override
  List<Object?> get props => [name, location, deviceKey];
}

class CheckDeviceStatus extends AdminEvent {
  final String deviceKey;

  const CheckDeviceStatus(this.deviceKey);

  @override
  List<Object?> get props => [deviceKey];
}

class ChangeUserRole extends AdminEvent {
  final int userId;
  final int roleId;

  const ChangeUserRole({required this.userId, required this.roleId});

  @override
  List<Object?> get props => [userId, roleId];
}
