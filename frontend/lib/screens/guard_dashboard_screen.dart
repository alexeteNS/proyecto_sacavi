import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  int _currentIndex = 0;
  bool _gateOpen = false;
  Timer? _liveTimer;
  late List<AccessLog> _activityLogs;

  @override
  void initState() {
    super.initState();
    _activityLogs = List.from(MockData.guardActivity);
    // Simulate live updates every 8 seconds
    _liveTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      setState(() {
        _activityLogs.insert(
          0,
          AccessLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            plate: ['ABC123', 'XYZ789', 'DEF456', 'GHI321'][DateTime.now().second % 4],
            timestamp: DateTime.now(),
            type: DateTime.now().second.isEven ? AccessType.entrada : AccessType.salida,
            status: DateTime.now().second % 5 == 0
                ? AccessStatus.rejected
                : AccessStatus.approved,
          ),
        );
        if (_activityLogs.length > 10) _activityLogs.removeLast();
      });
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guard Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {},
          ),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastAccess(),
              const SizedBox(height: 16),
              _buildGateControl(),
              const SizedBox(height: 16),
              _buildEsp32Status(),
              const SizedBox(height: 20),
              _buildActivityFeed(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastAccess() {
    final last = _activityLogs.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Último acceso', style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      last.plate,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text('Juan Pérez', style: AppTextStyles.body),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        AccessTypeLabel(type: last.type),
                        const SizedBox(width: 6),
                        const Text('·', style: TextStyle(color: AppColors.textLight)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'APROBADO',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Hace 3 segundos', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGateControl() {
    return GestureDetector(
      onTap: () => setState(() => _gateOpen = !_gateOpen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gateOpen
                ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                : [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_gateOpen ? AppColors.success : AppColors.primary).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _gateOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                key: ValueKey(_gateOpen),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _gateOpen ? 'Pluma abierta — Toca para cerrar' : 'Abrir pluma manual',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEsp32Status() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const OnlineDot(online: true, size: 10),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('ESP32: ONLINE', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success,
              )),
              Text('Entrada principal: Disponible', style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Actividad reciente'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            children: _activityLogs.take(5).toList().asMap().entries.map((e) {
              final i = e.key;
              final log = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  _ActivityRow(log: log, isLatest: i == 0),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Activity Row ─────────────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final AccessLog log;
  final bool isLatest;

  const _ActivityRow({required this.log, required this.isLatest});

  String _elapsed() {
    final diff = DateTime.now().difference(log.timestamp);
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds} seg';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    return 'Hace ${diff.inHours} hr';
  }

  @override
  Widget build(BuildContext context) {
    final approved = log.status == AccessStatus.approved;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: isLatest ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              _elapsed(),
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log.plate,
              style: AppTextStyles.bodyBold,
            ),
          ),
          AccessTypeLabel(type: log.type),
          const SizedBox(width: 10),
          Icon(
            approved ? Icons.check_rounded : Icons.close_rounded,
            color: approved ? AppColors.successLight : AppColors.errorLight,
            size: 18,
          ),
        ],
      ),
    );
  }
}
