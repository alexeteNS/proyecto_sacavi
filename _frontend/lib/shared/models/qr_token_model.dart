import 'package:equatable/equatable.dart';

/// Corresponde exactamente a [QrGenerateResponse] del backend.
/// Campos: token (UUID), expires_in_seconds (30)
class QrTokenModel extends Equatable {
  const QrTokenModel({
    required this.token,
    required this.expiresInSeconds,
  });

  final String token;
  final int expiresInSeconds;

  factory QrTokenModel.fromJson(Map<String, dynamic> json) => QrTokenModel(
        token: json['token'] as String,
        expiresInSeconds: json['expires_in_seconds'] as int,
      );

  @override
  List<Object?> get props => [token, expiresInSeconds];
}
