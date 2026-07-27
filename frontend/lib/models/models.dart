enum VehicleStatus { active, inactive }
enum AccessType { entrada, salida }
enum AccessStatus { approved, rejected, pending }

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final String color;
  final VehicleStatus status;
  final String logoAsset; // brand logo identifier

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.color,
    required this.status,
    required this.logoAsset,
  });

  String get displayName => '$brand $model';
  String get displayInfo => '$plate | $color';
}

class AccessLog {
  final String id;
  final String plate;
  final DateTime timestamp;
  final AccessType type;
  final AccessStatus status;
  final String? userName;

  const AccessLog({
    required this.id,
    required this.plate,
    required this.timestamp,
    required this.type,
    required this.status,
    this.userName,
  });

  String get timeString {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get dateString {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }
}

class Student {
  final String id;
  final String name;
  final String role;
  final String avatarInitial;

  const Student({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarInitial,
  });
}

// ─── Mock data ───────────────────────────────────────────────────────────────

class MockData {
  static const student = Student(
    id: 'STU001',
    name: 'Brandon',
    role: 'ESTUDIANTE',
    avatarInitial: 'B',
  );

  static final vehicles = [
    const Vehicle(
      id: 'v1',
      brand: 'Toyota',
      model: 'Corolla',
      plate: 'ABC123',
      color: 'Blanco',
      status: VehicleStatus.active,
      logoAsset: 'toyota',
    ),
    const Vehicle(
      id: 'v2',
      brand: 'Hyundai',
      model: 'Tucson',
      plate: 'XYZ789',
      color: 'Gris',
      status: VehicleStatus.active,
      logoAsset: 'hyundai',
    ),
    const Vehicle(
      id: 'v3',
      brand: 'Honda',
      model: 'Civic',
      plate: 'DEF456',
      color: 'Azul',
      status: VehicleStatus.inactive,
      logoAsset: 'honda',
    ),
  ];

  static final accessLogs = [
    AccessLog(
      id: 'a1',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 27, 7, 6, 51),
      type: AccessType.entrada,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'a2',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 27, 18, 35, 22),
      type: AccessType.salida,
      status: AccessStatus.approved,
    ),
    AccessLog(
      id: 'a3',
      plate: 'ABC123',
      timestamp: DateTime(2027, 7, 26, 9, 12, 5),
      type: AccessType.entrada,
      status: AccessStatus.approved,
    ),
  ];

  static final guardActivity = [
    AccessLog(
      id: 'g1',
      plate: 'ABC123',
      timestamp: DateTime.now().subtract(const Duration(seconds: 3)),
      type: AccessType.entrada,
      status: AccessStatus.approved,
      userName: 'Juan Pérez',
    ),
    AccessLog(
      id: 'g2',
      plate: 'XYZ982',
      timestamp: DateTime.now().subtract(const Duration(seconds: 18)),
      type: AccessType.entrada,
      status: AccessStatus.rejected,
    ),
    AccessLog(
      id: 'g3',
      plate: 'DEF456',
      timestamp: DateTime.now().subtract(const Duration(seconds: 35)),
      type: AccessType.salida,
      status: AccessStatus.approved,
    ),
  ];
}
