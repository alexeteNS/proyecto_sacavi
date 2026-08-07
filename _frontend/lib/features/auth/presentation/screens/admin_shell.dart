import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../admin/presentation/bloc/admin_event.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../admin/presentation/screens/users_management_screen.dart';
import '../../../admin/presentation/screens/devices_screen.dart';
import '../../../admin/presentation/screens/reports_screen.dart';
import '../../../admin/presentation/screens/settings_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';

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
    DevicesScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminBloc>(
          create: (_) => di.sl<AdminBloc>()..add(LoadAdminDashboard()),
        ),
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>(),
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
