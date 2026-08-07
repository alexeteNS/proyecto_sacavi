import 'package:equatable/equatable.dart';
import '../../../../../shared/models/access_history_model.dart';

abstract class AdminAccessHistoryEvent extends Equatable {
  const AdminAccessHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccessHistory extends AdminAccessHistoryEvent {
  final Map<String, dynamic> filters;
  const LoadAccessHistory({this.filters = const {}});

  @override
  List<Object?> get props => [filters];
}

class LoadAccessStats extends AdminAccessHistoryEvent {}

class AddNewAccessRecord extends AdminAccessHistoryEvent {
  final AccessHistoryModel record;
  const AddNewAccessRecord(this.record);

  @override
  List<Object?> get props => [record];
}
