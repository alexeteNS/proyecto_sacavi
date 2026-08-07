import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class StartDashboardListening extends AdminDashboardEvent {}

class StopDashboardListening extends AdminDashboardEvent {}

class DashboardUpdateReceived extends AdminDashboardEvent {
  final Map<String, dynamic> data;

  const DashboardUpdateReceived(this.data);

  @override
  List<Object?> get props => [data];
}
