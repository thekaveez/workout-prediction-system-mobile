import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final int caloriesConsumed;
  final int caloriesGoal;
  final int stepsTaken;
  final int stepsGoal;
  final int sittingMinutes;
  final int sittingGoalMinutes;

  const DailySummary({
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.stepsTaken,
    required this.stepsGoal,
    required this.sittingMinutes,
    required this.sittingGoalMinutes,
  });

  double get caloriesProgress => caloriesConsumed / caloriesGoal;
  double get stepsProgress => stepsTaken / stepsGoal;
  double get sittingProgress => sittingMinutes / sittingGoalMinutes;

  String get formattedSittingTime {
    final hours = sittingMinutes ~/ 60;
    final minutes = sittingMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [
    caloriesConsumed,
    caloriesGoal,
    stepsTaken,
    stepsGoal,
    sittingMinutes,
    sittingGoalMinutes,
  ];
}
