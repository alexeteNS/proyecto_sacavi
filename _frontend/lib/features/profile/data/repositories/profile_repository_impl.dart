import '../datasources/profile_remote_datasource.dart';
import '../../../../shared/models/user_model.dart';

class ProfileRepositoryImpl {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  Future<UserModel> getProfile() {
    return remoteDataSource.getProfile();
  }

  Future<UserModel> updateProfile({required String name, required String email}) {
    return remoteDataSource.updateProfile(name: name, email: email);
  }
}
