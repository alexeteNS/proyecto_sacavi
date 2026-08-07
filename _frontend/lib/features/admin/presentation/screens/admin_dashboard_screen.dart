import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(label: 'Usuarios', sublabel: '', value: '120', icon: Icons.people),
                StatCard(label: 'Accesos Hoy', sublabel: '', value: '45', icon: Icons.login),
                StatCard(label: 'Dispositivos', sublabel: '', value: '2', icon: Icons.developer_board),
                StatCard(label: 'Alertas', sublabel: '', value: '0', icon: Icons.warning),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminDashboardLoaded && state.deviceStatus != null) {
                  return Card(
                    child: ListTile(
                      title: const Text('Estado ESP32 Main'),
                      subtitle: Text(state.deviceStatus!.online ? 'En línea' : 'Desconectado'),
                      trailing: state.deviceStatus!.online ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.error, color: Colors.red),
                    ),
                  );
                }
                return const Card(child: ListTile(title: Text('Estado de dispositivos desconocido')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
