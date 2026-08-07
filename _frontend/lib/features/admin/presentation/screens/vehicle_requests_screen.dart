import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle_request/admin_vehicle_request_bloc.dart';
import '../bloc/vehicle_request/admin_vehicle_request_event.dart';
import '../bloc/vehicle_request/admin_vehicle_request_state.dart';
import '../../../../injection_container.dart';

class VehicleRequestsScreen extends StatelessWidget {
  const VehicleRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminVehicleRequestBloc>()..add(LoadVehicleRequests()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Solicitudes de Vehículos')),
        body: BlocConsumer<AdminVehicleRequestBloc, AdminVehicleRequestState>(
          listener: (context, state) {
            if (state is AdminVehicleRequestActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud ${state.action}')));
            } else if (state is AdminVehicleRequestError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
          builder: (context, state) {
            if (state is AdminVehicleRequestLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminVehicleRequestsLoaded) {
              return ListView.builder(
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return Card(
                    child: ListTile(
                      title: Text('${request.brand} ${request.model} - ${request.plate}'),
                      subtitle: Text('Estado: ${request.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (request.status == 'PENDIENTE') ...[
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              color: Colors.orange,
                              onPressed: () => context.read<AdminVehicleRequestBloc>().add(MarkVehicleRequestInRevision(request.idRequest)),
                            ),
                          ],
                          if (request.status == 'EN_REVISION' || request.status == 'PENDIENTE') ...[
                            IconButton(
                              icon: const Icon(Icons.check),
                              color: Colors.green,
                              onPressed: () => context.read<AdminVehicleRequestBloc>().add(ApproveVehicleRequest(request.idRequest)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.red,
                              onPressed: () => context.read<AdminVehicleRequestBloc>().add(RejectVehicleRequest(request.idRequest)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Cargando solicitudes...'));
          },
        ),
      ),
    );
  }
}
