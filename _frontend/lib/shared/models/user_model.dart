import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Corresponde exactamente a [UserResponseDto] del backend.
/// Campos: id_user, name, email, role, permissions[]
class UserModel extends Equatable {
  const UserModel({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
  });

  final int idUser;
  final String name;
  final String email;

  /// Valores posibles: "ESTUDIANTE" | "GUARDIA" | "ADMIN"
  final String role;
  final List<String> permissions;

  // ─── Constructores ────────────────────────────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        idUser: json['id_user'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        permissions: List<String>.from(json['permissions'] as List),
      );

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'name': name,
        'email': email,
        'role': role,
        'permissions': permissions,
      };

  /// Serializa a String para guardarlo en SecureStorage.
  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String raw) =>
      UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  // ─── Helpers de rol ───────────────────────────────────────────────────────

  bool get isStudent => role == 'ESTUDIANTE';
  bool get isGuard => role == 'GUARDIA';
  bool get isAdmin => role == 'ADMIN';

  UserModel copyWith({
    int? idUser,
    String? name,
    String? email,
    String? role,
    List<String>? permissions,
  }) =>
      UserModel(
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        permissions: permissions ?? this.permissions,
      );

  /// Inicial del nombre para el avatar.
  String get avatarInitial =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [idUser, name, email, role, permissions];
}
