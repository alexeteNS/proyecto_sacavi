import 'package:equatable/equatable.dart';

abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminUsers extends AdminUserEvent {}

class CreateAdminUser extends AdminUserEvent {
  final Map<String, dynamic> data;
  const CreateAdminUser(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateAdminUser extends AdminUserEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateAdminUser(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteAdminUser extends AdminUserEvent {
  final int id;
  const DeleteAdminUser(this.id);

  @override
  List<Object?> get props => [id];
}

class ResetAdminUserPassword extends AdminUserEvent {
  final int id;
  final String newPassword;
  const ResetAdminUserPassword(this.id, this.newPassword);

  @override
  List<Object?> get props => [id, newPassword];
}
