import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import 'admin_vehicle_request_event.dart';
import 'admin_vehicle_request_state.dart';

class AdminVehicleRequestBloc
    extends Bloc<AdminVehicleRequestEvent, AdminVehicleRequestState> {
  final AdminRepositoryImpl repository;

  AdminVehicleRequestBloc({required this.repository})
      : super(AdminVehicleRequestInitial()) {
    on<LoadVehicleRequests>(_onLoadVehicleRequests);
    on<ApproveVehicleRequest>(_onApproveVehicleRequest);
    on<RejectVehicleRequest>(_onRejectVehicleRequest);
    on<MarkVehicleRequestInRevision>(_onMarkVehicleRequestInRevision);
  }

  Future<void> _onLoadVehicleRequests(
      LoadVehicleRequests event, Emitter<AdminVehicleRequestState> emit) async {
    emit(AdminVehicleRequestLoading());
    try {
      final requests = await repository.getAllVehicleRequests();
      emit(AdminVehicleRequestsLoaded(requests));
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onApproveVehicleRequest(ApproveVehicleRequest event,
      Emitter<AdminVehicleRequestState> emit) async {
    try {
      final request = await repository.approveRequest(event.id);
      emit(AdminVehicleRequestActionSuccess(request, 'approved'));
      add(LoadVehicleRequests());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onRejectVehicleRequest(RejectVehicleRequest event,
      Emitter<AdminVehicleRequestState> emit) async {
    try {
      final request = await repository.rejectRequest(event.id);
      emit(AdminVehicleRequestActionSuccess(request, 'rejected'));
      add(LoadVehicleRequests());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  Future<void> _onMarkVehicleRequestInRevision(MarkVehicleRequestInRevision event,
      Emitter<AdminVehicleRequestState> emit) async {
    try {
      final request = await repository.markRequestInRevision(event.id);
      emit(AdminVehicleRequestActionSuccess(request, 'in_revision'));
      add(LoadVehicleRequests());
    } catch (e) {
      _emitError(e, emit);
    }
  }

  void _emitError(dynamic e, Emitter<AdminVehicleRequestState> emit) {
    if (e is Failure) {
      emit(AdminVehicleRequestError(e.message));
    } else {
      emit(AdminVehicleRequestError(e.toString()));
    }
  }
}
