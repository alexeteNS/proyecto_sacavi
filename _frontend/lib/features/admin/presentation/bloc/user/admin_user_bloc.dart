import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import 'admin_user_event.dart';
import 'admin_user_state.dart';

class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final AdminRepositoryImpl repository;

  AdminUserBloc({required this.repository}) : super(AdminUserInitial()) {
    on<LoadAdminUsers>(_onLoadAdminUsers);
    on<CreateAdminUser>(_onCreateAdminUser);
    on<UpdateAdminUser>(_onUpdateAdminUser);
    on<DeleteAdminUser>(_onDeleteAdminUser);
    on<ResetAdminUserPassword>(_onResetAdminUserPassword);
  }

  Future<void> _onLoadAdminUsers(
      LoadAdminUsers event, Emitter<AdminUserState> emit) async {
    emit(AdminUserLoading());
    try {
      final users = await repository.getUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onCreateAdminUser(
      CreateAdminUser event, Emitter<AdminUserState> emit) async {
    try {
      await repository.createUser(event.data);
      emit(const AdminUserActionSuccess('created'));
      add(LoadAdminUsers());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onUpdateAdminUser(
      UpdateAdminUser event, Emitter<AdminUserState> emit) async {
    try {
      await repository.updateUser(event.id, event.data);
      emit(const AdminUserActionSuccess('updated'));
      add(LoadAdminUsers());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onDeleteAdminUser(
      DeleteAdminUser event, Emitter<AdminUserState> emit) async {
    try {
      await repository.deleteUser(event.id);
      emit(const AdminUserActionSuccess('deleted'));
      add(LoadAdminUsers());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onResetAdminUserPassword(
      ResetAdminUserPassword event, Emitter<AdminUserState> emit) async {
    try {
      await repository.resetPassword(event.id, event.newPassword);
      emit(const AdminUserActionSuccess('password_reset'));
    } catch (e) {
      _emitError(e, emit);
    }
  }

  void _emitError(dynamic e, Emitter<AdminUserState> emit) {
    if (e is Failure) {
      emit(AdminUserError(e.message));
    } else {
      emit(AdminUserError(e.toString()));
    }
  }
}
