import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/admin_user_bloc.dart';
import '../bloc/user/admin_user_event.dart';
import '../bloc/user/admin_user_state.dart';
import '../../../../injection_container.dart';
import '../../../../shared/models/admin_user_model.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  void _showUserDialog(BuildContext context, {AdminUserResponse? user}) {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final roleCtrl = TextEditingController(text: user?.role ?? 'ESTUDIANTE');
    final pwdCtrl = TextEditingController(); // Only for create

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Editar Usuario' : 'Crear Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Rol (ADMIN, GUARDIA, ESTUDIANTE)')),
              if (!isEdit)
                TextField(controller: pwdCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final data = {
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'role': roleCtrl.text.trim(),
              };
              if (isEdit) {
                context.read<AdminUserBloc>().add(UpdateAdminUser(user!.idUser, data));
              } else {
                data['password'] = pwdCtrl.text;
                context.read<AdminUserBloc>().add(CreateAdminUser(data));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, int userId) {
    final pwdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetear Contraseña'),
        content: TextField(
          controller: pwdCtrl,
          decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminUserBloc>().add(ResetAdminUserPassword(userId, pwdCtrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminUserBloc>()..add(LoadAdminUsers()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestión de Usuarios')),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () => _showUserDialog(ctx),
            child: const Icon(Icons.add),
          ),
        ),
        body: BlocConsumer<AdminUserBloc, AdminUserState>(
          listener: (context, state) {
            if (state is AdminUserActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acción completada: ${state.action}')));
              if (state.action != 'password_reset') {
                 context.read<AdminUserBloc>().add(LoadAdminUsers());
              }
            } else if (state is AdminUserError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
          builder: (context, state) {
            if (state is AdminUserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminUsersLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text('${user.email} - Rol: ${user.role}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.lock_reset),
                            onPressed: () => _showResetPasswordDialog(context, user.idUser),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showUserDialog(context, user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<AdminUserBloc>().add(DeleteAdminUser(user.idUser));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Cargando usuarios...'));
          },
        ),
      ),
    );
  }
}
