import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/models/meal_plan.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/repositories/meal_prediction_repository.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/models/user_setup_data.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/providers/user_setup_provider.dart';

// Repository provider
final mealPredictionRepositoryProvider = Provider<MealPredictionRepository>((
  ref,
) {
  return MealPredictionRepository();
});

enum MealPredictionStatus { initial, loading, loaded, error }

// State class for meal prediction
class MealPredictionState {
  final MealPlan? mealPlan;
  final MealPredictionStatus status;
  final String? errorMessage;
  final int? predictionLabel;
  final UserSetupData? userData;

  MealPredictionState({
    this.mealPlan,
    this.status = MealPredictionStatus.initial,
    this.errorMessage,
    this.predictionLabel,
    this.userData,
  });

  MealPredictionState copyWith({
    MealPlan? mealPlan,
    MealPredictionStatus? status,
    String? errorMessage,
    int? predictionLabel,
    UserSetupData? userData,
  }) {
    return MealPredictionState(
      mealPlan: mealPlan ?? this.mealPlan,
      status: status ?? this.status,
      errorMessage: errorMessage,
      predictionLabel: predictionLabel ?? this.predictionLabel,
      userData: userData ?? this.userData,
    );
  }
}

// Notifier for meal prediction
class MealPredictionNotifier extends StateNotifier<MealPredictionState> {
  final MealPredictionRepository _repository;
  final Ref _ref;

  MealPredictionNotifier(this._repository, this._ref)
    : super(MealPredictionState());

  // Get meal prediction and fetch meal plan
  Future<void> getMealPrediction() async {
    try {
      // Get user setup data
      final userData = _ref.read(userSetupDataProvider);

      if (userData == null) {
        state = state.copyWith(
          status: MealPredictionStatus.error,
          errorMessage:
              'User setup data not available. Please complete your profile setup.',
        );
        return;
      }

      state = state.copyWith(
        status: MealPredictionStatus.loading,
        errorMessage: null,
        userData: userData,
      );

      // Get prediction from API
      final prediction = await _repository.getMealPrediction(userData);

      // Fetch meal plan based on prediction
      final mealPlan = await _repository.getMealPlanByLabel(prediction);

      state = state.copyWith(
        mealPlan: mealPlan,
        status: MealPredictionStatus.loaded,
        predictionLabel: prediction,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealPredictionStatus.error,
        errorMessage: 'Failed to get meal prediction: ${e.toString()}',
      );
    }
  }

  // Get meal plan by label directly (bypassing prediction)
  Future<void> getMealPlanByLabel(int labelNumber) async {
    try {
      state = state.copyWith(
        status: MealPredictionStatus.loading,
        errorMessage: null,
      );

      final mealPlan = await _repository.getMealPlanByLabel(labelNumber);

      state = state.copyWith(
        mealPlan: mealPlan,
        status: MealPredictionStatus.loaded,
        predictionLabel: labelNumber,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealPredictionStatus.error,
        errorMessage: 'Failed to get meal plan: ${e.toString()}',
      );
    }
  }
}

// Provider for meal prediction state
final mealPredictionProvider =
    StateNotifierProvider<MealPredictionNotifier, MealPredictionState>((ref) {
      final repository = ref.watch(mealPredictionRepositoryProvider);
      return MealPredictionNotifier(repository, ref);
    });
