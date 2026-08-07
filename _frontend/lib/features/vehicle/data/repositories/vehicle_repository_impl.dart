import '../datasources/vehicle_remote_datasource.dart';
import '../../../../shared/models/vehicle_model.dart';

class VehicleRepositoryImpl {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  Future<VehicleModel> addVehicle({required String plate, required String brand, required String model, required String color}) {
    return remoteDataSource.addVehicle(plate: plate, brand: brand, model: model, color: color);
  }

  Future<List<VehicleModel>> getMyVehicles() {
    return remoteDataSource.getMyVehicles();
  }

  Future<void> deleteVehicle(int id) {
    return remoteDataSource.deleteVehicle(id);
  }
}
