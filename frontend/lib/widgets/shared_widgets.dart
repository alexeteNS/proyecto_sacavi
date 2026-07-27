import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class SacaviBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  const SacaviBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return _buildAdminNav();
    }
    return _buildStudentNav();
  }

  Widget _buildStudentNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.navBar,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF5C7EC7),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 22), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded, size: 22), label: 'QR'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car_rounded, size: 22), label: 'Vehículos'),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 22), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 22), label: 'Perfil'),
      ],
    );
  }

  Widget _buildAdminNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.navBar,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF5C7EC7),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 22), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.people_rounded, size: 22), label: 'Usuarios'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car_rounded, size: 22), label: 'Vehículos'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded, size: 22), label: 'Reportes'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded, size: 22), label: 'Ajustes'),
      ],
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  factory StatusChip.active() => const StatusChip(
    label: 'ACTIVO',
    color: Color(0xFF1B5E20),
  );

  factory StatusChip.inactive() => const StatusChip(
    label: 'INACTIVO',
    color: Color(0xFF616161),
  );

  factory StatusChip.approved() => const StatusChip(
    label: 'Aprobado',
    color: AppColors.successBg,
    textColor: AppColors.success,
  );

  factory StatusChip.rejected() => const StatusChip(
    label: 'Rechazado',
    color: AppColors.errorBg,
    textColor: AppColors.error,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Access Type Label ────────────────────────────────────────────────────────

class AccessTypeLabel extends StatelessWidget {
  final AccessType type;

  const AccessTypeLabel({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isEntrada = type == AccessType.entrada;
    return Text(
      isEntrada ? 'ENTRADA' : 'SALIDA',
      style: TextStyle(
        color: isEntrada ? AppColors.entradaColor : AppColors.salidaColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Status Indicator ────────────────────────────────────────────────────────

class StatusIndicator extends StatelessWidget {
  final AccessStatus status;
  final double size;

  const StatusIndicator({super.key, required this.status, this.size = 18});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AccessStatus.approved:
        return Icon(Icons.check_circle, color: AppColors.successLight, size: size);
      case AccessStatus.rejected:
        return Icon(Icons.cancel, color: AppColors.errorLight, size: size);
      case AccessStatus.pending:
        return Icon(Icons.schedule, color: AppColors.warning, size: size);
    }
  }
}

// ─── Connection Status Row ────────────────────────────────────────────────────

class ConnectionRow extends StatelessWidget {
  final String label;
  final bool connected;

  const ConnectionRow({super.key, required this.label, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            connected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: connected ? AppColors.successLight : AppColors.inactive,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          Text(
            connected ? 'Conectado' : 'Desconectado',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: connected ? AppColors.successLight : AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Vehicle Logo Widget ──────────────────────────────────────────────────────

class VehicleLogo extends StatelessWidget {
  final String brand;
  final double size;

  const VehicleLogo({super.key, required this.brand, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          brand[0].toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.accent, size: 18),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
          Text(sublabel, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─── Online Dot ───────────────────────────────────────────────────────────────

class OnlineDot extends StatelessWidget {
  final bool online;
  final double size;

  const OnlineDot({super.key, required this.online, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: online ? AppColors.online : AppColors.inactive,
        shape: BoxShape.circle,
        boxShadow: online
            ? [BoxShadow(color: AppColors.online.withValues(alpha: 0.4), blurRadius: 4)]
            : null,
      ),
    );
  }
}
