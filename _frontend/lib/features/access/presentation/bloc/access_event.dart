import 'package:equatable/equatable.dart';

sealed class AccessEvent extends Equatable {
  const AccessEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends AccessEvent {}

class OpenGate extends AccessEvent {
  final int idVehicle;

  const OpenGate({required this.idVehicle});

  @override
  List<Object?> get props => [idVehicle];
}
