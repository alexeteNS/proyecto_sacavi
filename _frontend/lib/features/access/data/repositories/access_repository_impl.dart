import '../datasources/access_remote_datasource.dart';
import '../../../../shared/models/access_record_model.dart';

class AccessRepositoryImpl {
  final AccessRemoteDataSource remoteDataSource;

  AccessRepositoryImpl({required this.remoteDataSource});

  Future<List<AccessRecordModel>> getHistory() {
    return remoteDataSource.getHistory();
  }

  Future<AccessRecordModel> openGate(int idVehicle) {
    return remoteDataSource.openGate(idVehicle);
  }
}
