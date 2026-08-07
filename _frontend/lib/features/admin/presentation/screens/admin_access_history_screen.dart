import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/access_history/admin_access_history_bloc.dart';
import '../bloc/access_history/admin_access_history_state.dart';
import '../bloc/access_history/admin_access_history_event.dart';
import '../../../../core/utils/date_formatter.dart';

class AdminAccessHistoryScreen extends StatelessWidget {
  const AdminAccessHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Monitoreo', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: const _AccessHistoryBody(),
    );
  }
}

class _AccessHistoryBody extends StatelessWidget {
  const _AccessHistoryBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAccessHistoryBloc, AdminAccessHistoryState>(
      builder: (context, state) {
        if (state.isLoading && state.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminAccessHistoryBloc>().add(LoadAccessHistory());
            context.read<AdminAccessHistoryBloc>().add(LoadAccessStats());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              if (state.stats != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildStatsGrid(context, state),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Últimos Accesos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              if (state.history.isEmpty && !state.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No hay actividad reciente.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = state.history[index];
                    final formattedTime = DateFormatter.toTime(DateFormatter.parse(record.dateTime));
                    final isAprobado = record.status == 'APROBADO';
                    final isEntrada = record.type == 'ENTRADA';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isAprobado ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.push('/admin/access/${record.idRecord}', extra: record);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isAprobado ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  isEntrada ? Icons.login : (record.type == 'SALIDA' ? Icons.logout : Icons.pan_tool),
                                  color: isAprobado ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '🚗 ${record.vehicle.plate}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      record.owner.name,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            record.type,
                                            style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (record.device != null)
                                          Expanded(
                                            child: Text(
                                              '📍 ${record.device!.location}',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: state.history.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminAccessHistoryState state) {
    if (state.isStatsLoading && state.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = state.stats!;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Accesos Hoy', stats.todayTotal.toString(), Icons.analytics, Colors.blue),
        _buildStatCard('Entradas', stats.entradas.toString(), Icons.login, Colors.green),
        _buildStatCard('Salidas', stats.salidas.toString(), Icons.logout, Colors.orange),
        _buildStatCard('Denegados', stats.denied.toString(), Icons.block, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color.withOpacity(0.8)),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
