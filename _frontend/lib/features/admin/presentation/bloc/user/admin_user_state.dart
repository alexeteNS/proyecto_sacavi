import 'package:equatable/equatable.dart';
import '../../../../../shared/models/admin_user_model.dart';

abstract class AdminUserState extends Equatable {
  const AdminUserState();

  @override
  List<Object?> get props => [];
}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUsersLoaded extends AdminUserState {
  final List<AdminUserResponse> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminUserActionSuccess extends AdminUserState {
  final String action; // 'created', 'updated', 'deleted', 'password_reset'

  const AdminUserActionSuccess(this.action);

  @override
  List<Object?> get props => [action];
}

class AdminUserError extends AdminUserState {
  final String message;

  const AdminUserError(this.message);

  @override
  List<Object?> get props => [message];
}
