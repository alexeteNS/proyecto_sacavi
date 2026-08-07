import 'package:equatable/equatable.dart';

class AdminUserResponse extends Equatable {
  final int idUser;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final String? createdAt;
  final int vehicleCount;

  const AdminUserResponse({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.createdAt,
    required this.vehicleCount,
  });

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserResponse(
      idUser: json['id_user'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['created_at'],
      vehicleCount: json['vehicle_count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        idUser,
        name,
        email,
        role,
        permissions,
        createdAt,
        vehicleCount,
      ];
}
