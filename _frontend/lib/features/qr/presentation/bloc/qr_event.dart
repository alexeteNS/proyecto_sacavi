import 'package:equatable/equatable.dart';

sealed class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class GenerateQr extends QrEvent {}

class QrRefreshed extends QrEvent {}
