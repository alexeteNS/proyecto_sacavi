import 'package:equatable/equatable.dart';
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
