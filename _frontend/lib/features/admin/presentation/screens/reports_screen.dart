import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/log/admin_log_bloc.dart';
import '../bloc/log/admin_log_event.dart';
import '../bloc/log/admin_log_state.dart';
import '../../../../injection_container.dart';
import '../../../../core/utils/date_formatter.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminLogBloc>()..add(const LoadAdminLogs()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Historial de Accesos')),
        body: BlocBuilder<AdminLogBloc, AdminLogState>(
          builder: (context, state) {
            if (state is AdminLogLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminLogsLoaded) {
              if (state.logs.isEmpty) {
                return const Center(child: Text('No hay registros.'));
              }
              return ListView.builder(
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  final formattedDate = DateFormatter.toDateTime(DateFormatter.parse(log.createdAt));
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        log.result == 'GRANTED' ? Icons.check_circle : Icons.error,
                        color: log.result == 'GRANTED' ? Colors.green : Colors.red,
                      ),
                      title: Text('Usuario: ${log.idUser ?? "Desconocido"} - Dispositivo: ${log.device ?? "N/A"}'),
                      subtitle: Text('Acción: ${log.action}\nFecha: $formattedDate'),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            } else if (state is AdminLogError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
