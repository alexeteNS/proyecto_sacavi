import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_event.dart';
import 'qr_state.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../../../core/error/failures.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final QrRepositoryImpl repository;

  QrBloc({required this.repository}) : super(QrInitial()) {
    on<GenerateQr>(_onGenerateQr);
    on<QrRefreshed>((event, emit) => add(GenerateQr()));
  }

  Future<void> _onGenerateQr(GenerateQr event, Emitter<QrState> emit) async {
    emit(QrLoading());
    try {
      final token = await repository.generateQr();
      emit(QrLoaded(token));
    } catch (e) {
      if (e is Failure) {
        emit(QrError(e.message));
      } else {
        emit(QrError(e.toString()));
      }
    }
  }
}
