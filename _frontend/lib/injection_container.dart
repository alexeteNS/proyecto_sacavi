import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/dashboard_ws_service.dart';


// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Vehicle
import 'features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicle/presentation/bloc/vehicle_bloc.dart';

// QR
import 'features/qr/data/datasources/qr_remote_datasource.dart';
import 'features/qr/data/repositories/qr_repository_impl.dart';
import 'features/qr/presentation/bloc/qr_bloc.dart';

// Access / History
import 'features/access/data/datasources/access_remote_datasource.dart';
import 'features/access/data/repositories/access_repository_impl.dart';
import 'features/access/presentation/bloc/access_bloc.dart';

// Profile
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// Admin
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/admin/presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import 'features/admin/presentation/bloc/vehicle_request/admin_vehicle_request_bloc.dart';
import 'features/admin/presentation/bloc/user/admin_user_bloc.dart';
import 'features/admin/presentation/bloc/log/admin_log_bloc.dart';
import 'features/admin/presentation/bloc/access_history/admin_access_history_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ─── Core ─────────────────────────────────────────────────────────────────

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<DashboardWsService>(
    () => DashboardWsService(storage: sl<SecureStorageService>()),
  );

  // ─── Auth ─────────────────────────────────────────────────────────────────

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<SecureStorageService>(),
    ),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepositoryImpl>()),
  );

  // ─── Vehicle ──────────────────────────────────────────────────────────────

  sl.registerLazySingleton<VehicleRemoteDataSourceImpl>(
    () => VehicleRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<VehicleRepositoryImpl>(
    () => VehicleRepositoryImpl(
      remoteDataSource: sl<VehicleRemoteDataSourceImpl>(),
    ),
  );

  sl.registerFactory<VehicleBloc>(
    () => VehicleBloc(repository: sl<VehicleRepositoryImpl>()),
  );

  // ─── QR ───────────────────────────────────────────────────────────────────

  sl.registerLazySingleton<QrRemoteDataSourceImpl>(
    () => QrRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<QrRepositoryImpl>(
    () => QrRepositoryImpl(
      remoteDataSource: sl<QrRemoteDataSourceImpl>(),
    ),
  );

  sl.registerFactory<QrBloc>(
    () => QrBloc(repository: sl<QrRepositoryImpl>()),
  );

  // ─── Access / History ─────────────────────────────────────────────────────

  sl.registerLazySingleton<AccessRemoteDataSourceImpl>(
    () => AccessRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AccessRepositoryImpl>(
    () => AccessRepositoryImpl(
      remoteDataSource: sl<AccessRemoteDataSourceImpl>(),
    ),
  );

  sl.registerFactory<AccessBloc>(
    () => AccessBloc(repository: sl<AccessRepositoryImpl>()),
  );

  // ─── Profile ──────────────────────────────────────────────────────────────

  sl.registerLazySingleton<ProfileRemoteDataSourceImpl>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProfileRepositoryImpl>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSourceImpl>(),
    ),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      repository: sl<ProfileRepositoryImpl>(),
      authBloc: sl<AuthBloc>(),
    ),
  );

  // ─── Admin ────────────────────────────────────────────────────────────────

  sl.registerLazySingleton<AdminRemoteDataSourceImpl>(
    () => AdminRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AdminRepositoryImpl>(
    () => AdminRepositoryImpl(
      remoteDataSource: sl<AdminRemoteDataSourceImpl>(),
    ),
  );

  sl.registerFactory<AdminBloc>(
    () => AdminBloc(repository: sl<AdminRepositoryImpl>()),
  );

  sl.registerFactory<AdminDashboardBloc>(
    () => AdminDashboardBloc(
      repository: sl<AdminRepositoryImpl>(),
      wsService: sl<DashboardWsService>(),
    ),
  );

  sl.registerFactory<AdminVehicleRequestBloc>(
    () => AdminVehicleRequestBloc(repository: sl<AdminRepositoryImpl>()),
  );

  sl.registerFactory<AdminUserBloc>(
    () => AdminUserBloc(repository: sl<AdminRepositoryImpl>()),
  );

  sl.registerFactory<AdminLogBloc>(
    () => AdminLogBloc(repository: sl<AdminRepositoryImpl>()),
  );

  sl.registerFactory<AdminAccessHistoryBloc>(
    () => AdminAccessHistoryBloc(adminRepository: sl<AdminRepositoryImpl>()),
  );
}
