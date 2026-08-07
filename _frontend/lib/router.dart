import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/student_shell.dart';
import 'features/auth/presentation/screens/guard_shell.dart';
import 'features/auth/presentation/screens/admin_shell.dart';

// ─── Rutas nombradas ──────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String student = '/student';
  static const String guard = '/guard';
  static const String admin = '/admin';
}

// ─── Router factory ───────────────────────────────────────────────────────────

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterAuthNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Aún cargando — quedarse en splash
      if (authState is AuthInitial || authState is AuthLoading) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // No autenticado → login
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isOnAuth ? null : AppRoutes.login;
      }

      // Registro exitoso → login
      if (authState is AuthRegistered) {
        return AppRoutes.login;
      }

      // Autenticado → Shell según rol
      if (authState is AuthAuthenticated) {
        if (isOnSplash || isOnAuth) {
          return switch (authState.user.role) {
            'GUARDIA' => AppRoutes.guard,
            'ADMIN' => AppRoutes.admin,
            _ => AppRoutes.student,
          };
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.student,
        builder: (_, __) => const StudentShell(),
      ),
      GoRoute(
        path: AppRoutes.guard,
        builder: (_, __) => const GuardShell(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminShell(),
      ),
    ],
  );
}

// ─── Notifier para que GoRouter reaccione al AuthBloc ─────────────────────────

class GoRouterAuthNotifier extends ChangeNotifier {
  GoRouterAuthNotifier(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}
