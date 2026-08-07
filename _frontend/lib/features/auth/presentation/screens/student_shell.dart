import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicle/presentation/bloc/vehicle_event.dart';
import '../../../vehicle/presentation/screens/home_student_screen.dart';
import '../../../vehicle/presentation/screens/vehicles_screen.dart';
import '../../../qr/presentation/bloc/qr_bloc.dart';
import '../../../qr/presentation/bloc/qr_event.dart';
import '../../../qr/presentation/screens/qr_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';
import '../../../access/presentation/screens/history_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VehicleBloc>(
          create: (_) => di.sl<VehicleBloc>()..add(LoadVehicles()),
        ),
        BlocProvider<QrBloc>(create: (_) => di.sl<QrBloc>()),
        BlocProvider<AccessBloc>(create: (_) => di.sl<AccessBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeStudentScreen(
                onNavigateToQr: () {
                  setState(() => _currentIndex = 1);
                  context.read<QrBloc>().add(GenerateQr());
                },
              ),
              const QrScreen(),
              const VehiclesScreen(),
              const HistoryScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: SacaviBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0 || index == 3) {
                context.read<AccessBloc>().add(LoadHistory());
              }
            },
            isAdmin: false,
          ),
        ),
      ),
    );
  }
}
