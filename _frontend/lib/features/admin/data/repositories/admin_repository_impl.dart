import '../datasources/admin_remote_datasource.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/models/admin_user_model.dart';
import '../../../../shared/models/system_log_model.dart';
import '../../../../shared/models/vehicle_request_model.dart';
import '../../../../shared/models/access_history_model.dart';

class AdminRepositoryImpl {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  Future<DeviceStatusModel> getDeviceStatus(String deviceKey) {
    return remoteDataSource.getDeviceStatus(deviceKey);
  }

  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey}) {
    return remoteDataSource.registerDevice(name: name, location: location, deviceKey: deviceKey);
  }

  Future<UserModel> changeUserRole(int userId, int roleId) {
    return remoteDataSource.changeUserRole(userId, roleId);
  }
  
  Future<Map<String, dynamic>> getRolePermissions(int roleId) {
    return remoteDataSource.getRolePermissions(roleId);
  }

  Future<DashboardDto> getDashboard() async {
    final data = await remoteDataSource.getDashboard();
    return DashboardDto.fromJson(data);
  }

  Future<List<AdminUserResponse>> getUsers() async {
    final data = await remoteDataSource.getUsers();
    return data.map((e) => AdminUserResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminUserResponse> getUser(int id) async {
    final data = await remoteDataSource.getUser(id);
    return AdminUserResponse.fromJson(data);
  }

  Future<AdminUserResponse> createUser(Map<String, dynamic> userData) async {
    final data = await remoteDataSource.createUser(userData);
    return AdminUserResponse.fromJson(data);
  }

  Future<AdminUserResponse> updateUser(int id, Map<String, dynamic> userData) async {
    final data = await remoteDataSource.updateUser(id, userData);
    return AdminUserResponse.fromJson(data);
  }

  Future<void> deleteUser(int id) {
    return remoteDataSource.deleteUser(id);
  }

  Future<void> resetPassword(int id, String newPassword) {
    return remoteDataSource.resetPassword(id, newPassword);
  }

  Future<List<SystemLogModel>> getLogs(Map<String, dynamic> filters) async {
    final data = await remoteDataSource.getLogs(filters);
    return data.map((e) => SystemLogModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AccessHistoryModel>> getAccessHistory(Map<String, dynamic> filters) async {
    final data = await remoteDataSource.getAccessHistory(filters);
    return data.map((e) => AccessHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AccessStatsModel> getAccessStats() async {
    final data = await remoteDataSource.getAccessStats();
    return AccessStatsModel.fromJson(data);
  }

  Future<List<VehicleRequest>> getAllVehicleRequests() async {
    final data = await remoteDataSource.getAllVehicleRequests();
    return data.map((e) => VehicleRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VehicleRequest>> getPendingVehicleRequests() async {
    final data = await remoteDataSource.getPendingVehicleRequests();
    return data.map((e) => VehicleRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VehicleRequest>> getInRevisionVehicleRequests() async {
    final data = await remoteDataSource.getInRevisionVehicleRequests();
    return data.map((e) => VehicleRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VehicleRequest> markRequestInRevision(int id) async {
    final data = await remoteDataSource.markRequestInRevision(id);
    return VehicleRequest.fromJson(data);
  }

  Future<VehicleRequest> approveRequest(int id) async {
    final data = await remoteDataSource.approveRequest(id);
    return VehicleRequest.fromJson(data);
  }

  Future<VehicleRequest> rejectRequest(int id) async {
    final data = await remoteDataSource.rejectRequest(id);
    return VehicleRequest.fromJson(data);
  }
}
