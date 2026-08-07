import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'router.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar UI del sistema
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.navBar,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar inyección de dependencias
  await setupDependencies();

  runApp(const SacaviApp());
}

class SacaviApp extends StatefulWidget {
  const SacaviApp({super.key});

  @override
  State<SacaviApp> createState() => _SacaviAppState();
}

class _SacaviAppState extends State<SacaviApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    // Verificar sesión guardada al arrancar
    _authBloc.add(const AuthCheckSession());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: Builder(
        builder: (context) {
          final router = createRouter(_authBloc);
          return MaterialApp.router(
            title: 'SACAVI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
