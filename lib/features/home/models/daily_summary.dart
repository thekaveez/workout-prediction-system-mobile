import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final int caloriesConsumed;
  final int caloriesGoal;
  final int stepsTaken;
  final int stepsGoal;
  final int sittingMinutes;
  final int sittingGoalMinutes;
  final double waterConsumed; // in milliliters
  final double waterGoal; // in milliliters

  const DailySummary({
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.stepsTaken,
    required this.stepsGoal,
    required this.sittingMinutes,
    required this.sittingGoalMinutes,
    this.waterConsumed = 0,
    this.waterGoal = 2500,
  });

  double get caloriesProgress => caloriesConsumed / caloriesGoal;
  double get stepsProgress => stepsTaken / stepsGoal;
  double get sittingProgress => sittingMinutes / sittingGoalMinutes;
  double get waterProgress => waterConsumed / waterGoal;

  String get formattedSittingTime {
    final hours = sittingMinutes ~/ 60;
    final minutes = sittingMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedWaterConsumed {
    if (waterConsumed >= 1000) {
      return '${(waterConsumed / 1000).toStringAsFixed(1)} L';
    }
    return '${waterConsumed.toInt()} ml';
  }

  String get formattedWaterGoal {
    if (waterGoal >= 1000) {
      return '${(waterGoal / 1000).toStringAsFixed(1)} L';
    }
    return '${waterGoal.toInt()} ml';
  }

  DailySummary copyWith({
    int? caloriesConsumed,
    int? caloriesGoal,
    int? stepsTaken,
    int? stepsGoal,
    int? sittingMinutes,
    int? sittingGoalMinutes,
    double? waterConsumed,
    double? waterGoal,
  }) {
    return DailySummary(
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      stepsTaken: stepsTaken ?? this.stepsTaken,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sittingMinutes: sittingMinutes ?? this.sittingMinutes,
      sittingGoalMinutes: sittingGoalMinutes ?? this.sittingGoalMinutes,
      waterConsumed: waterConsumed ?? this.waterConsumed,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }

  @override
  List<Object?> get props => [
    caloriesConsumed,
    caloriesGoal,
    stepsTaken,
    stepsGoal,
    sittingMinutes,
    sittingGoalMinutes,
    waterConsumed,
    waterGoal,
  ];
}
