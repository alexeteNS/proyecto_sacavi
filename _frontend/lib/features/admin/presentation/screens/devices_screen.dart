import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final keyCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos')),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is DeviceRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo Registrado')));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Device Key')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<AdminBloc>().add(RegisterDevice(name: nameCtrl.text, location: locationCtrl.text, deviceKey: keyCtrl.text));
                },
                child: const Text('Registrar Dispositivo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
