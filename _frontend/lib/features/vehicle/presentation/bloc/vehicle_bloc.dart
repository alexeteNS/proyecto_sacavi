import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../../../core/error/failures.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepositoryImpl repository;

  VehicleBloc({required this.repository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicles = await repository.getMyVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      if (e is Failure) {
        emit(VehicleError(e.message));
      } else {
        emit(VehicleError(e.toString()));
      }
    }
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    final currentState = state;
    emit(VehicleLoading());
    try {
      await repository.addVehicle(
        plate: event.plate,
        brand: event.brand,
        model: event.model,
        color: event.color,
      );
      // Reload vehicles after adding
      final vehicles = await repository.getMyVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      if (e is Failure) {
        emit(VehicleError(e.message));
      } else {
        emit(VehicleError(e.toString()));
      }
      if (currentState is VehicleLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    final currentState = state;
    emit(VehicleLoading());
    try {
      await repository.deleteVehicle(event.id);
      // Reload vehicles after deleting
      final vehicles = await repository.getMyVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      if (e is Failure) {
        emit(VehicleError(e.message));
      } else {
        emit(VehicleError(e.toString()));
      }
      if (currentState is VehicleLoaded) {
        emit(currentState);
      }
    }
  }
}
