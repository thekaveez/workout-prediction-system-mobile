import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/profile/bloc/profile_event.dart';
import 'package:workout_prediction_system_mobile/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(ProfileState.initial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileUploadPhotoRequested>(_onProfileUploadPhotoRequested);
    on<ProfileSignOutRequested>(_onProfileSignOutRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final user = await _authRepository.getUserData(event.userId);
      if (user != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            user: user,
            photoUrl: user.photoUrl,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'User not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      final updatedUser = await _authRepository.updateUserProfile(
        userId: event.userId,
        name: event.name,
        metadata: event.metadata,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: updatedUser,
          photoUrl: updatedUser.photoUrl,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onProfileUploadPhotoRequested(
    ProfileUploadPhotoRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploading: true));

    try {
      final photoUrl = await _authRepository.uploadProfilePicture(
        event.userId,
        File(event.photoPath),
      );

      // Get updated user data
      final updatedUser = await _authRepository.getUserData(event.userId);

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: updatedUser,
          photoUrl: photoUrl,
          isUploading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: e.toString(),
          isUploading: false,
        ),
      );
    }
  }

  Future<void> _onProfileSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Emit initial state immediately
    emit(
      state.copyWith(status: ProfileStatus.initial, user: null, photoUrl: null),
    );

    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
