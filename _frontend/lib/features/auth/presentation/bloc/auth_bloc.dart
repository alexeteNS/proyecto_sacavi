import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC central de autenticación.
///
/// Responsabilidades:
/// - Verificar sesión persistida en SecureStorage al iniciar la app.
/// - Ejecutar login y guardar JWT.
/// - Ejecutar registro.
/// - Logout limpiando almacenamiento.
/// - Emitir [AuthAuthenticated] con el UserModel global que toda la app consume.
///
/// El go_router escucha este BLoC para redirigir según el estado.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  final AuthRepositoryImpl _repository;

  // ─── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.restoreSession();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (_) {
      emit(const AuthError('Error inesperado. Inténtalo de nuevo.'));
    }
  }

  Future<void> _onRegister(
    AuthRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(const AuthRegistered('Cuenta creada exitosamente. Inicia sesión.'));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (_) {
      emit(const AuthError('Error inesperado. Inténtalo de nuevo.'));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  void _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated(event.updatedUser));
  }
}
