import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepositoryImpl repository;
  final AuthBloc authBloc;

  ProfileBloc({required this.repository, required this.authBloc}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await repository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      if (e is Failure) {
        emit(ProfileError(e.message));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await repository.updateProfile(name: event.name, email: event.email);
      emit(ProfileUpdated(user));
      authBloc.add(AuthUserUpdated(user));
    } catch (e) {
      if (e is Failure) {
        emit(ProfileError(e.message));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
