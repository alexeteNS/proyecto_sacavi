import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<DeviceStatusModel> getDeviceStatus(String deviceKey);
  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey});
  Future<UserModel> changeUserRole(int userId, int roleId);
  Future<Map<String, dynamic>> getRolePermissions(int roleId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DeviceStatusModel> getDeviceStatus(String deviceKey) async {
    try {
      final response = await apiClient.get('/device/status/$deviceKey');
      return DeviceStatusModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) throw failureFromDio(e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey}) async {
    try {
      final response = await apiClient.post('/device/register', data: {
        'name': name,
        'location': location,
        'device_key': deviceKey,
      });
      return DeviceModel.fromJson(response.data);
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> changeUserRole(int userId, int roleId) async {
    try {
      final response = await apiClient.put('/user/$userId/role', data: {
        'id_role': roleId,
      });
      return UserModel.fromJson(response.data);
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getRolePermissions(int roleId) async {
    try {
      final response = await apiClient.get('/roles/$roleId/permissions');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }
}
