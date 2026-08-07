import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../injection_container.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_event.dart';
import '../../../admin/presentation/bloc/dashboard/admin_dashboard_state.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';

class GuardDashboardScreen extends StatelessWidget {
  const GuardDashboardScreen({super.key});

  void _showOpenGateDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abrir Pluma Manual'),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(labelText: 'ID Vehículo'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(idController.text);
              if (id != null) {
                context.read<AccessBloc>().add(OpenGate(idVehicle: id));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Abrir'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminDashboardBloc>()..add(StartDashboardListening()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Panel de Guardia')),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sensor_door),
                label: const Text('ABRIR PLUMA'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () => _showOpenGateDialog(context),
              ),
            ),
            const Divider(),
            const Text('Últimos Accesos (En Vivo)', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
                builder: (context, state) {
                  if (state is AdminDashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminDashboardLoaded) {
                    final records = state.dashboard.recentAccess;
                    if (records.isEmpty) {
                      return const Center(child: Text('Sin accesos recientes'));
                    }
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final r = records[index];
                        return ListTile(
                          title: Text(r.vehiclePlate),
                          subtitle: Text('${DateFormatter.toDate(r.parsedDateTime)} ${DateFormatter.toTime(r.parsedDateTime)}'),
                          trailing: AccessTypeLabel(type: r.type),
                        );
                      },
                    );
                  } else if (state is AdminDashboardError) {
                    return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
