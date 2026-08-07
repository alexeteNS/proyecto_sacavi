import 'package:flutter_bloc/flutter_bloc.dart';
import 'access_event.dart';
import 'access_state.dart';
import '../../data/repositories/access_repository_impl.dart';
import '../../../../core/error/failures.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final AccessRepositoryImpl repository;

  AccessBloc({required this.repository}) : super(AccessInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<OpenGate>(_onOpenGate);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<AccessState> emit) async {
    emit(AccessLoading());
    try {
      final records = await repository.getHistory();
      emit(AccessLoaded(records));
    } catch (e) {
      if (e is Failure) {
        emit(AccessError(e.message));
      } else {
        emit(AccessError(e.toString()));
      }
    }
  }

  Future<void> _onOpenGate(OpenGate event, Emitter<AccessState> emit) async {
    emit(AccessLoading());
    try {
      final record = await repository.openGate(event.idVehicle);
      emit(GateOpened(record));
      // Reload history after opening
      final records = await repository.getHistory();
      emit(AccessLoaded(records));
    } catch (e) {
      if (e is Failure) {
        emit(AccessError(e.message));
      } else {
        emit(AccessError(e.toString()));
      }
    }
  }
}
