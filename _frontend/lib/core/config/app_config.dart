/// Configuración central de la aplicación SACAVI.
/// Modifica [baseUrl] según el entorno de ejecución.
class AppConfig {
  AppConfig._();

  // Para emulador Android: 10.0.2.2
  // Para dispositivo físico en la misma red: IP del servidor
  // Para iOS simulator: 127.0.0.1
  static const String baseUrl = 'https://6c78-177-226-64-4.ngrok-free.app';
  

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const String jwtStorageKey = 'sacavi_jwt';
  static const String userStorageKey = 'sacavi_user';
}
