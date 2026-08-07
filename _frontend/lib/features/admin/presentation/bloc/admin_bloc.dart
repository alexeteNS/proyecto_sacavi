import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../../core/error/failures.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepositoryImpl repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<RegisterDevice>(_onRegisterDevice);
    on<CheckDeviceStatus>(_onCheckDeviceStatus);
    on<ChangeUserRole>(_onChangeUserRole);
  }

  Future<void> _onLoadAdminDashboard(LoadAdminDashboard event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      emit(const AdminDashboardLoaded());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onRegisterDevice(RegisterDevice event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final device = await repository.registerDevice(
        name: event.name,
        location: event.location,
        deviceKey: event.deviceKey,
      );
      emit(DeviceRegistered(device));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onCheckDeviceStatus(CheckDeviceStatus event, Emitter<AdminState> emit) async {
    try {
      final status = await repository.getDeviceStatus(event.deviceKey);
      emit(AdminDashboardLoaded(deviceStatus: status));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onChangeUserRole(ChangeUserRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final user = await repository.changeUserRole(event.userId, event.roleId);
      emit(RoleChanged(user));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }
}
