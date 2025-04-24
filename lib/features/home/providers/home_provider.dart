import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/home/models/daily_summary.dart';
import 'package:workout_prediction_system_mobile/features/home/models/health_tip.dart';
import 'package:workout_prediction_system_mobile/features/home/models/meal_plan.dart';

part 'home_provider.g.dart';

// Home state definition
enum HomeStatus { initial, loading, loaded, error }

// Home state class
class HomeState {
  final HomeStatus status;
  final String username;
  final String? photoUrl;
  final DateTime date;
  final DailySummary? dailySummary;
  final MealPlan? mealPlan;
  final List<HealthTip>? healthTips;
  final bool isGeneratingNewMealPlan;
  final bool isSwappingMeal;
  final String? errorMessage;

  HomeState({
    this.status = HomeStatus.initial,
    this.username = 'User',
    this.photoUrl,
    DateTime? date,
    this.dailySummary,
    this.mealPlan,
    this.healthTips,
    this.isGeneratingNewMealPlan = false,
    this.isSwappingMeal = false,
    this.errorMessage,
  }) : date = date ?? DateTime.now();

  factory HomeState.initial() {
    return HomeState(
      status: HomeStatus.initial,
      username: 'User',
      date: null,
      dailySummary: null,
      mealPlan: null,
      healthTips: null,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    String? username,
    String? photoUrl,
    DateTime? date,
    DailySummary? dailySummary,
    MealPlan? mealPlan,
    List<HealthTip>? healthTips,
    bool? isGeneratingNewMealPlan,
    bool? isSwappingMeal,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
      dailySummary: dailySummary ?? this.dailySummary,
      mealPlan: mealPlan ?? this.mealPlan,
      healthTips: healthTips ?? this.healthTips,
      isGeneratingNewMealPlan:
          isGeneratingNewMealPlan ?? this.isGeneratingNewMealPlan,
      isSwappingMeal: isSwappingMeal ?? this.isSwappingMeal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Home provider
@riverpod
class Home extends _$Home {
  @override
  HomeState build() {
    return HomeState.initial();
  }

  Future<void> initialLoad() async {
    state = state.copyWith(status: HomeStatus.loading);

    try {
      String username = 'User';
      String? photoUrl;

      // Get user data
      final authState = ref.read(authProvider);
      final authRepository = ref.read(authRepositoryProvider);

      if (authState.user != null) {
        // Get latest user data
        final userData = await authRepository.getUserData(authState.user!.id);
        if (userData != null) {
          username = userData.name;
          photoUrl = userData.photoUrl;
        }
      }

      // Mock data for other parts of the UI
      final dailySummary = _getMockDailySummary();
      final mealPlan = _getMockMealPlan();
      final healthTips = _getMockHealthTips();

      state = state.copyWith(
        status: HomeStatus.loaded,
        username: username,
        photoUrl: photoUrl,
        date: DateTime.now(),
        dailySummary: dailySummary,
        mealPlan: mealPlan,
        healthTips: healthTips,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshData() async {
    if (state.status != HomeStatus.loaded) return;

    state = state.copyWith(isGeneratingNewMealPlan: true);

    try {
      String username = state.username;
      String? photoUrl = state.photoUrl;

      // Get latest user data
      final authState = ref.read(authProvider);
      final authRepository = ref.read(authRepositoryProvider);

      if (authState.user != null) {
        final userData = await authRepository.getUserData(authState.user!.id);
        if (userData != null) {
          username = userData.name;
          photoUrl = userData.photoUrl;
        }
      }

      // In a real app, this would refresh data from a repository
      // For now, we'll use mock data with slight variations
      final updatedDailySummary = DailySummary(
        caloriesConsumed: state.dailySummary!.caloriesConsumed + 50,
        caloriesGoal: state.dailySummary!.caloriesGoal,
        stepsTaken: state.dailySummary!.stepsTaken + 100,
        stepsGoal: state.dailySummary!.stepsGoal,
        sittingMinutes: state.dailySummary!.sittingMinutes + 10,
        sittingGoalMinutes: state.dailySummary!.sittingGoalMinutes,
      );

      state = state.copyWith(
        username: username,
        photoUrl: photoUrl,
        dailySummary: updatedDailySummary,
        isGeneratingNewMealPlan: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> generateNewMealPlan() async {
    if (state.status != HomeStatus.loaded) return;

    state = state.copyWith(isGeneratingNewMealPlan: true);

    try {
      // In a real app, this would call an AI service to generate a new meal plan
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      final newMealPlan = _getMockMealPlan(variation: true);

      state = state.copyWith(
        mealPlan: newMealPlan,
        isGeneratingNewMealPlan: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> swapMeal({required String mealType, int? snackIndex}) async {
    if (state.status != HomeStatus.loaded) return;

    state = state.copyWith(isSwappingMeal: true);

    try {
      // In a real app, this would call an AI service to swap a specific meal
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay

      // Create a new meal plan with the swapped meal
      MealPlan newMealPlan;

      switch (mealType) {
        case 'breakfast':
          newMealPlan = MealPlan(
            breakfast: Meal(
              name: 'Greek Yogurt with Berries',
              description: 'Greek yogurt topped with mixed berries and honey',
              calories: 320,
              imageUrl: 'assets/images/meals/greek_yogurt.jpg',
              macros: {'protein': 20, 'carbs': 35, 'fats': 10},
            ),
            lunch: state.mealPlan!.lunch,
            dinner: state.mealPlan!.dinner,
            snacks: state.mealPlan!.snacks,
          );
          break;
        case 'lunch':
          newMealPlan = MealPlan(
            breakfast: state.mealPlan!.breakfast,
            lunch: Meal(
              name: 'Quinoa Salad',
              description: 'Quinoa with roasted vegetables and feta cheese',
              calories: 420,
              imageUrl: 'assets/images/meals/quinoa_salad.jpg',
              macros: {'protein': 15, 'carbs': 60, 'fats': 12},
            ),
            dinner: state.mealPlan!.dinner,
            snacks: state.mealPlan!.snacks,
          );
          break;
        case 'dinner':
          newMealPlan = MealPlan(
            breakfast: state.mealPlan!.breakfast,
            lunch: state.mealPlan!.lunch,
            dinner: Meal(
              name: 'Baked Salmon',
              description: 'Baked salmon with steamed vegetables',
              calories: 380,
              imageUrl: 'assets/images/meals/salmon.jpg',
              macros: {'protein': 30, 'carbs': 15, 'fats': 20},
            ),
            snacks: state.mealPlan!.snacks,
          );
          break;
        case 'snack':
          if (snackIndex != null &&
              snackIndex < state.mealPlan!.snacks.length) {
            final newSnacks = List<Meal>.from(state.mealPlan!.snacks);
            newSnacks[snackIndex] = Meal(
              name: 'Apple with Almond Butter',
              description: 'Sliced apple with a tablespoon of almond butter',
              calories: 180,
              imageUrl: 'assets/images/meals/apple_almond.jpg',
              macros: {'protein': 5, 'carbs': 20, 'fats': 10},
            );

            newMealPlan = MealPlan(
              breakfast: state.mealPlan!.breakfast,
              lunch: state.mealPlan!.lunch,
              dinner: state.mealPlan!.dinner,
              snacks: newSnacks,
            );
          } else {
            newMealPlan = state.mealPlan!;
          }
          break;
        default:
          newMealPlan = state.mealPlan!;
      }

      state = state.copyWith(mealPlan: newMealPlan, isSwappingMeal: false);
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Mock data methods
  DailySummary _getMockDailySummary() {
    return const DailySummary(
      caloriesConsumed: 1240,
      caloriesGoal: 2000,
      stepsTaken: 6500,
      stepsGoal: 10000,
      sittingMinutes: 240,
      sittingGoalMinutes: 360,
    );
  }

  MealPlan _getMockMealPlan({bool variation = false}) {
    if (!variation) {
      return MealPlan(
        breakfast: Meal(
          name: 'Avocado Toast',
          description: 'Whole grain toast with avocado and poached eggs',
          calories: 380,
          imageUrl: 'assets/images/meals/avocado_toast.jpg',
          macros: {'protein': 15, 'carbs': 30, 'fats': 22},
        ),
        lunch: Meal(
          name: 'Chicken Salad',
          description: 'Grilled chicken with mixed greens and vinaigrette',
          calories: 450,
          imageUrl: 'assets/images/meals/chicken_salad.jpg',
          macros: {'protein': 35, 'carbs': 15, 'fats': 25},
        ),
        dinner: Meal(
          name: 'Salmon with Quinoa',
          description: 'Grilled salmon with quinoa and steamed vegetables',
          calories: 520,
          imageUrl: 'assets/images/meals/salmon_quinoa.jpg',
          macros: {'protein': 40, 'carbs': 45, 'fats': 18},
        ),
        snacks: [
          Meal(
            name: 'Protein Smoothie',
            description: 'Banana and berry protein smoothie',
            calories: 220,
            imageUrl: 'assets/images/meals/protein_smoothie.jpg',
            macros: {'protein': 20, 'carbs': 25, 'fats': 5},
          ),
          Meal(
            name: 'Mixed Nuts',
            description: 'A handful of mixed nuts and dried fruits',
            calories: 180,
            imageUrl: 'assets/images/meals/mixed_nuts.jpg',
            macros: {'protein': 6, 'carbs': 12, 'fats': 14},
          ),
        ],
      );
    } else {
      // Variation for when generating new meal plan
      return MealPlan(
        breakfast: Meal(
          name: 'Protein Pancakes',
          description: 'Protein pancakes with maple syrup and berries',
          calories: 420,
          imageUrl: 'assets/images/meals/protein_pancakes.jpg',
          macros: {'protein': 25, 'carbs': 45, 'fats': 12},
        ),
        lunch: Meal(
          name: 'Turkey Wrap',
          description: 'Turkey breast wrap with avocado and vegetables',
          calories: 380,
          imageUrl: 'assets/images/meals/turkey_wrap.jpg',
          macros: {'protein': 30, 'carbs': 30, 'fats': 15},
        ),
        dinner: Meal(
          name: 'Vegetable Stir Fry',
          description: 'Tofu and vegetable stir fry with brown rice',
          calories: 420,
          imageUrl: 'assets/images/meals/stir_fry.jpg',
          macros: {'protein': 22, 'carbs': 55, 'fats': 12},
        ),
        snacks: [
          Meal(
            name: 'Greek Yogurt',
            description: 'Greek yogurt with honey and walnuts',
            calories: 180,
            imageUrl: 'assets/images/meals/greek_yogurt_snack.jpg',
            macros: {'protein': 15, 'carbs': 12, 'fats': 8},
          ),
          Meal(
            name: 'Energy Bar',
            description: 'Homemade energy bar with dates and nuts',
            calories: 150,
            imageUrl: 'assets/images/meals/energy_bar.jpg',
            macros: {'protein': 5, 'carbs': 18, 'fats': 7},
          ),
        ],
      );
    }
  }

  List<HealthTip> _getMockHealthTips() {
    return [
      HealthTip(
        title: 'Stay Hydrated',
        description:
            'Aim to drink at least 8 glasses of water daily for optimal health.',
        icon: 'water_drop',
        category: 'hydration',
      ),
      HealthTip(
        title: 'Take Stretch Breaks',
        description:
            'Take a 5-minute stretch break for every hour of sitting to improve circulation.',
        icon: 'fitness_center',
        category: 'activity',
      ),
      HealthTip(
        title: 'Balanced Nutrition',
        description:
            'Include proteins, complex carbs, and healthy fats in each meal for balanced nutrition.',
        icon: 'restaurant',
        category: 'nutrition',
      ),
    ];
  }
}
