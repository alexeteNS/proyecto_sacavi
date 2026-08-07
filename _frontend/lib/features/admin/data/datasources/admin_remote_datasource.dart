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

  // New admin endpoints
  Future<Map<String, dynamic>> getDashboard();
  Future<List<dynamic>> getUsers();
  Future<Map<String, dynamic>> getUser(int id);
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<void> resetPassword(int id, String newPassword);
  Future<List<dynamic>> getLogs(Map<String, dynamic> filters);
  Future<List<dynamic>> getAccessHistory(Map<String, dynamic> filters);
  Future<Map<String, dynamic>> getAccessStats();

  // Vehicle Requests management
  Future<List<dynamic>> getAllVehicleRequests();
  Future<List<dynamic>> getPendingVehicleRequests();
  Future<List<dynamic>> getInRevisionVehicleRequests();
  Future<Map<String, dynamic>> markRequestInRevision(int id);
  Future<Map<String, dynamic>> approveRequest(int id);
  Future<Map<String, dynamic>> rejectRequest(int id);
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

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await apiClient.get('/admin/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await apiClient.get('/admin/users');
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final response = await apiClient.get('/admin/users/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/admin/users', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/admin/users/$id', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await apiClient.delete('/admin/users/$id');
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword(int id, String newPassword) async {
    try {
      await apiClient.put('/admin/users/$id/reset-password', data: {
        'new_password': newPassword,
      });
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getLogs(Map<String, dynamic> filters) async {
    try {
      final response = await apiClient.get('/admin/logs', queryParameters: filters);
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getAccessHistory(Map<String, dynamic> filters) async {
    try {
      final response = await apiClient.get('/admin/access/history', queryParameters: filters);
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getAccessStats() async {
    try {
      final response = await apiClient.get('/admin/access/stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getAllVehicleRequests() async {
    try {
      final response = await apiClient.get('/admin/vehicle-requests');
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getPendingVehicleRequests() async {
    try {
      final response = await apiClient.get('/admin/vehicle-requests/pending');
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getInRevisionVehicleRequests() async {
    try {
      final response = await apiClient.get('/admin/vehicle-requests/in-revision');
      return response.data as List<dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> markRequestInRevision(int id) async {
    try {
      final response = await apiClient.put('/admin/vehicle-requests/$id/in-revision');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> approveRequest(int id) async {
    try {
      final response = await apiClient.put('/admin/vehicle-requests/$id/approve');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> rejectRequest(int id) async {
    try {
      final response = await apiClient.put('/admin/vehicle-requests/$id/reject');
      return response.data as Map<String, dynamic>;
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }
}
