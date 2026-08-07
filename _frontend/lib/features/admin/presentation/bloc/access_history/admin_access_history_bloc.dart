import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_access_history_event.dart';
import 'admin_access_history_state.dart';
import '../../../../admin/data/repositories/admin_repository_impl.dart';

class AdminAccessHistoryBloc extends Bloc<AdminAccessHistoryEvent, AdminAccessHistoryState> {
  final AdminRepositoryImpl adminRepository;

  AdminAccessHistoryBloc({required this.adminRepository}) : super(const AdminAccessHistoryState()) {
    on<LoadAccessHistory>(_onLoadAccessHistory);
    on<LoadAccessStats>(_onLoadAccessStats);
    on<AddNewAccessRecord>(_onAddNewAccessRecord);
  }

  Future<void> _onLoadAccessHistory(LoadAccessHistory event, Emitter<AdminAccessHistoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final history = await adminRepository.getAccessHistory(event.filters);
      emit(state.copyWith(isLoading: false, history: history));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadAccessStats(LoadAccessStats event, Emitter<AdminAccessHistoryState> emit) async {
    emit(state.copyWith(isStatsLoading: true, error: null));
    try {
      final stats = await adminRepository.getAccessStats();
      emit(state.copyWith(isStatsLoading: false, stats: stats));
    } catch (e) {
      emit(state.copyWith(isStatsLoading: false, error: e.toString()));
    }
  }

  void _onAddNewAccessRecord(AddNewAccessRecord event, Emitter<AdminAccessHistoryState> emit) {
    final updatedHistory = List.of(state.history)..insert(0, event.record);
    emit(state.copyWith(history: updatedHistory));
    add(LoadAccessStats()); // Refresh stats when new record comes in
  }
}
