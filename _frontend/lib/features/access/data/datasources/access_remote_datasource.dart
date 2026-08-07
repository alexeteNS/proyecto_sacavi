import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/access_record_model.dart';
abstract class AccessRemoteDataSource {
  Future<List<AccessRecordModel>> getHistory();
  Future<AccessRecordModel> openGate(int idVehicle);
}

class AccessRemoteDataSourceImpl implements AccessRemoteDataSource {
  final ApiClient apiClient;

  AccessRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AccessRecordModel>> getHistory() async {
    try {
      final response = await apiClient.get('/access/history');
      final List<dynamic> data = response.data;
      return data.map((json) => AccessRecordModel.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) throw failureFromDio(e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AccessRecordModel> openGate(int idVehicle) async {
    try {
      final response = await apiClient.post('/access/open', data: {
        'id_vehicle': idVehicle,
      });
      return AccessRecordModel.fromJson(response.data);
    } catch (e) {
        if (e is DioException) throw failureFromDio(e);
        throw ServerFailure(e.toString());
    }
  }
}
