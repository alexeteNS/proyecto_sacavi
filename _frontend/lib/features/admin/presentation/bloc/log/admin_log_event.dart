import 'package:equatable/equatable.dart';

abstract class AdminLogEvent extends Equatable {
  const AdminLogEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminLogs extends AdminLogEvent {
  final Map<String, dynamic> filters;
  const LoadAdminLogs({this.filters = const {}});

  @override
  List<Object?> get props => [filters];
}
