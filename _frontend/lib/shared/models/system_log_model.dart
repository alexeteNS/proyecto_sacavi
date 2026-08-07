import 'package:equatable/equatable.dart';

class SystemLogModel extends Equatable {
  const SystemLogModel({
    required this.idLog,
    this.idUser,
    required this.action,
    this.device,
    required this.result,
    required this.createdAt,
  });

  final int idLog;
  final int? idUser;
  final String action;
  final String? device;
  final String result;
  final String createdAt;

  factory SystemLogModel.fromJson(Map<String, dynamic> json) => SystemLogModel(
        idLog: json['id_log'] as int,
        idUser: json['id_user'] as int?,
        action: json['action'] as String,
        device: json['device'] as String?,
        result: json['result'] as String,
        createdAt: json['created_at'] as String,
      );

  @override
  List<Object?> get props => [idLog, idUser, action, device, result, createdAt];
}
