import 'package:equatable/equatable.dart';
import '../../../../shared/models/qr_token_model.dart';

sealed class QrState extends Equatable {
  const QrState();

  @override
  List<Object?> get props => [];
}

class QrInitial extends QrState {}

class QrLoading extends QrState {}

class QrLoaded extends QrState {
  final QrTokenModel qrToken;

  const QrLoaded(this.qrToken);

  @override
  List<Object?> get props => [qrToken];
}

class QrError extends QrState {
  final String message;

  const QrError(this.message);

  @override
  List<Object?> get props => [message];
}
