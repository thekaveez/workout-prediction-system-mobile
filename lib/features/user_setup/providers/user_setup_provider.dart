import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/models/user_setup_data.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/repositories/user_setup_repository.dart';

// Repository provider
final userSetupRepositoryProvider = Provider<UserSetupRepository>((ref) {
  return UserSetupRepository();
});

// State class for user setup
class UserSetupState {
  final UserSetupData? setupData;
  final bool isLoading;
  final String? errorMessage;
  final bool hasCompletedSetup;

  UserSetupState({
    this.setupData,
    this.isLoading = false,
    this.errorMessage,
    this.hasCompletedSetup = false,
  });

  UserSetupState copyWith({
    UserSetupData? setupData,
    bool? isLoading,
    String? errorMessage,
    bool? hasCompletedSetup,
  }) {
    return UserSetupState(
      setupData: setupData ?? this.setupData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }
}

// Notifier for user setup
class UserSetupNotifier extends StateNotifier<UserSetupState> {
  final UserSetupRepository _repository;

  UserSetupNotifier(this._repository) : super(UserSetupState());

  // Save user setup data
  Future<void> saveUserSetupData({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final setupData = UserSetupData(
        age: age,
        weight: weight,
        height: height,
        gender: gender,
        activityLevel: activityLevel,
      );

      await _repository.saveUserSetupData(setupData);

      state = state.copyWith(
        setupData: setupData,
        isLoading: false,
        hasCompletedSetup: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save setup data: ${e.toString()}',
      );
    }
  }

  // Load user setup data
  Future<void> loadUserSetupData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final hasCompletedSetup = await _repository.hasUserCompletedSetup();

      if (hasCompletedSetup) {
        final setupData = await _repository.getUserSetupData();
        state = state.copyWith(
          setupData: setupData,
          isLoading: false,
          hasCompletedSetup: true,
        );
      } else {
        state = state.copyWith(isLoading: false, hasCompletedSetup: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load setup data: ${e.toString()}',
      );
    }
  }
}

// Provider for user setup state
final userSetupProvider =
    StateNotifierProvider<UserSetupNotifier, UserSetupState>((ref) {
      final repository = ref.watch(userSetupRepositoryProvider);
      return UserSetupNotifier(repository);
    });

// Provider to check if setup is complete
final hasCompletedSetupProvider = Provider<bool>((ref) {
  return ref.watch(userSetupProvider).hasCompletedSetup;
});

// Provider to get the user setup data
final userSetupDataProvider = Provider<UserSetupData?>((ref) {
  return ref.watch(userSetupProvider).setupData;
});
