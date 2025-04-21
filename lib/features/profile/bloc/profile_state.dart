import 'package:equatable/equatable.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState extends Equatable {
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

  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get hasError => status == ProfileStatus.error;

  @override
  List<Object?> get props => [
    status,
    user,
    photoUrl,
    errorMessage,
    isUploading,
  ];
}
