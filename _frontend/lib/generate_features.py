import os

base_dir = "/home/zambrandon/Proyecto_sacavi/_frontend/lib"

files = {
    "features/auth/presentation/screens/student_shell.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicle/presentation/bloc/vehicle_event.dart';
import '../../../vehicle/presentation/screens/home_student_screen.dart';
import '../../../vehicle/presentation/screens/vehicles_screen.dart';
import '../../../qr/presentation/bloc/qr_bloc.dart';
import '../../../qr/presentation/screens/qr_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/screens/history_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeStudentScreen(),
    QrScreen(),
    VehiclesScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VehicleBloc>(
          create: (_) => di.sl<VehicleBloc>()..add(LoadVehicles()),
        ),
        BlocProvider<QrBloc>(
          create: (_) => di.sl<QrBloc>(),
        ),
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: SacaviBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isAdmin: false,
        ),
      ),
    );
  }
}
""",
    "features/auth/presentation/screens/guard_shell.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../guard/presentation/screens/guard_dashboard_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';

class GuardShell extends StatelessWidget {
  const GuardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>()..add(LoadHistory()),
        ),
      ],
      child: const Scaffold(
        body: GuardDashboardScreen(),
      ),
    );
  }
}
""",
    "features/auth/presentation/screens/admin_shell.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../admin/presentation/bloc/admin_bloc.dart';
import '../../../admin/presentation/bloc/admin_event.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../admin/presentation/screens/users_management_screen.dart';
import '../../../admin/presentation/screens/devices_screen.dart';
import '../../../admin/presentation/screens/reports_screen.dart';
import '../../../admin/presentation/screens/settings_screen.dart';
import '../../../access/presentation/bloc/access_bloc.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    UsersManagementScreen(),
    DevicesScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminBloc>(
          create: (_) => di.sl<AdminBloc>()..add(LoadAdminDashboard()),
        ),
        BlocProvider<AccessBloc>(
          create: (_) => di.sl<AccessBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: SacaviBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isAdmin: true,
        ),
      ),
    );
  }
}
""",
    "features/vehicle/data/datasources/vehicle_remote_datasource.dart": """import '../../../../core/network/api_client.dart';
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
      throw failureFromDio(e);
    }
  }

  @override
  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await apiClient.get('/vehicle/my');
      final List<dynamic> data = response.data;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
      throw failureFromDio(e);
    }
  }

  @override
  Future<void> deleteVehicle(int id) async {
    try {
      await apiClient.delete('/vehicle/$id');
    } catch (e) {
      throw failureFromDio(e);
    }
  }
}
""",
    "features/vehicle/data/repositories/vehicle_repository_impl.dart": """import '../datasources/vehicle_remote_datasource.dart';
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
""",
    "features/vehicle/presentation/bloc/vehicle_event.dart": """import 'package:equatable/equatable.dart';

sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final String plate;
  final String brand;
  final String model;
  final String color;

  const AddVehicle({required this.plate, required this.brand, required this.model, required this.color});

  @override
  List<Object?> get props => [plate, brand, model, color];
}

class DeleteVehicle extends VehicleEvent {
  final int id;

  const DeleteVehicle(this.id);

  @override
  List<Object?> get props => [id];
}
""",
    "features/vehicle/presentation/bloc/vehicle_state.dart": """import 'package:equatable/equatable.dart';
import '../../../../shared/models/vehicle_model.dart';

sealed class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;

  const VehicleLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
""",
    "features/vehicle/presentation/bloc/vehicle_bloc.dart": """import 'package:flutter_bloc/flutter_bloc.dart';
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
""",
    "features/vehicle/presentation/screens/vehicles_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _showAddVehicleSheet(BuildContext context) {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final colorController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Agregar Vehículo', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Placa'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<VehicleBloc>().add(
                    AddVehicle(
                      plate: plateController.text,
                      brand: brandController.text,
                      model: modelController.text,
                      color: colorController.text,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleError) {
            showErrorSnack(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is VehicleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VehicleLoaded) {
            final vehicles = state.vehicles;
            if (vehicles.isEmpty) {
              return const Center(child: Text('No tienes vehículos.'));
            }
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return ListTile(
                  leading: const VehicleLogo(),
                  title: Text(v.displayName),
                  subtitle: Text(v.displayInfo),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<VehicleBloc>().add(DeleteVehicle(v.idVehicle!));
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Error cargando vehículos.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
""",
    "features/vehicle/presentation/screens/home_student_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_state.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../access/presentation/bloc/access_event.dart';

class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = 'Estudiante';
    String initial = 'E';
    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      initial = authState.user.avatarInitial;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(initial)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Hola, \$name', style: AppTextStyles.h1),
                  ),
                  const OnlineDot(),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Generar Acceso', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar al tab 1 (QR). 
                        // Idealmente el BottomNav shell controla esto.
                      },
                      child: const Text('GENERAR QR'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Mi Vehículo'),
              BlocBuilder<VehicleBloc, VehicleState>(
                builder: (context, state) {
                  if (state is VehicleLoading) return const CircularProgressIndicator();
                  if (state is VehicleLoaded) {
                    if (state.vehicles.isEmpty) return const Text('Sin vehículos.');
                    final v = state.vehicles.first;
                    return ListTile(
                      leading: const VehicleLogo(),
                      title: Text(v.displayName),
                      subtitle: Text(v.displayInfo),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Historial Reciente'),
              BlocBuilder<AccessBloc, AccessState>(
                builder: (context, state) {
                  if (state is AccessLoading) return const CircularProgressIndicator();
                  if (state is AccessLoaded) {
                    final recent = state.records.take(3).toList();
                    if (recent.isEmpty) return const Text('Sin historial.');
                    return Column(
                      children: recent.map((r) => ListTile(
                        title: Text(r.vehiclePlate ?? 'Sin placa'),
                        subtitle: Text(r.parsedDateTime),
                        trailing: AccessTypeLabel(isEntrada: r.isEntrada),
                      )).toList(),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    "features/qr/data/datasources/qr_remote_datasource.dart": """import '../../../../core/network/api_client.dart';
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
      throw failureFromDio(e);
    }
  }
}
""",
    "features/qr/data/repositories/qr_repository_impl.dart": """import '../datasources/qr_remote_datasource.dart';
import '../../../../shared/models/qr_token_model.dart';

class QrRepositoryImpl {
  final QrRemoteDataSource remoteDataSource;

  QrRepositoryImpl({required this.remoteDataSource});

  Future<QrTokenModel> generateQr() {
    return remoteDataSource.generateQr();
  }
}
""",
    "features/qr/presentation/bloc/qr_event.dart": """import 'package:equatable/equatable.dart';

sealed class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class GenerateQr extends QrEvent {}

class QrRefreshed extends QrEvent {}
""",
    "features/qr/presentation/bloc/qr_state.dart": """import 'package:equatable/equatable.dart';
import '../../../../shared/models/qr_token_model.dart';

sealed class QrState extends Equatable {
  const QrState();

  @override
  List<Object?> get props => [];
}

class QrInitial extends QrState {}

class QrLoading extends QrState {}

class QrLoaded extends QrState {
  final QrTokenModel qrToken;

  const QrLoaded(this.qrToken);

  @override
  List<Object?> get props => [qrToken];
}

class QrError extends QrState {
  final String message;

  const QrError(this.message);

  @override
  List<Object?> get props => [message];
}
""",
    "features/qr/presentation/bloc/qr_bloc.dart": """import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_event.dart';
import 'qr_state.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../../../core/error/failures.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final QrRepositoryImpl repository;

  QrBloc({required this.repository}) : super(QrInitial()) {
    on<GenerateQr>(_onGenerateQr);
    on<QrRefreshed>((event, emit) => add(GenerateQr()));
  }

  Future<void> _onGenerateQr(GenerateQr event, Emitter<QrState> emit) async {
    emit(QrLoading());
    try {
      final token = await repository.generateQr();
      emit(QrLoaded(token));
    } catch (e) {
      if (e is Failure) {
        emit(QrError(e.message));
      } else {
        emit(QrError(e.toString()));
      }
    }
  }
}
""",
    "features/qr/presentation/screens/qr_screen.dart": """import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';
import '../../../../shared/theme/app_theme.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  Timer? _timer;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    context.read<QrBloc>().add(GenerateQr());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            context.read<QrBloc>().add(GenerateQr());
            _timeLeft = 30;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _timeLeft / 30.0;
    final color = progress > 0.5 ? Colors.green : (progress > 0.2 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso QR')),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (context, state) {
          if (state is QrLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QrLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, val, child) {
                      return Transform.scale(scale: val, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: QrImageView(
                        data: state.qrToken.token,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 220,
                    child: LinearProgressIndicator(
                      value: progress,
                      color: color,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Actualizando en \$_timeLeft s', style: AppTextStyles.bodyText),
                  const SizedBox(height: 32),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Este código es personal e intransferible.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                ],
              ),
            );
          } else if (state is QrError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
""",
    "features/access/data/datasources/access_remote_datasource.dart": """import '../../../../core/network/api_client.dart';
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
      throw failureFromDio(e);
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
      throw failureFromDio(e);
    }
  }
}
""",
    "features/access/data/repositories/access_repository_impl.dart": """import '../datasources/access_remote_datasource.dart';
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
""",
    "features/access/presentation/bloc/access_event.dart": """import 'package:equatable/equatable.dart';

sealed class AccessEvent extends Equatable {
  const AccessEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends AccessEvent {}

class OpenGate extends AccessEvent {
  final int idVehicle;

  const OpenGate({required this.idVehicle});

  @override
  List<Object?> get props => [idVehicle];
}
""",
    "features/access/presentation/bloc/access_state.dart": """import 'package:equatable/equatable.dart';
import '../../../../shared/models/access_record_model.dart';

sealed class AccessState extends Equatable {
  const AccessState();

  @override
  List<Object?> get props => [];
}

class AccessInitial extends AccessState {}

class AccessLoading extends AccessState {}

class AccessLoaded extends AccessState {
  final List<AccessRecordModel> records;

  const AccessLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class GateOpened extends AccessState {
  final AccessRecordModel record;

  const GateOpened(this.record);

  @override
  List<Object?> get props => [record];
}

class AccessError extends AccessState {
  final String message;

  const AccessError(this.message);

  @override
  List<Object?> get props => [message];
}
""",
    "features/access/presentation/bloc/access_bloc.dart": """import 'package:flutter_bloc/flutter_bloc.dart';
import 'access_event.dart';
import 'access_state.dart';
import '../../data/repositories/access_repository_impl.dart';
import '../../../../core/error/failures.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final AccessRepositoryImpl repository;

  AccessBloc({required this.repository}) : super(AccessInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<OpenGate>(_onOpenGate);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<AccessState> emit) async {
    emit(AccessLoading());
    try {
      final records = await repository.getHistory();
      emit(AccessLoaded(records));
    } catch (e) {
      if (e is Failure) {
        emit(AccessError(e.message));
      } else {
        emit(AccessError(e.toString()));
      }
    }
  }

  Future<void> _onOpenGate(OpenGate event, Emitter<AccessState> emit) async {
    emit(AccessLoading());
    try {
      final record = await repository.openGate(event.idVehicle);
      emit(GateOpened(record));
      // Reload history after opening
      final records = await repository.getHistory();
      emit(AccessLoaded(records));
    } catch (e) {
      if (e is Failure) {
        emit(AccessError(e.message));
      } else {
        emit(AccessError(e.toString()));
      }
    }
  }
}
""",
    "features/access/presentation/screens/history_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/access_bloc.dart';
import '../bloc/access_event.dart';
import '../bloc/access_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Accesos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Todos', label: Text('Todos')),
                ButtonSegment(value: 'ENTRADA', label: Text('Entradas')),
                ButtonSegment(value: 'SALIDA', label: Text('Salidas')),
              ],
              selected: {_filter},
              onSelectionChanged: (set) {
                setState(() => _filter = set.first);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AccessBloc, AccessState>(
              builder: (context, state) {
                if (state is AccessLoading) return const Center(child: CircularProgressIndicator());
                if (state is AccessLoaded) {
                  final records = state.records.where((r) {
                    if (_filter == 'Todos') return true;
                    if (_filter == 'ENTRADA') return r.isEntrada;
                    if (_filter == 'SALIDA') return r.isSalida;
                    return true;
                  }).toList();
                  if (records.isEmpty) return const Center(child: Text('No hay registros.'));

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final r = records[index];
                      return ListTile(
                        title: Text(r.vehiclePlate ?? 'Sin placa'),
                        subtitle: Text(r.parsedDateTime),
                        trailing: AccessTypeLabel(isEntrada: r.isEntrada),
                      );
                    },
                  );
                }
                if (state is AccessError) return Center(child: Text(state.message));
                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
""",
    "features/profile/data/datasources/profile_remote_datasource.dart": """import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String name, required String email});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get('/user/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw failureFromDio(e);
    }
  }

  @override
  Future<UserModel> updateProfile({required String name, required String email}) async {
    try {
      final response = await apiClient.put('/user/update', data: {
        'name': name,
        'email': email,
      });
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw failureFromDio(e);
    }
  }
}
""",
    "features/profile/data/repositories/profile_repository_impl.dart": """import '../datasources/profile_remote_datasource.dart';
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
""",
    "features/profile/presentation/bloc/profile_event.dart": """import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;

  const UpdateProfile({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}
""",
    "features/profile/presentation/bloc/profile_state.dart": """import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserModel user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
""",
    "features/profile/presentation/bloc/profile_bloc.dart": """import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepositoryImpl repository;
  final AuthBloc authBloc;

  ProfileBloc({required this.repository, required this.authBloc}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await repository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      if (e is Failure) {
        emit(ProfileError(e.message));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await repository.updateProfile(name: event.name, email: event.email);
      emit(ProfileUpdated(user));
      authBloc.add(AuthUserUpdated(user));
    } catch (e) {
      if (e is Failure) {
        emit(ProfileError(e.message));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
""",
    "features/profile/presentation/screens/profile_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.name),
              background: Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Text(user.avatarInitial, style: const TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nombre'),
                subtitle: Text(user.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Dialog for edit
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogout());
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
""",
    "features/guard/presentation/screens/guard_dashboard_screen.dart": """import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_event.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        context.read<AccessBloc>().add(LoadHistory());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showOpenGateDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abrir Pluma Manual'),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(labelText: 'ID Vehículo'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(idController.text);
              if (id != null) {
                context.read<AccessBloc>().add(OpenGate(idVehicle: id));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Abrir'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Guardia')),
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is GateOpened) {
            showSuccessSnack(context, 'Pluma abierta correctamente');
          } else if (state is AccessError) {
            showErrorSnack(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AccessLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccessLoaded || state is GateOpened) {
            final records = state is AccessLoaded ? state.records : [];
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sensor_door),
                    label: const Text('ABRIR PLUMA'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () => _showOpenGateDialog(context),
                  ),
                ),
                const Divider(),
                const Text('Últimos Accesos', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: records.isEmpty
                      ? const Center(child: Text('Sin accesos recientes'))
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final r = records[index];
                            return ListTile(
                              title: Text(r.vehiclePlate ?? 'Sin placa'),
                              subtitle: Text(r.parsedDateTime),
                              trailing: AccessTypeLabel(isEntrada: r.isEntrada),
                            );
                          },
                        ),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
""",
    "features/admin/data/datasources/admin_remote_datasource.dart": """import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<DeviceStatusModel> getDeviceStatus(String deviceKey);
  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey});
  Future<UserModel> changeUserRole(int userId, int roleId);
  Future<Map<String, dynamic>> getRolePermissions(int roleId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DeviceStatusModel> getDeviceStatus(String deviceKey) async {
    try {
      final response = await apiClient.get('/device/status/\$deviceKey');
      return DeviceStatusModel.fromJson(response.data);
    } catch (e) {
      throw failureFromDio(e);
    }
  }

  @override
  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey}) async {
    try {
      final response = await apiClient.post('/device/register', data: {
        'name': name,
        'location': location,
        'device_key': deviceKey,
      });
      return DeviceModel.fromJson(response.data);
    } catch (e) {
      throw failureFromDio(e);
    }
  }

  @override
  Future<UserModel> changeUserRole(int userId, int roleId) async {
    try {
      final response = await apiClient.put('/user/\$userId/role', data: {
        'id_role': roleId,
      });
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw failureFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getRolePermissions(int roleId) async {
    try {
      final response = await apiClient.get('/roles/\$roleId/permissions');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw failureFromDio(e);
    }
  }
}
""",
    "features/admin/data/repositories/admin_repository_impl.dart": """import '../datasources/admin_remote_datasource.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

class AdminRepositoryImpl {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  Future<DeviceStatusModel> getDeviceStatus(String deviceKey) {
    return remoteDataSource.getDeviceStatus(deviceKey);
  }

  Future<DeviceModel> registerDevice({required String name, required String location, required String deviceKey}) {
    return remoteDataSource.registerDevice(name: name, location: location, deviceKey: deviceKey);
  }

  Future<UserModel> changeUserRole(int userId, int roleId) {
    return remoteDataSource.changeUserRole(userId, roleId);
  }
  
  Future<Map<String, dynamic>> getRolePermissions(int roleId) {
    return remoteDataSource.getRolePermissions(roleId);
  }
}
""",
    "features/admin/presentation/bloc/admin_event.dart": """import 'package:equatable/equatable.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {}

class RegisterDevice extends AdminEvent {
  final String name;
  final String location;
  final String deviceKey;

  const RegisterDevice({required this.name, required this.location, required this.deviceKey});

  @override
  List<Object?> get props => [name, location, deviceKey];
}

class CheckDeviceStatus extends AdminEvent {
  final String deviceKey;

  const CheckDeviceStatus(this.deviceKey);

  @override
  List<Object?> get props => [deviceKey];
}

class ChangeUserRole extends AdminEvent {
  final int userId;
  final int roleId;

  const ChangeUserRole({required this.userId, required this.roleId});

  @override
  List<Object?> get props => [userId, roleId];
}
""",
    "features/admin/presentation/bloc/admin_state.dart": """import 'package:equatable/equatable.dart';
import '../../../../shared/models/device_model.dart';
import '../../../../shared/models/user_model.dart';

sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final DeviceStatusModel? deviceStatus;

  const AdminDashboardLoaded({this.deviceStatus});

  @override
  List<Object?> get props => [deviceStatus];
}

class DeviceRegistered extends AdminState {
  final DeviceModel device;

  const DeviceRegistered(this.device);

  @override
  List<Object?> get props => [device];
}

class RoleChanged extends AdminState {
  final UserModel user;

  const RoleChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
""",
    "features/admin/presentation/bloc/admin_bloc.dart": """import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../../core/error/failures.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepositoryImpl repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<RegisterDevice>(_onRegisterDevice);
    on<CheckDeviceStatus>(_onCheckDeviceStatus);
    on<ChangeUserRole>(_onChangeUserRole);
  }

  Future<void> _onLoadAdminDashboard(LoadAdminDashboard event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      emit(const AdminDashboardLoaded());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onRegisterDevice(RegisterDevice event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final device = await repository.registerDevice(
        name: event.name,
        location: event.location,
        deviceKey: event.deviceKey,
      );
      emit(DeviceRegistered(device));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onCheckDeviceStatus(CheckDeviceStatus event, Emitter<AdminState> emit) async {
    try {
      final status = await repository.getDeviceStatus(event.deviceKey);
      emit(AdminDashboardLoaded(deviceStatus: status));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onChangeUserRole(ChangeUserRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final user = await repository.changeUserRole(event.userId, event.roleId);
      emit(RoleChanged(user));
    } catch (e) {
      if (e is Failure) {
        emit(AdminError(e.message));
      } else {
        emit(AdminError(e.toString()));
      }
    }
  }
}
""",
    "features/admin/presentation/screens/admin_dashboard_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(title: 'Usuarios', value: '120', icon: Icons.people),
                StatCard(title: 'Accesos Hoy', value: '45', icon: Icons.login),
                StatCard(title: 'Dispositivos', value: '2', icon: Icons.developer_board),
                StatCard(title: 'Alertas', value: '0', icon: Icons.warning),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminDashboardLoaded && state.deviceStatus != null) {
                  return Card(
                    child: ListTile(
                      title: const Text('Estado ESP32 Main'),
                      subtitle: Text(state.deviceStatus!.isOnline ? 'En línea' : 'Desconectado'),
                      trailing: state.deviceStatus!.isOnline ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.error, color: Colors.red),
                    ),
                  );
                }
                return const Card(child: ListTile(title: Text('Estado de dispositivos desconocido')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
""",
    "features/admin/presentation/screens/devices_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final keyCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos')),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is DeviceRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo Registrado')));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Device Key')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<AdminBloc>().add(RegisterDevice(name: nameCtrl.text, location: locationCtrl.text, deviceKey: keyCtrl.text));
                },
                child: const Text('Registrar Dispositivo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""",
    "features/admin/presentation/screens/users_management_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Cambiar rol de usuario'),
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID Usuario')),
            TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'ID Rol (1=Admin, 2=Guard, 3=Student)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final uid = int.tryParse(idCtrl.text) ?? 0;
                final rid = int.tryParse(roleCtrl.text) ?? 0;
                context.read<AdminBloc>().add(ChangeUserRole(userId: uid, roleId: rid));
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}
""",
    "features/admin/presentation/screens/reports_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../access/presentation/bloc/access_bloc.dart';
import '../../../access/presentation/bloc/access_state.dart';
import '../../../access/presentation/bloc/access_event.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccessBloc>().add(LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Generales')),
      body: BlocBuilder<AccessBloc, AccessState>(
        builder: (context, state) {
          if (state is AccessLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccessLoaded) {
            return ListView.builder(
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final r = state.records[index];
                return ListTile(
                  title: Text(r.vehiclePlate ?? 'Sin placa'),
                  subtitle: Text(r.parsedDateTime),
                );
              },
            );
          }
          return const Center(child: Text('Sin datos'));
        },
      ),
    );
  }
}
""",
    "features/admin/presentation/screens/settings_screen.dart": """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Versión'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(AuthLogout());
            },
          ),
        ],
      ),
    );
  }
}
"""
}

for rel_path, content in files.items():
    full_path = os.path.join(base_dir, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content)
    print(f"Created: {full_path}")
