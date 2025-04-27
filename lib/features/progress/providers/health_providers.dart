import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:workout_prediction_system_mobile/features/progress/models/health_data.dart';
import 'package:workout_prediction_system_mobile/features/progress/services/health_service.dart';
import 'package:flutter/foundation.dart';

// Health service provider
final healthServiceProvider = Provider<HealthService>((ref) {
  print("[PROVIDER] Creating new HealthService instance");
  return HealthService();
});

// Health permissions provider
final healthPermissionsProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  print("[PROVIDER] Checking health permissions");
  final hasPermissions = await healthService.hasPermissions();
  print("[PROVIDER] Has permissions: $hasPermissions");
  return hasPermissions;
});

// Daily health summary provider
final dailyHealthSummaryProvider = FutureProvider.family<
  DailyHealthSummary,
  DateTime
>((ref, date) async {
  try {
    print("[PROVIDER] Starting to fetch daily health summary for date: $date");
    final healthService = ref.watch(healthServiceProvider);

    // Check permissions first
    print("[PROVIDER] Checking permissions before fetching daily summary");
    final hasPermissions = await healthService.hasPermissions();
    print("[PROVIDER] Permissions status for daily summary: $hasPermissions");

    if (!hasPermissions) {
      print("[PROVIDER] No permissions, requesting permissions");
      final granted = await healthService.requestPermissions();
      print("[PROVIDER] Permission request result: $granted");
    }

    print("[PROVIDER] Calling fetchDailySummary");
    final result = await healthService.fetchDailySummary(date);
    print("[PROVIDER] Daily summary fetched successfully: $result");
    return result;
  } catch (e, stack) {
    print("[PROVIDER] Error in dailyHealthSummaryProvider: $e");
    print("[PROVIDER] Stack trace: $stack");
    // Return empty data instead of propagating the error
    return DailyHealthSummary.empty();
  }
});

// Weekly metrics provider for steps
final weeklyStepsProvider = FutureProvider.family<List<HealthMetric>, DateTime>(
  (ref, date) async {
    try {
      print("[PROVIDER] Fetching weekly steps for date: $date");
      final healthService = ref.watch(healthServiceProvider);
      final result = await healthService.fetchWeeklyMetrics(
        HealthDataType.STEPS,
        date,
      );
      print(
        "[PROVIDER] Weekly steps fetched successfully: ${result.length} items",
      );
      return result;
    } catch (e) {
      print("[PROVIDER] Error in weeklyStepsProvider: $e");
      // Return empty list instead of propagating the error
      return [];
    }
  },
);

// Weekly metrics provider for calories
final weeklyCaloriesProvider = FutureProvider.family<
  List<HealthMetric>,
  DateTime
>((ref, date) async {
  try {
    print("[PROVIDER] Fetching weekly calories for date: $date");
    final healthService = ref.watch(healthServiceProvider);
    final result = await healthService.fetchWeeklyMetrics(
      HealthDataType.ACTIVE_ENERGY_BURNED,
      date,
    );
    print(
      "[PROVIDER] Weekly calories fetched successfully: ${result.length} items",
    );
    return result;
  } catch (e) {
    print("[PROVIDER] Error in weeklyCaloriesProvider: $e");
    // Return empty list instead of propagating the error
    return [];
  }
});

// Weekly metrics provider for distance
final weeklyDistanceProvider = FutureProvider.family<
  List<HealthMetric>,
  DateTime
>((ref, date) async {
  try {
    print("[PROVIDER] Fetching weekly distance for date: $date");
    final healthService = ref.watch(healthServiceProvider);

    // On Android, we need to use WORKOUT type to get distance
    final healthDataType =
        Platform.isAndroid
            ? HealthDataType
                .WORKOUT // Android: use workout data to calculate distance
            : HealthDataType
                .DISTANCE_WALKING_RUNNING; // iOS: use direct distance type

    print("[PROVIDER] Using data type for distance: $healthDataType");

    final result = await healthService.fetchWeeklyMetrics(healthDataType, date);
    print(
      "[PROVIDER] Weekly distance fetched successfully: ${result.length} items",
    );
    return result;
  } catch (e) {
    print("[PROVIDER] Error in weeklyDistanceProvider: $e");
    // Return empty list instead of propagating the error
    return [];
  }
});

// Workouts provider
final workoutsProvider = FutureProvider.family<
  List<WorkoutData>,
  ({DateTime startDate, DateTime endDate})
>((ref, dateRange) async {
  try {
    print(
      "[PROVIDER] Starting to fetch workouts for range: ${dateRange.startDate} to ${dateRange.endDate}",
    );
    final healthService = ref.watch(healthServiceProvider);

    // Check permissions first
    print("[PROVIDER] Checking permissions before fetching workouts");
    final hasPermissions = await healthService.hasPermissions();
    print("[PROVIDER] Permissions status for workouts: $hasPermissions");

    if (!hasPermissions) {
      print("[PROVIDER] No permissions, requesting permissions");
      final granted = await healthService.requestPermissions();
      print("[PROVIDER] Permission request result: $granted");
    }

    print("[PROVIDER] Calling fetchWorkouts");
    final result = await healthService.fetchWorkouts(
      dateRange.startDate,
      dateRange.endDate,
    );
    print("[PROVIDER] Workouts fetched successfully. Count: ${result.length}");
    print(
      "[PROVIDER] Workout details: ${result.map((w) => '${w.workoutType} on ${w.startTime}')}",
    );
    return result;
  } catch (e, stack) {
    print("[PROVIDER] Error in workoutsProvider: $e");
    print("[PROVIDER] Stack trace: $stack");
    // Return empty list instead of propagating the error
    return [];
  }
});
