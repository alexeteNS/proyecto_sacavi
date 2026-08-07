import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../access/presentation/bloc/access_event.dart';
import '../../../../core/utils/date_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Generales')),
      body: BlocBuilder<AccessBloc, AccessState>(
        builder: (context, state) {
          if (state is AccessLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccessLoaded) {
            return ListView.builder(
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final r = state.records[index];
                return ListTile(
                  title: Text(r.vehiclePlate),
                  subtitle: Text('${DateFormatter.toDate(r.parsedDateTime)} ${DateFormatter.toTime(r.parsedDateTime)}'),
                );
              },
            );
          }
          return const Center(child: Text('Sin datos'));
        },
      ),
    );
  }
}
