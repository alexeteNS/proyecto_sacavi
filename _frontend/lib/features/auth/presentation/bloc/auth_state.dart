import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial mientras se verifica la sesión.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Verificando sesión o ejecutando login/register.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Sesión activa — usuario autenticado.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

/// No hay sesión activa — mostrar Login.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Registro exitoso — redirigir al Login con mensaje.
class AuthRegistered extends AuthState {
  const AuthRegistered(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Error de autenticación — mostrar mensaje en pantalla.
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
