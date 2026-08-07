import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _showAddVehicleSheet(BuildContext context) {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final colorController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Agregar Vehículo', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Placa'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<VehicleBloc>().add(
                    AddVehicle(
                      plate: plateController.text,
                      brand: brandController.text,
                      model: modelController.text,
                      color: colorController.text,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleError) {
            showErrorSnack(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is VehicleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VehicleLoaded) {
            final vehicles = state.vehicles;
            if (vehicles.isEmpty) {
              return const Center(child: Text('No tienes vehículos.'));
            }
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return ListTile(
                  leading: VehicleLogo(brand: v.brand),
                  title: Text(v.displayName),
                  subtitle: Text(v.displayInfo),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<VehicleBloc>().add(DeleteVehicle(v.idVehicle));
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Error cargando vehículos.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
