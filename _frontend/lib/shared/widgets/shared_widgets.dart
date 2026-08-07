import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class SacaviBottomNav extends StatelessWidget {
  const SacaviBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return isAdmin ? _buildAdminNav() : _buildStudentNav();
  }

  Widget _buildStudentNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.navBar,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF5C7EC7),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 22), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_rounded, size: 22), label: 'QR'),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_rounded, size: 22),
            label: 'Vehículos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 22), label: 'Historial'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 22), label: 'Perfil'),
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
      selectedLabelStyle:
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 22), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded, size: 22), label: 'Usuarios'),
        BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions_rounded, size: 22),
            label: 'Solicitudes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 22), label: 'Historial'),
        BottomNavigationBarItem(
            icon: Icon(Icons.developer_board_rounded, size: 22), label: 'Disp.'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded, size: 22), label: 'Ajustes'),
      ],
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color textColor;

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
  const AccessTypeLabel({super.key, required this.type});

  /// "ENTRADA" | "SALIDA" | "MANUAL"
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'ENTRADA' => AppColors.entradaColor,
      'SALIDA' => AppColors.salidaColor,
      _ => AppColors.inactive, // MANUAL
    };
    return Text(
      type,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Status Indicator ────────────────────────────────────────────────────────

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status, this.size = 18});

  /// "APROBADO" | "RECHAZADO" | "PENDIENTE"
  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'APROBADO' =>
        Icon(Icons.check_circle, color: AppColors.successLight, size: size),
      'RECHAZADO' =>
        Icon(Icons.cancel, color: AppColors.errorLight, size: size),
      _ => Icon(Icons.schedule, color: AppColors.warning, size: size),
    };
  }
}

// ─── Connection Status Row (Splash) ──────────────────────────────────────────

class ConnectionRow extends StatelessWidget {
  const ConnectionRow(
      {super.key, required this.label, required this.connected});

  final String label;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            connected
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
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
              color:
                  connected ? AppColors.successLight : AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

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
  const VehicleLogo({super.key, required this.brand, this.size = 40});

  final String brand;
  final double size;

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
          brand.isNotEmpty ? brand[0].toUpperCase() : '?',
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
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color? iconColor;

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
          Row(children: [
            Icon(icon, color: iconColor ?? AppColors.accent, size: 18),
            const Spacer(),
          ]),
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
          Text(label,
              style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
          Text(sublabel, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─── Online Dot ───────────────────────────────────────────────────────────────

class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key, required this.online, this.size = 10});

  final bool online;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: online ? AppColors.online : AppColors.inactive,
        shape: BoxShape.circle,
        boxShadow: online
            ? [
                BoxShadow(
                    color: AppColors.online.withValues(alpha: 0.4),
                    blurRadius: 4)
              ]
            : null,
      ),
    );
  }
}

// ─── Loading Button ───────────────────────────────────────────────────────────

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  )
                : Text(label),
      ),
    );
  }
}

// ─── Error Snackbar Helper ────────────────────────────────────────────────────

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
    ),
  );
}

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
    ),
  );
}
