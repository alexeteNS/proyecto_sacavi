import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../admin/presentation/screens/users_management_screen.dart';
import '../../../admin/presentation/screens/vehicle_requests_screen.dart';
import '../../../admin/presentation/screens/admin_access_history_screen.dart';
import '../../../admin/presentation/screens/devices_screen.dart';
import '../../../admin/presentation/screens/settings_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../admin/presentation/bloc/access_history/admin_access_history_bloc.dart';
import '../../../admin/presentation/bloc/access_history/admin_access_history_event.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    UsersManagementScreen(),
    VehicleRequestsScreen(),
    AdminAccessHistoryScreen(),
    DevicesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminBloc>(
          create: (_) => di.sl<AdminBloc>(),
        ),
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>(),
        ),
        BlocProvider<AdminAccessHistoryBloc>(
          create: (_) => di.sl<AdminAccessHistoryBloc>()..add(const LoadAccessHistory())..add(LoadAccessStats()),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: SacaviBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isAdmin: true,
        ),
      ),
    );
  }
}
