import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_event.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_state.dart';
import 'package:workout_prediction_system_mobile/features/home/models/daily_summary.dart';
import 'package:workout_prediction_system_mobile/features/home/models/health_tip.dart';
import 'package:workout_prediction_system_mobile/features/home/models/meal_plan.dart';
import 'package:workout_prediction_system_mobile/features/profile/screens/profile_screen.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthBloc? _authBloc;
  final AuthRepository? _authRepository;

  HomeBloc({AuthBloc? authBloc, AuthRepository? authRepository})
    : _authBloc = authBloc,
      _authRepository = authRepository,
      super(const HomeInitialState()) {
    on<HomeInitialLoadEvent>(_onInitialLoad);
    on<HomeRefreshDataEvent>(_onRefreshData);
    on<GenerateNewMealPlanEvent>(_onGenerateNewMealPlan);
    on<SwapMealEvent>(_onSwapMeal);
    on<NavigateToProfileEvent>(_onNavigateToProfile);
  }

  Future<void> _onInitialLoad(
    HomeInitialLoadEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());
    try {
      String username = 'User';
      String? photoUrl;

      // Get user data if we have auth dependencies
      if (_authBloc != null && _authRepository != null) {
        final currentUser = _authBloc!.state.user;
        if (currentUser != null) {
          // Get latest user data
          final userData = await _authRepository!.getUserData(currentUser.id);
          if (userData != null) {
            username = userData.name;
            photoUrl = userData.photoUrl;
          }
        }
      }

      // Mock data for other parts of the UI
      final dailySummary = _getMockDailySummary();
      final mealPlan = _getMockMealPlan();
      final healthTips = _getMockHealthTips();

      emit(
        HomeLoadedState(
          username: username,
          photoUrl: photoUrl,
          date: DateTime.now(),
          dailySummary: dailySummary,
          mealPlan: mealPlan,
          healthTips: healthTips,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefreshData(
    HomeRefreshDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(isGeneratingNewMealPlan: true));

      try {
        String username = currentState.username;
        String? photoUrl = currentState.photoUrl;

        // Get latest user data if we have auth dependencies
        if (_authBloc != null && _authRepository != null) {
          final currentUser = _authBloc!.state.user;
          if (currentUser != null) {
            final userData = await _authRepository!.getUserData(currentUser.id);
            if (userData != null) {
              username = userData.name;
              photoUrl = userData.photoUrl;
            }
          }
        }

        // In a real app, this would refresh data from a repository
        // For now, we'll use mock data with slight variations
        final updatedDailySummary = DailySummary(
          caloriesConsumed: currentState.dailySummary.caloriesConsumed + 50,
          caloriesGoal: currentState.dailySummary.caloriesGoal,
          stepsTaken: currentState.dailySummary.stepsTaken + 100,
          stepsGoal: currentState.dailySummary.stepsGoal,
          sittingMinutes: currentState.dailySummary.sittingMinutes + 10,
          sittingGoalMinutes: currentState.dailySummary.sittingGoalMinutes,
        );

        emit(
          currentState.copyWith(
            username: username,
            photoUrl: photoUrl,
            dailySummary: updatedDailySummary,
            isGeneratingNewMealPlan: false,
          ),
        );
      } catch (e) {
        emit(HomeErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onGenerateNewMealPlan(
    GenerateNewMealPlanEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(isGeneratingNewMealPlan: true));

      try {
        // In a real app, this would call an AI service to generate a new meal plan
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Simulate network delay
        final newMealPlan = _getMockMealPlan(variation: true);

        emit(
          currentState.copyWith(
            mealPlan: newMealPlan,
            isGeneratingNewMealPlan: false,
          ),
        );
      } catch (e) {
        emit(HomeErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _onSwapMeal(SwapMealEvent event, Emitter<HomeState> emit) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(isSwappingMeal: true));

      try {
        // In a real app, this would call an AI service to swap a specific meal
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Simulate network delay

        // Create a new meal plan with the swapped meal
        MealPlan newMealPlan;

        switch (event.mealType) {
          case 'breakfast':
            newMealPlan = MealPlan(
              breakfast: Meal(
                name: 'Greek Yogurt with Berries',
                description: 'Greek yogurt topped with mixed berries and honey',
                calories: 320,
                imageUrl: 'assets/images/meals/greek_yogurt.jpg',
                macros: {'protein': 20, 'carbs': 35, 'fats': 10},
              ),
              lunch: currentState.mealPlan.lunch,
              dinner: currentState.mealPlan.dinner,
              snacks: currentState.mealPlan.snacks,
            );
            break;
          case 'lunch':
            newMealPlan = MealPlan(
              breakfast: currentState.mealPlan.breakfast,
              lunch: Meal(
                name: 'Quinoa Salad',
                description: 'Quinoa with roasted vegetables and feta cheese',
                calories: 420,
                imageUrl: 'assets/images/meals/quinoa_salad.jpg',
                macros: {'protein': 15, 'carbs': 60, 'fats': 12},
              ),
              dinner: currentState.mealPlan.dinner,
              snacks: currentState.mealPlan.snacks,
            );
            break;
          case 'dinner':
            newMealPlan = MealPlan(
              breakfast: currentState.mealPlan.breakfast,
              lunch: currentState.mealPlan.lunch,
              dinner: Meal(
                name: 'Baked Salmon',
                description: 'Baked salmon with steamed vegetables',
                calories: 380,
                imageUrl: 'assets/images/meals/salmon.jpg',
                macros: {'protein': 30, 'carbs': 15, 'fats': 20},
              ),
              snacks: currentState.mealPlan.snacks,
            );
            break;
          case 'snack':
            if (event.snackIndex != null &&
                event.snackIndex! < currentState.mealPlan.snacks.length) {
              final newSnacks = List<Meal>.from(currentState.mealPlan.snacks);
              newSnacks[event.snackIndex!] = Meal(
                name: 'Apple with Almond Butter',
                description: 'Sliced apple with a tablespoon of almond butter',
                calories: 180,
                imageUrl: 'assets/images/meals/apple_almond.jpg',
                macros: {'protein': 5, 'carbs': 20, 'fats': 10},
              );

              newMealPlan = MealPlan(
                breakfast: currentState.mealPlan.breakfast,
                lunch: currentState.mealPlan.lunch,
                dinner: currentState.mealPlan.dinner,
                snacks: newSnacks,
              );
            } else {
              newMealPlan = currentState.mealPlan;
            }
            break;
          default:
            newMealPlan = currentState.mealPlan;
        }

        emit(
          currentState.copyWith(mealPlan: newMealPlan, isSwappingMeal: false),
        );
      } catch (e) {
        emit(HomeErrorState(message: e.toString()));
      }
    }
  }

  void _onNavigateToProfile(
    NavigateToProfileEvent event,
    Emitter<HomeState> emit,
  ) {
    // Navigation to profile screen will be handled in the UI
    // We don't need to update state here
  }

  // Mock data methods
  DailySummary _getMockDailySummary() {
    return const DailySummary(
      caloriesConsumed: 1240,
      caloriesGoal: 1800,
      stepsTaken: 3450,
      stepsGoal: 10000,
      sittingMinutes: 200, // 3h 20m
      sittingGoalMinutes: 300,
    );
  }

  MealPlan _getMockMealPlan({bool variation = false}) {
    if (variation) {
      return MealPlan(
        breakfast: Meal(
          name: 'Oatmeal with Banana',
          description: 'Steel-cut oats with sliced banana and cinnamon',
          calories: 300,
          imageUrl: 'assets/images/meals/oatmeal_banana.jpg',
          macros: {'protein': 10, 'carbs': 50, 'fats': 5},
        ),
        lunch: Meal(
          name: 'Mediterranean Bowl',
          description:
              'Quinoa, chickpeas, cucumber, tomato with tahini dressing',
          calories: 450,
          imageUrl: 'assets/images/meals/med_bowl.jpg',
          macros: {'protein': 18, 'carbs': 65, 'fats': 12},
        ),
        dinner: Meal(
          name: 'Grilled Chicken Salad',
          description:
              'Grilled chicken breast with mixed greens and olive oil dressing',
          calories: 350,
          imageUrl: 'assets/images/meals/chicken_salad.jpg',
          macros: {'protein': 35, 'carbs': 10, 'fats': 15},
        ),
        snacks: [
          Meal(
            name: 'Greek Yogurt',
            description: 'Plain Greek yogurt with honey',
            calories: 150,
            imageUrl: 'assets/images/meals/greek_yogurt.jpg',
            macros: {'protein': 15, 'carbs': 10, 'fats': 5},
          ),
        ],
      );
    }

    return MealPlan(
      breakfast: Meal(
        name: 'Avocado Toast',
        description: 'Whole grain toast with mashed avocado and poached egg',
        calories: 350,
        imageUrl: 'assets/images/meals/avocado_toast.jpg',
        macros: {'protein': 15, 'carbs': 30, 'fats': 20},
      ),
      lunch: Meal(
        name: 'Chicken Wrap',
        description:
            'Whole wheat wrap with grilled chicken, vegetables, and hummus',
        calories: 480,
        imageUrl: 'assets/images/meals/chicken_wrap.jpg',
        macros: {'protein': 30, 'carbs': 45, 'fats': 15},
      ),
      dinner: Meal(
        name: 'Salmon with Quinoa',
        description: 'Baked salmon with quinoa and roasted vegetables',
        calories: 420,
        imageUrl: 'assets/images/meals/salmon_quinoa.jpg',
        macros: {'protein': 35, 'carbs': 30, 'fats': 18},
      ),
      snacks: [
        Meal(
          name: 'Mixed Nuts',
          description: 'Handful of mixed nuts with dried fruits',
          calories: 200,
          imageUrl: 'assets/images/meals/mixed_nuts.jpg',
          macros: {'protein': 6, 'carbs': 12, 'fats': 16},
        ),
      ],
    );
  }

  List<HealthTip> _getMockHealthTips() {
    return [
      const HealthTip(
        title: 'Stay Hydrated',
        description:
            '💧 Drink at least 8 glasses of water today to maintain energy levels.',
        icon: '💧',
        category: 'hydration',
      ),
      const HealthTip(
        title: 'Take Movement Breaks',
        description:
            '🚶 Take a 5-min walk every hour to reduce fatigue and improve focus.',
        icon: '🚶',
        category: 'activity',
      ),
      const HealthTip(
        title: 'Mindful Eating',
        description:
            '🍽️ Put down your phone while eating to improve digestion and satisfaction.',
        icon: '🍽️',
        category: 'nutrition',
      ),
    ];
  }
}
