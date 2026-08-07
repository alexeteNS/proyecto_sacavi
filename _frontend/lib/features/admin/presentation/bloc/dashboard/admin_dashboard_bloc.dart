import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/dashboard_ws_service.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRepositoryImpl repository;
  final DashboardWsService wsService;

  AdminDashboardBloc({
    required this.repository,
    required this.wsService,
  }) : super(AdminDashboardInitial()) {
    on<StartDashboardListening>(_onStartDashboardListening);
    on<StopDashboardListening>(_onStopDashboardListening);
    on<DashboardUpdateReceived>(_onDashboardUpdateReceived);
  }

  Future<void> _onStartDashboardListening(
      StartDashboardListening event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());

    // 1. Fetch initial state via REST
    try {
      final dashboard = await repository.getDashboard();
      emit(AdminDashboardLoaded(dashboard));

      // 2. Connect to WebSocket for real-time updates
      wsService.onMessage = (data) {
        // Here we just reload the dashboard or apply partial updates.
        // For simplicity and to ensure data consistency without a complex reducer,
        // we could trigger a reload. But to be efficient, let's just trigger an update event
        // that handles the reload.
        add(DashboardUpdateReceived(data));
      };
      await wsService.connect();
    } catch (e) {
      if (e is Failure) {
        emit(AdminDashboardError(e.message));
      } else {
        emit(AdminDashboardError(e.toString()));
      }
    }
  }

  void _onStopDashboardListening(
      StopDashboardListening event, Emitter<AdminDashboardState> emit) {
    wsService.disconnect();
  }

  Future<void> _onDashboardUpdateReceived(
      DashboardUpdateReceived event, Emitter<AdminDashboardState> emit) async {
    // If the websocket signals a change (e.g. new_access, vehicle_request_status_change),
    // we fetch the dashboard again to get the fresh summary and lists.
    // Alternatively, we could manually patch `DashboardDto`, but fetching is safer.
    try {
      final dashboard = await repository.getDashboard();
      emit(AdminDashboardLoaded(dashboard));
    } catch (e) {
      // Don't emit error on background update failure, just log it.
    }
  }

  @override
  Future<void> close() {
    wsService.disconnect();
    return super.close();
  }
}
