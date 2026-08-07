import '../datasources/qr_remote_datasource.dart';
import '../../../../shared/models/qr_token_model.dart';

class QrRepositoryImpl {
  final QrRemoteDataSource remoteDataSource;

  QrRepositoryImpl({required this.remoteDataSource});

  Future<QrTokenModel> generateQr() {
    return remoteDataSource.generateQr();
  }
}
