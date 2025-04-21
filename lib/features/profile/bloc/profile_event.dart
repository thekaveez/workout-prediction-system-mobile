import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String userId;
  final String? name;
  final Map<String, dynamic>? metadata;

  const ProfileUpdateRequested({
    required this.userId,
    this.name,
    this.metadata,
  });

  @override
  List<Object?> get props => [userId, name, metadata];
}

class ProfileUploadPhotoRequested extends ProfileEvent {
  final String userId;
  final String photoPath;

  const ProfileUploadPhotoRequested({
    required this.userId,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [userId, photoPath];
}

class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}
