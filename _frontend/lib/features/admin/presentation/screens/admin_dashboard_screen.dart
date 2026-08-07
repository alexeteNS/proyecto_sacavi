import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard/admin_dashboard_bloc.dart';
import '../bloc/dashboard/admin_dashboard_event.dart';
import '../bloc/dashboard/admin_dashboard_state.dart';
import '../bloc/access_history/admin_access_history_bloc.dart';
import '../bloc/access_history/admin_access_history_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../injection_container.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminDashboardBloc>()..add(StartDashboardListening()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
                builder: (context, state) {
                  if (state is AdminDashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminDashboardLoaded) {
                    final summary = state.dashboard.summary;
                    return Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatCard(label: 'Usuarios', sublabel: '', value: summary.users.toString(), icon: Icons.people),
                            StatCard(label: 'Vehículos', sublabel: '', value: summary.vehicles.toString(), icon: Icons.directions_car),
                            StatCard(label: 'Solicitudes Pendientes', sublabel: '', value: summary.vehicleRequestsPending.toString(), icon: Icons.pending_actions),
                            StatCard(label: 'Accesos Hoy', sublabel: '', value: summary.accessToday.toString(), icon: Icons.login),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Dispositivos ESP32', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...state.dashboard.devices.map((d) => Card(
                          child: ListTile(
                            title: Text(d.name),
                            subtitle: Text('Estado: ${d.status}'),
                            trailing: d.status == 'online' ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.error, color: Colors.red),
                          ),
                        )),
                        const SizedBox(height: 24),
                        const Text('Usuarios Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        BlocBuilder<AdminAccessHistoryBloc, AdminAccessHistoryState>(
                          builder: (context, accessState) {
                            if (accessState.isLoading && accessState.history.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (accessState.history.isEmpty) {
                              return const Center(child: Text('Sin accesos recientes'));
                            }
                            // Take top 3 unique users
                            final uniqueUsers = <int>{};
                            final recentRecords = accessState.history.where((r) {
                              if (uniqueUsers.contains(r.owner.idUser)) return false;
                              uniqueUsers.add(r.owner.idUser);
                              return true;
                            }).take(3).toList();

                            return Column(
                              children: recentRecords.map((r) => Card(
                                child: ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(r.owner.name),
                                  subtitle: Text('Último acceso: ${r.type}\nPlaca: ${r.vehicle.plate}'),
                                  trailing: Text(r.dateTime.split('T').last),
                                  isThreeLine: true,
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  } else if (state is AdminDashboardError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
