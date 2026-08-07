import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import 'admin_log_event.dart';
import 'admin_log_state.dart';

class AdminLogBloc extends Bloc<AdminLogEvent, AdminLogState> {
  final AdminRepositoryImpl repository;

  AdminLogBloc({required this.repository}) : super(AdminLogInitial()) {
    on<LoadAdminLogs>(_onLoadAdminLogs);
  }

  Future<void> _onLoadAdminLogs(
      LoadAdminLogs event, Emitter<AdminLogState> emit) async {
    emit(AdminLogLoading());
    try {
      final logs = await repository.getLogs(event.filters);
      emit(AdminLogsLoaded(logs));
    } catch (e) {
      if (e is Failure) {
        emit(AdminLogError(e.message));
      } else {
        emit(AdminLogError(e.toString()));
      }
    }
  }
}
