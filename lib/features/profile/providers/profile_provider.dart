import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';

part 'profile_provider.g.dart';

// Profile state definition
enum ProfileStatus { initial, loading, loaded, updating, error }

// Profile state class
class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final String? photoUrl;
  final String? errorMessage;
  final bool isUploading;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.photoUrl,
    this.errorMessage,
    this.isUploading = false,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      status: ProfileStatus.initial,
      user: null,
      photoUrl: null,
      errorMessage: null,
      isUploading: false,
    );
  }

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    String? photoUrl,
    String? errorMessage,
    bool? isUploading,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      photoUrl: photoUrl ?? this.photoUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

// Profile provider
@riverpod
class Profile extends _$Profile {
  @override
  ProfileState build() {
    // Initialize with the user from auth provider if available
    final authState = ref.watch(authProvider);
    if (authState.user != null) {
      return ProfileState(
        status: ProfileStatus.loaded,
        user: authState.user,
        photoUrl: authState.user?.photoUrl,
      );
    }

    return ProfileState.initial();
  }

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(status: ProfileStatus.loading);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getUserData(userId);

      if (user != null) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          photoUrl: user.photoUrl,
        );
      } else {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'User not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);

    try {
      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await repository.updateUserProfile(
        userId: userId,
        name: name,
        metadata: metadata,
      );

      state = state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
        photoUrl: updatedUser.photoUrl,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadProfilePhoto(String userId, String photoPath) async {
    state = state.copyWith(isUploading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final photoUrl = await repository.uploadProfilePicture(
        userId,
        File(photoPath),
      );

      // Get updated user data
      final updatedUser = await repository.getUserData(userId);

      state = state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
        photoUrl: photoUrl,
        isUploading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
        isUploading: false,
      );
    }
  }

  void signOut() {
    state = ProfileState.initial();
    ref.read(authProvider.notifier).signOut();
  }
}
