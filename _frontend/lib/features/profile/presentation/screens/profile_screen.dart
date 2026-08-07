import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.name),
              background: Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Text(user.avatarInitial, style: const TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nombre'),
                subtitle: Text(user.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Dialog for edit
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.read<AuthBloc>().add(const AuthLogout());
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
