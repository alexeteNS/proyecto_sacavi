import '../datasources/admin_remote_datasource.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

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
}
