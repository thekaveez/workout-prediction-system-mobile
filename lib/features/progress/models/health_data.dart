import 'package:health/health.dart';

class HealthMetric {
  final String title;
  final String value;
  final HealthDataType type;
  final String unit;
  final DateTime date;
  final String? iconPath;

  HealthMetric({
    required this.title,
    required this.value,
    required this.type,
    required this.unit,
    required this.date,
    this.iconPath,
  });
}

class DailyHealthSummary {
  final int steps;
  final double caloriesBurned;
  final int activeMinutes;
  final double distanceWalked;
  final DateTime date;
  final int heartRate;
  final double weightKg;

  DailyHealthSummary({
    required this.steps,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.distanceWalked,
    required this.date,
    required this.heartRate,
    required this.weightKg,
  });

  factory DailyHealthSummary.empty() {
    return DailyHealthSummary(
      steps: 0,
      caloriesBurned: 0,
      activeMinutes: 0,
      distanceWalked: 0,
      date: DateTime.now(),
      heartRate: 0,
      weightKg: 0,
    );
  }
}

class WorkoutData {
  final String workoutType;
  final DateTime startTime;
  final DateTime endTime;
  final double caloriesBurned;
  final double distance;
  final int activeDuration;

  WorkoutData({
    required this.workoutType,
    required this.startTime,
    required this.endTime,
    required this.caloriesBurned,
    required this.distance,
    required this.activeDuration,
  });
}
