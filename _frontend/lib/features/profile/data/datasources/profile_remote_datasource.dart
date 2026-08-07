import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/user_model.dart';
abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String name, required String email});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get('/user/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) throw failureFromDio(e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({required String name, required String email}) async {
    try {
      final response = await apiClient.put('/user/update', data: {
        'name': name,
        'email': email,
      });
      return UserModel.fromJson(response.data);
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }
}
