import 'package:equatable/equatable.dart';
import 'package:workout_prediction_system_mobile/features/home/models/daily_summary.dart';
import 'package:workout_prediction_system_mobile/features/home/models/health_tip.dart';
import 'package:workout_prediction_system_mobile/features/home/models/meal_plan.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  final String username;
  final String? photoUrl;
  final DateTime date;
  final DailySummary dailySummary;
  final MealPlan mealPlan;
  final List<HealthTip> healthTips;
  final bool isGeneratingNewMealPlan;
  final bool isSwappingMeal;

  const HomeLoadedState({
    required this.username,
    this.photoUrl,
    required this.date,
    required this.dailySummary,
    required this.mealPlan,
    required this.healthTips,
    this.isGeneratingNewMealPlan = false,
    this.isSwappingMeal = false,
  });

  @override
  List<Object?> get props => [
    username,
    photoUrl,
    date,
    dailySummary,
    mealPlan,
    healthTips,
    isGeneratingNewMealPlan,
    isSwappingMeal,
  ];

  HomeLoadedState copyWith({
    String? username,
    String? photoUrl,
    DateTime? date,
    DailySummary? dailySummary,
    MealPlan? mealPlan,
    List<HealthTip>? healthTips,
    bool? isGeneratingNewMealPlan,
    bool? isSwappingMeal,
  }) {
    return HomeLoadedState(
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
      dailySummary: dailySummary ?? this.dailySummary,
      mealPlan: mealPlan ?? this.mealPlan,
      healthTips: healthTips ?? this.healthTips,
      isGeneratingNewMealPlan:
          isGeneratingNewMealPlan ?? this.isGeneratingNewMealPlan,
      isSwappingMeal: isSwappingMeal ?? this.isSwappingMeal,
    );
  }
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
