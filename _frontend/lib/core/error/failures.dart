/// Tipos de falla del dominio.
/// Utilizar para mapear errores HTTP a mensajes comprensibles en la UI.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Error de red (sin conexión, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Error del servidor (4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error de autenticación (401).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesión expirada. Inicia sesión de nuevo.']);
}

/// Error de autorización (403).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'No tienes permiso para realizar esta acción.']);
}

/// Error de recurso no encontrado (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}
