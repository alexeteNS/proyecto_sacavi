import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SacaviBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        isAdmin: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(),
              const SizedBox(height: 20),
              _buildSystemStatus(),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        StatCard(
          value: '245',
          label: 'Usuarios',
          sublabel: 'Activos',
          icon: Icons.people_rounded,
          iconColor: AppColors.accent,
        ),
        StatCard(
          value: '180',
          label: 'Vehículos',
          sublabel: 'Registrados',
          icon: Icons.directions_car_rounded,
          iconColor: AppColors.primaryLight,
        ),
        StatCard(
          value: '3',
          label: 'ESP32',
          sublabel: 'Online',
          icon: Icons.developer_board_rounded,
          iconColor: AppColors.successLight,
        ),
        StatCard(
          value: '120',
          label: 'Accesos hoy',
          sublabel: 'Totales',
          icon: Icons.bar_chart_rounded,
          iconColor: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Estado del sistema'),
          const SizedBox(height: 14),
          _statusRow('Servidor', true),
          _statusRow('Base de datos', true),
          _statusRow('ESP32 - Entrada Principal', true),
          _statusRow('Internet', true),
        ],
      ),
    );
  }

  Widget _statusRow(String label, bool online) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            online ? Icons.circle : Icons.circle_outlined,
            color: online ? AppColors.online : AppColors.inactive,
            size: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          Text(
            online ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: online ? AppColors.online : AppColors.inactive,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Acciones rápidas'),
        const SizedBox(height: 12),
        Row(
          children: [
            _quickAction(
              icon: Icons.people_rounded,
              label: 'Usuarios',
              color: AppColors.accent,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _quickAction(
              icon: Icons.directions_car_rounded,
              label: 'Vehículos',
              color: AppColors.primaryLight,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _quickAction(
              icon: Icons.bar_chart_rounded,
              label: 'Reportes',
              color: AppColors.warning,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final logs = MockData.guardActivity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Actividad reciente', actionLabel: 'Ver todo'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            children: logs.asMap().entries.map((e) {
              final i = e.key;
              final log = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  _AdminActivityRow(log: log),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Admin Activity Row ───────────────────────────────────────────────────────

class _AdminActivityRow extends StatelessWidget {
  final AccessLog log;
  const _AdminActivityRow({required this.log});

  String _elapsed() {
    final diff = DateTime.now().difference(log.timestamp);
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds} seg';
    return 'Hace ${diff.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final approved = log.status == AccessStatus.approved;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            child: Text(
              _elapsed(),
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(log.plate, style: AppTextStyles.bodyBold),
          ),
          AccessTypeLabel(type: log.type),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: approved ? AppColors.successBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              approved ? Icons.check_rounded : Icons.close_rounded,
              color: approved ? AppColors.successLight : AppColors.errorLight,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
