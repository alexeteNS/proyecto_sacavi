import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../guard/presentation/screens/guard_dashboard_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';

class GuardShell extends StatelessWidget {
  const GuardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>()..add(LoadHistory()),
        ),
      ],
      child: const Scaffold(
        body: GuardDashboardScreen(),
      ),
    );
  }
}
