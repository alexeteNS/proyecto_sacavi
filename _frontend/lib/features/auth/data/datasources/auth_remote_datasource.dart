import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';


/// Datasource remoto para autenticación.
/// Consume exactamente: POST /user/register, POST /user/login
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  /// POST /user/login
  /// Request: {email, password}
  /// Response: {token, user: UserResponseDto}
  Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/user/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data!;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      return (token, user);
    } on DioException catch (e) {
      throw failureFromDio(e);
    }
  }

  /// POST /user/register
  /// Request: {name, email, password}
  /// Response: UserResponseDto (sin token — debe hacer login después)
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/user/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw failureFromDio(e);
    }
  }

  /// GET /user/profile
  /// Verifica que el token almacenado sigue siendo válido.
  Future<UserModel> getProfile() async {
    try {
      final response =
          await _client.get<Map<String, dynamic>>('/user/profile');
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw failureFromDio(e);
    }
  }
}
