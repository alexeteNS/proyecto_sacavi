import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'guard_dashboard_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = MockData.student;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            student.avatarInitial,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Hola, ${student.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          )),
                      Text(student.role,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _section('Mi cuenta', [
                  _tile(Icons.person_outline_rounded, 'Datos personales', () {}),
                  _tile(Icons.lock_outline_rounded, 'Cambiar contraseña', () {}),
                  _tile(Icons.notifications_outlined, 'Notificaciones', () {}),
                ]),
                const SizedBox(height: 16),
                _section('Acceso rápido', [
                  _tile(
                    Icons.security_rounded,
                    'Guard Dashboard',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuardDashboardScreen()),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                  ),
                  _tile(
                    Icons.admin_panel_settings_rounded,
                    'Panel Admin',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                  ),
                ]),
                const SizedBox(height: 16),
                _section('Soporte', [
                  _tile(Icons.help_outline_rounded, 'Centro de ayuda', () {}),
                  _tile(Icons.info_outline_rounded, 'Acerca de SACAVI', () {}),
                ]),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: _tile(
                    Icons.logout_rounded,
                    'Cerrar sesión',
                    () {},
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              return Column(
                children: [
                  if (e.key > 0) const Divider(height: 1, indent: 54, color: AppColors.divider),
                  e.value,
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
    Widget? trailing,
  }) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 18),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: c, fontSize: 14)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
    );
  }
}
