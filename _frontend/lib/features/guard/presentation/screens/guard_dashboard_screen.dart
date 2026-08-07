import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/utils/date_formatter.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        context.read<AccessBloc>().add(LoadHistory());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Guardia')),
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is GateOpened) {
            showSuccessSnack(context, 'Pluma abierta correctamente');
          } else if (state is AccessError) {
            showErrorSnack(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AccessLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccessLoaded || state is GateOpened) {
            final records = state is AccessLoaded ? state.records : [];
            return Column(
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
                const Text('Últimos Accesos', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: records.isEmpty
                      ? const Center(child: Text('Sin accesos recientes'))
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final r = records[index];
                            return ListTile(
                              title: Text(r.vehiclePlate),
                              subtitle: Text('${DateFormatter.toDate(r.parsedDateTime)} ${DateFormatter.toTime(r.parsedDateTime)}'),
                              trailing: AccessTypeLabel(type: r.type),
                            );
                          },
                        ),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
