import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filterIndex = 0; // 0=Todos, 1=Entradas, 2=Salidas

  final List<AccessLog> _allLogs = [
    AccessLog(
      id: 'h1',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 27, 7, 6, 51),
      type: AccessType.entrada,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'h2',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 27, 6, 45, 22),
      type: AccessType.salida,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'h3',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 26, 18, 35, 10),
      type: AccessType.salida,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'h4',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 26, 9, 12, 47),
      type: AccessType.entrada,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'h5',
      plate: 'XYZ789',
      timestamp: DateTime(2027, 7, 25, 16, 30, 0),
      type: AccessType.entrada,
      status: AccessStatus.rejected,
    ),
  ];

  List<AccessLog> get _filtered {
    if (_filterIndex == 1) {
      return _allLogs.where((l) => l.type == AccessType.entrada).toList();
    } else if (_filterIndex == 2) {
      return _allLogs.where((l) => l.type == AccessType.salida).toList();
    }
    return _allLogs;
  }

  Map<String, List<AccessLog>> get _groupedLogs {
    final map = <String, List<AccessLog>>{};
    for (final log in _filtered) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);

      String key;
      if (logDate == today) {
        key = 'Hoy';
      } else if (logDate == yesterday) {
        key = 'Ayer';
      } else {
        key = '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}';
      }
      map.putIfAbsent(key, () => []).add(log);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de Accesos'),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const labels = ['Todos', 'Entradas', 'Salidas'];
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = _filterIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filterIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: selected ? AppColors.primary : Colors.white70,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildList() {
    final groups = _groupedLogs;
    final keys = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final key = keys[i];
        final logs = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: logs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final log = entry.value;
                  return Column(
                    children: [
                      if (idx > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                      _LogRow(log: log),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.textLight),
          const SizedBox(height: 12),
          const Text('Sin registros', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          const Text('No hay accesos en esta categoría', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

// ─── Log Row ──────────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final AccessLog log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 56,
            child: Text(
              log.timeString,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Divider line
          Container(
            width: 2,
            height: 36,
            color: log.type == AccessType.entrada
                ? AppColors.entradaColor.withValues(alpha: 0.3)
                : AppColors.salidaColor.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccessTypeLabel(type: log.type),
                const SizedBox(height: 2),
                Text(log.plate, style: AppTextStyles.caption),
              ],
            ),
          ),

          // Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                log.status == AccessStatus.approved ? 'Aprobado' : 'Rechazado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: log.status == AccessStatus.approved
                      ? AppColors.successLight
                      : AppColors.errorLight,
                ),
              ),
              const SizedBox(height: 4),
              StatusIndicator(status: log.status, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
