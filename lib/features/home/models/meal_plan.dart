import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String name;
  final String description;
  final int calories;
  final String imageUrl;
  final Map<String, double> macros; // protein, carbs, fats in grams

  const Meal({
    required this.name,
    required this.description,
    required this.calories,
    required this.imageUrl,
    required this.macros,
  });

  @override
  List<Object?> get props => [name, description, calories, imageUrl, macros];
}

class MealPlan extends Equatable {
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final List<Meal> snacks;

  const MealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });

  int get totalCalories =>
      breakfast.calories +
      lunch.calories +
      dinner.calories +
      snacks.fold(0, (sum, snack) => sum + snack.calories);

  @override
  List<Object?> get props => [breakfast, lunch, dinner, snacks];
}
