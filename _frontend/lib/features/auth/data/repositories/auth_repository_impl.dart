import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../shared/models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';

/// Repositorio de autenticación.
/// Orquesta el datasource remoto y el almacenamiento seguro del JWT.
class AuthRepositoryImpl {
  const AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final SecureStorageService _storage;

  /// Inicia sesión, guarda el JWT y el UserModel en SecureStorage.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final (token, user) = await _dataSource.login(
      email: email,
      password: password,
    );
    await _storage.saveToken(token);
    await _storage.saveUser(user.toJsonString());
    return user;
  }

  /// Registra un nuevo usuario. No guarda token (el backend no lo devuelve
  /// en /register). La UI debe redirigir al login tras el registro exitoso.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _dataSource.register(name: name, email: email, password: password);

  /// Intenta restaurar la sesión desde SecureStorage.
  /// Retorna el [UserModel] si el token existe y sigue siendo válido.
  /// Lanza [AuthFailure] si no hay token o si el backend rechaza la sesión.
  Future<UserModel> restoreSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw const AuthFailure('No hay sesión guardada');
    }
    // Verificar que el token sigue siendo válido con el backend
    return _dataSource.getProfile();
  }

  /// Cierra sesión borrando el JWT y el UserModel del almacenamiento.
  Future<void> logout() => _storage.clearAll();
}
