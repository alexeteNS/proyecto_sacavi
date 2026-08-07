import 'package:flutter/material.dart';
import '../../../../../shared/models/access_history_model.dart';
import '../../../../../core/utils/date_formatter.dart';

class AccessDetailsScreen extends StatelessWidget {
  final AccessHistoryModel record;

  const AccessDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isAprobado = record.status == 'APROBADO';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Acceso'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              color: isAprobado ? Colors.green.shade50 : Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Icon(
                    isAprobado ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 64,
                    color: isAprobado ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    record.status,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isAprobado ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.toDateTime(DateFormatter.parse(record.dateTime)),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Información del Acceso'),
                  _buildInfoCard([
                    _buildInfoRow('ID Registro', '#${record.idRecord}'),
                    _buildInfoRow('Tipo', record.type),
                    _buildInfoRow('Ubicación (ESP32)', record.device?.location ?? 'Desconocida'),
                    _buildInfoRow('Dispositivo', record.device?.name ?? 'Desconocido'),
                    _buildInfoRow('Tiempo Validación', 'N/A'), // Según requerimiento actual
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Información del Vehículo'),
                  _buildInfoCard([
                    _buildInfoRow('Placa', record.vehicle.plate),
                    _buildInfoRow('Marca', record.vehicle.brand),
                    _buildInfoRow('Modelo', record.vehicle.model),
                    _buildInfoRow('Color', record.vehicle.color),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Información del Propietario'),
                  _buildInfoCard([
                    _buildInfoRow('Nombre', record.owner.name),
                    _buildInfoRow('Correo', record.owner.email),
                    _buildInfoRow('Rol', record.owner.role),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Historial Reciente (Propietario)'),
                  // Dummy timeline for now as requested (or we could fetch it). 
                  // The prompt requested a timeline view.
                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // Simple static timeline as placeholder for the specific user's timeline.
    // In a real scenario, this would be a ListView built from a user_history query.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTimelineItem('ENTRADA', 'Hoy 08:30 AM', isLast: false),
          _buildTimelineItem('SALIDA', 'Hoy 02:12 PM', isLast: false),
          _buildTimelineItem('ENTRADA', 'Hoy 05:40 PM', isLast: false),
          _buildTimelineItem(record.type, DateFormatter.toTime(DateFormatter.parse(record.dateTime)), isLast: true, isCurrent: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String action, String time, {bool isLast = false, bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.blue : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action, style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.blue : Colors.black87)),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }
}
