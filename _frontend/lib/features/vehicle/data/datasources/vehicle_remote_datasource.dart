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
      // Usar endpoint de solicitudes vehiculares
      final response = await apiClient.post('/vehicle/request', data: {
        'plate': plate,
        'brand': brand,
        'model': model,
        'color': color,
      });
      // El backend devuelve un VehicleRequestResponseDto,
      // la UI actual espera VehicleModel (para listarlos optimistamente).
      // Adaptaremos el json devuelto para que coincida parcialmente.
      return VehicleModel.fromJson({
        'id_vehicle': response.data['id_request'],
        'plate': response.data['plate'],
        'brand': response.data['brand'],
        'model': response.data['model'],
        'color': response.data['color'],
        'id_user': response.data['id_user'],
        'status': response.data['status']
      });
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
