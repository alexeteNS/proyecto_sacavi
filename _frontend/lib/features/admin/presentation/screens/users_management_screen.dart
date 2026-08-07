import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Cambiar rol de usuario'),
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID Usuario')),
            TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'ID Rol (1=Admin, 2=Guard, 3=Student)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final uid = int.tryParse(idCtrl.text) ?? 0;
                final rid = int.tryParse(roleCtrl.text) ?? 0;
                context.read<AdminBloc>().add(ChangeUserRole(userId: uid, roleId: rid));
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}
