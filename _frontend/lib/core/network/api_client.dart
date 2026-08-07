import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/failures.dart';
import '../storage/secure_storage.dart';

/// Cliente HTTP centralizado basado en Dio.
///
/// Características:
/// - Lee el JWT automáticamente desde [SecureStorageService].
/// - Agrega el header `Authorization: Bearer <token>` a todas las peticiones.
/// - Las pantallas NUNCA manipulan el token directamente.
/// - Lanza [Failure] según el código HTTP para que los BLoCs los manejen.
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _attachToken,
      onError: _handleError,
    ));
  }

  late final Dio _dio;
  final SecureStorageService _storage;

  // ─── Interceptor: agrega JWT automáticamente ──────────────────────────────

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ─── Interceptor: convierte DioException → Failure ────────────────────────

  void _handleError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response == null) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkFailure(),
        ),
      );
      return;
    }

    final body = response.data?.toString() ?? 'Error desconocido';
    final Failure failure;

    switch (response.statusCode) {
      case 401:
        failure = AuthFailure(body);
      case 403:
        failure = ForbiddenFailure(body);
      case 404:
        failure = NotFoundFailure(body);
      default:
        failure = ServerFailure(body);
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        error: failure,
      ),
    );
  }

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

/// Extrae el [Failure] de un [DioException].
/// Uso: en los repositorios al hacer catch.
Failure failureFromDio(DioException e) {
  if (e.error is Failure) return e.error as Failure;
  if (e.response == null) return const NetworkFailure();
  return ServerFailure(e.message ?? 'Error desconocido');
}
