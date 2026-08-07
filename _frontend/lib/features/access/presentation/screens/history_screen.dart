import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/access_bloc.dart';
import '../bloc/access_event.dart';
import '../bloc/access_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/utils/date_formatter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Accesos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Todos', label: Text('Todos')),
                ButtonSegment(value: 'ENTRADA', label: Text('Entradas')),
                ButtonSegment(value: 'SALIDA', label: Text('Salidas')),
              ],
              selected: {_filter},
              onSelectionChanged: (set) {
                setState(() => _filter = set.first);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AccessBloc, AccessState>(
              builder: (context, state) {
                if (state is AccessLoading) return const Center(child: CircularProgressIndicator());
                if (state is AccessLoaded) {
                  final records = state.records.where((r) {
                    if (_filter == 'Todos') return true;
                    if (_filter == 'ENTRADA') return r.isEntrada;
                    if (_filter == 'SALIDA') return r.isSalida;
                    return true;
                  }).toList();
                  if (records.isEmpty) return const Center(child: Text('No hay registros.'));

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final r = records[index];
                      return ListTile(
                        title: Text(r.vehiclePlate),
                        subtitle: Text('${DateFormatter.toDate(r.parsedDateTime)} ${DateFormatter.toTime(r.parsedDateTime)}'),
                        trailing: AccessTypeLabel(type: r.type),
                      );
                    },
                  );
                }
                if (state is AccessError) return Center(child: Text(state.message));
                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
