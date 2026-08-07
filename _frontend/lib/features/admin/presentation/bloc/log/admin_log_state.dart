import 'package:equatable/equatable.dart';
import '../../../../../shared/models/system_log_model.dart';

abstract class AdminLogState extends Equatable {
  const AdminLogState();

  @override
  List<Object?> get props => [];
}

class AdminLogInitial extends AdminLogState {}

class AdminLogLoading extends AdminLogState {}

class AdminLogsLoaded extends AdminLogState {
  final List<SystemLogModel> logs;

  const AdminLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class AdminLogError extends AdminLogState {
  final String message;
  const AdminLogError(this.message);

  @override
  List<Object?> get props => [message];
}
