import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../access/presentation/bloc/access_event.dart';
import '../../../../core/utils/date_formatter.dart';

class HomeStudentScreen extends StatefulWidget {
  /// Callback para navegar al tab de QR (índice 1) desde el shell.
  final VoidCallback? onNavigateToQr;

  const HomeStudentScreen({super.key, this.onNavigateToQr});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(LoadVehicles());
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = 'Estudiante';
    String initial = 'E';
    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      initial = authState.user.avatarInitial;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(name, initial)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSystemStatus(),
                  const SizedBox(height: 16),
                  _buildQrCard(),
                  const SizedBox(height: 20),
                  _buildVehiclesSection(),
                  const SizedBox(height: 20),
                  _buildRecentHistory(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String initial) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ESTUDIANTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.successLight.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          OnlineDot(online: true, size: 10),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sistema operativo',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.success),
              ),
              Text(
                'Entrada principal activa',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2_rounded, color: Colors.white54, size: 36),
          const SizedBox(height: 8),
          const Text(
            'GENERAR QR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Muestre este código al escáner',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNavigateToQr,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Generar QR',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Mis vehículos'),
        const SizedBox(height: 10),
        BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VehicleLoaded && state.vehicles.isNotEmpty) {
              final v = state.vehicles.first;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    VehicleLogo(brand: v.brand),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.displayName,
                              style: AppTextStyles.bodyBold),
                          Text(v.displayInfo,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textLight),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Sin vehículos registrados',
                style: AppTextStyles.caption,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Historial reciente'),
        const SizedBox(height: 10),
        BlocBuilder<AccessBloc, AccessState>(
          builder: (context, state) {
            if (state is AccessLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AccessLoaded && state.records.isNotEmpty) {
              final recent = state.records.take(3).toList();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: recent.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    final dt = r.parsedDateTime;
                    return Column(
                      children: [
                        if (i > 0)
                          const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: AppColors.divider),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '${DateFormatter.toDate(dt)}\n${DateFormatter.toTime(dt)}',
                                  style: AppTextStyles.caption
                                      .copyWith(fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AccessTypeLabel(type: r.type),
                              ),
                              Text(
                                r.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: r.status == 'APROBADO'
                                      ? AppColors.successLight
                                      : AppColors.errorLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
            return const Text('Sin historial reciente',
                style: AppTextStyles.caption);
          },
        ),
      ],
    );
  }
}
