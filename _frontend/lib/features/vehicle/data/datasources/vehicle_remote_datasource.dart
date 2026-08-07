import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/vehicle_model.dart';
abstract class VehicleRemoteDataSource {
  Future<VehicleModel> addVehicle({required String plate, required String brand, required String model, required String color});
  Future<List<VehicleModel>> getMyVehicles();
  Future<void> deleteVehicle(int id);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient apiClient;

  VehicleRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<VehicleModel> addVehicle({required String plate, required String brand, required String model, required String color}) async {
    try {
      final response = await apiClient.post('/vehicle', data: {
        'plate': plate,
        'brand': brand,
        'model': model,
        'color': color,
      });
      return VehicleModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) throw failureFromDio(e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await apiClient.get('/vehicle/my');
      final List<dynamic> data = response.data;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(int id) async {
    try {
      await apiClient.delete('/vehicle/$id');
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }
}
