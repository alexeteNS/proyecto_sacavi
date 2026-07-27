import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late List<Vehicle> _vehicles;

  @override
  void initState() {
    super.initState();
    _vehicles = List.from(MockData.vehicles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 26),
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _vehicles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _VehicleCard(
                    vehicle: _vehicles[i],
                    onToggle: () => setState(() {
                      final v = _vehicles[i];
                      _vehicles[i] = Vehicle(
                        id: v.id,
                        brand: v.brand,
                        model: v.model,
                        plate: v.plate,
                        color: v.color,
                        status: v.status == VehicleStatus.active
                            ? VehicleStatus.inactive
                            : VehicleStatus.active,
                        logoAsset: v.logoAsset,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddVehicleDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar vehículo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddVehicleSheet(),
    );
  }
}

// ─── Vehicle Card ─────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onToggle;

  const _VehicleCard({required this.vehicle, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = vehicle.status == VehicleStatus.active;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Brand icon area
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _brandIcon(vehicle.brand),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.displayName, style: AppTextStyles.heading3),
                    const SizedBox(height: 3),
                    Text(
                      '${vehicle.plate} | ${vehicle.color}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Estado: ',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        isActive ? StatusChip.active() : StatusChip.inactive(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionBtn(
                icon: Icons.edit_rounded,
                label: 'Editar',
                color: AppColors.primary,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _actionBtn(
                icon: isActive ? Icons.block_rounded : Icons.check_circle_outline,
                label: isActive ? 'Desactivar' : 'Activar',
                color: isActive ? AppColors.error : AppColors.success,
                onTap: onToggle,
              ),
              const SizedBox(width: 8),
              _actionBtn(
                icon: Icons.qr_code_rounded,
                label: 'Ver QR',
                color: AppColors.accentLight,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandIcon(String brand) {
    final icons = {
      'Toyota': Icons.directions_car_filled_rounded,
      'Hyundai': Icons.directions_car_rounded,
      'Honda': Icons.two_wheeler_rounded,
    };
    return Icon(
      icons[brand] ?? Icons.directions_car_outlined,
      color: AppColors.primary,
      size: 28,
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Vehicle Bottom Sheet ─────────────────────────────────────────────────

class _AddVehicleSheet extends StatefulWidget {
  const _AddVehicleSheet();

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Agregar vehículo', style: AppTextStyles.heading2),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field('Placa', _plateCtrl, hint: 'Ej: ABC123'),
          const SizedBox(height: 12),
          _field('Marca / Modelo', _brandCtrl, hint: 'Ej: Toyota Corolla'),
          const SizedBox(height: 12),
          _field('Color', _colorCtrl, hint: 'Ej: Blanco'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Registrar Vehículo'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}
