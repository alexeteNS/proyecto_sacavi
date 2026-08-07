import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/qr_token_model.dart';
abstract class QrRemoteDataSource {
  Future<QrTokenModel> generateQr();
}

class QrRemoteDataSourceImpl implements QrRemoteDataSource {
  final ApiClient apiClient;

  QrRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<QrTokenModel> generateQr() async {
    try {
      final response = await apiClient.get('/qr/generate');
      return QrTokenModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) throw failureFromDio(e);
      throw ServerFailure(e.toString());
    }
  }
}
