import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Disparado al arrancar la app para verificar si hay sesión activa.
class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

/// Disparado cuando el usuario presiona "Iniciar sesión".
class AuthLogin extends AuthEvent {
  const AuthLogin({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Disparado cuando el usuario presiona "Registrarse".
class AuthRegister extends AuthEvent {
  const AuthRegister({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

/// Disparado cuando el usuario cierra sesión.
class AuthLogout extends AuthEvent {
  const AuthLogout();
}

/// Disparado desde ProfileBloc cuando el usuario actualiza sus datos.
class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.updatedUser);
  final UserModel updatedUser;

  @override
  List<Object?> get props => [updatedUser];
}
