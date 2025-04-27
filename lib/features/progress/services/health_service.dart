import 'dart:io';
import 'dart:math' show max;
import 'package:health/health.dart';
import 'package:workout_prediction_system_mobile/features/progress/models/health_data.dart';

class HealthService {
  final Health _health = Health();
  bool _isInitialized = false;

  // Platform-specific health data types
  List<HealthDataType> get _healthDataTypes {
    final List<HealthDataType> types = [
      HealthDataType.STEPS,
      if (Platform.isAndroid) ...[
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
      ] else
        HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.WEIGHT,
      HealthDataType.WORKOUT, // Workout data is important for both platforms
    ];

    // Add platform-specific distance type
    if (Platform.isIOS) {
      // iOS can directly access DISTANCE_WALKING_RUNNING
      types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
    }
    // On Android, we'll extract distance from the WORKOUT data
    // which is already included above

    return types;
  }

  // Get the appropriate distance type based on platform
  HealthDataType get _distanceType {
    if (Platform.isAndroid) {
      // For Android, we need to use a different approach
      // since DISTANCE_WALKING_RUNNING may not be supported in Health Connect
      return HealthDataType.WORKOUT; // We'll extract distance from workout data
    }
    return HealthDataType
        .DISTANCE_WALKING_RUNNING; // iOS supports this directly
  }

  // Helper to check if this is a distance request on Android
  bool _isDistanceRequestOnAndroid(HealthDataType type) {
    return Platform.isAndroid &&
        (type == HealthDataType.DISTANCE_WALKING_RUNNING);
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      print("[HEALTH] Health service already initialized");
      return;
    }

    try {
      print("[HEALTH] Configuring health service");
      await _health.configure();
      print("[HEALTH] Health service configured successfully");
      _isInitialized = true;
    } catch (e) {
      print("[HEALTH] Error initializing Health service: $e");
      if (Platform.isAndroid) {
        // On Android, this might be because Health Connect is not available or not set up
        print(
          "[HEALTH] This might be because Health Connect is not properly set up on Android",
        );
        // We'll set it as initialized anyway to allow graceful fallback
        _isInitialized = true;
      } else {
        // Re-throw on iOS since it should always work
        rethrow;
      }
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    print("[HEALTH] Requesting permissions");

    try {
      if (Platform.isAndroid) {
        print("[HEALTH] Running on Android, requesting permissions one by one");
        return await _requestPermissionsOneByOne();
      } else {
        // On iOS, we can request all permissions at once
        final permissions = List.generate(
          _healthDataTypes.length,
          (_) => HealthDataAccess.READ_WRITE,
        );

        print(
          "[HEALTH] Requesting permissions for: ${_healthDataTypes.map((t) => t.toString()).join(', ')}",
        );

        return await _health.requestAuthorization(
          _healthDataTypes,
          permissions: permissions,
        );
      }
    } catch (e) {
      print("[HEALTH] Error requesting health permissions: $e");
      return false;
    }
  }

  // Helper to request permissions one by one for robustness
  Future<bool> _requestPermissionsOneByOne() async {
    print("[HEALTH] Trying to request permissions one by one");
    bool anySuccess = false;

    // First request basic permissions
    final basicTypes = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      if (Platform.isAndroid) HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.WEIGHT,
    ];

    for (final type in basicTypes) {
      try {
        print("[HEALTH] Requesting permission for: $type");
        await Future.delayed(
          Duration(milliseconds: 500),
        ); // Add delay between requests
        final success = await _health.requestAuthorization(
          [type],
          permissions: [HealthDataAccess.READ_WRITE],
        );
        if (success) {
          anySuccess = true;
          print("[HEALTH] Permission granted for: $type");
        }
      } catch (e) {
        print("[HEALTH] Error requesting permission for $type: $e");
      }
    }

    // Then specifically request workout permissions
    try {
      print("[HEALTH] Requesting WORKOUT permissions");
      await Future.delayed(Duration(milliseconds: 500));
      final workoutSuccess = await _health.requestAuthorization(
        [HealthDataType.WORKOUT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
      if (workoutSuccess) {
        anySuccess = true;
        print("[HEALTH] WORKOUT permissions granted");
      }
    } catch (e) {
      print("[HEALTH] Error requesting WORKOUT permissions: $e");
    }

    return anySuccess;
  }

  Future<bool> hasPermissions() async {
    await initialize();

    try {
      return await _health.hasPermissions(_healthDataTypes) ?? false;
    } catch (e) {
      print('Error checking health permissions: $e');
      return false;
    }
  }

  Future<DailyHealthSummary> fetchDailySummary(DateTime date) async {
    print("[HEALTH] fetchDailySummary started for date: $date");
    try {
      await initialize();
      print("[HEALTH] Health service initialized");

      // Set time range (full day)
      final startTime = DateTime(date.year, date.month, date.day);
      final endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);
      print("[HEALTH] Date range: $startTime to $endTime");

      // Process the data
      int steps = 0;
      double caloriesBurned = 0;
      int activeMinutes = 0;
      double distanceWalked = 0;
      int heartRate = 0;
      double weightKg = 0;
      int heartRateCount = 0;

      // Check if permissions are granted
      bool hasPermission = false;
      try {
        hasPermission = await hasPermissions();
        print("[HEALTH] Initial permissions check: $hasPermission");

        if (!hasPermission) {
          print("[HEALTH] No permissions, requesting them now");
          hasPermission = await requestPermissions();
          print("[HEALTH] After requesting permissions: $hasPermission");
        }
      } catch (e) {
        print("[HEALTH] Error checking/requesting permissions: $e");
      }

      if (hasPermission) {
        try {
          print("[HEALTH] Starting to fetch health data points");
          print(
            "[HEALTH] Health data types to fetch: ${_healthDataTypes.map((t) => t.toString()).join(', ')}",
          );

          List<HealthDataPoint> healthData = await _health
              .getHealthDataFromTypes(
                startTime: startTime,
                endTime: endTime,
                types: _healthDataTypes,
              );

          print(
            "[HEALTH] Successfully fetched ${healthData.length} health data points",
          );
          print(
            "[HEALTH] Data points breakdown: ${healthData.map((p) => p.type.toString()).toList()}",
          );

          // Process each data point
          for (HealthDataPoint point in healthData) {
            try {
              if (point.type == HealthDataType.STEPS) {
                steps +=
                    (point.value as NumericHealthValue).numericValue.toInt();
                print("[HEALTH] Added steps: $steps");
              } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED ||
                  point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
                final calories =
                    (point.value as NumericHealthValue).numericValue.toDouble();
                caloriesBurned += calories;
                print(
                  "[HEALTH] Added calories (${point.type}): $calories, Total: $caloriesBurned",
                );
                if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
                  activeMinutes +=
                      ((point.dateTo.difference(point.dateFrom).inMinutes) *
                              0.7)
                          .round();
                }
              } else if (point.type == HealthDataType.HEART_RATE) {
                final rate =
                    (point.value as NumericHealthValue).numericValue.toInt();
                heartRate += rate;
                heartRateCount++;
                print(
                  "[HEALTH] Added heart rate: $rate, Count: $heartRateCount",
                );
              } else if (point.type ==
                  HealthDataType.DISTANCE_WALKING_RUNNING) {
                final distance =
                    (point.value as NumericHealthValue).numericValue.toDouble();
                distanceWalked += distance;
                print(
                  "[HEALTH] Added distance: $distance, Total: $distanceWalked",
                );
              } else if (point.type == HealthDataType.WEIGHT) {
                weightKg =
                    (point.value as NumericHealthValue).numericValue.toDouble();
                print("[HEALTH] Set weight: $weightKg");
              }
            } catch (e) {
              print(
                "[HEALTH] Error processing data point of type ${point.type}: $e",
              );
            }
          }

          // Try to get total steps directly
          try {
            print("[HEALTH] Attempting to get total steps directly");
            int? totalSteps = await _health.getTotalStepsInInterval(
              startTime,
              endTime,
            );
            if (totalSteps != null && totalSteps > 0) {
              print("[HEALTH] Got total steps directly: $totalSteps");
              steps = totalSteps;
            }
          } catch (e) {
            print("[HEALTH] Error getting total steps: $e");
          }
        } catch (e) {
          print("[HEALTH] Error fetching or processing health data: $e");
        }
      } else {
        print("[HEALTH] No permissions available, returning empty summary");
      }

      final summary = DailyHealthSummary(
        steps: steps,
        caloriesBurned: caloriesBurned,
        activeMinutes: activeMinutes,
        distanceWalked: distanceWalked,
        date: date,
        heartRate:
            heartRate > 0 ? (heartRate / max(1, heartRateCount)).round() : 0,
        weightKg: weightKg,
      );

      print("[HEALTH] Returning summary: $summary");
      return summary;
    } catch (e) {
      print("[HEALTH] Unhandled error in fetchDailySummary: $e");
      return DailyHealthSummary.empty();
    }
  }

  Future<List<WorkoutData>> fetchWorkouts(
    DateTime startDate,
    DateTime endDate,
  ) async {
    print("[HEALTH] fetchWorkouts started for range: $startDate to $endDate");
    try {
      await initialize();
      print("[HEALTH] Health service initialized for workouts");

      // Check permissions
      bool hasPermission = false;
      try {
        hasPermission = await hasPermissions();
        print("[HEALTH] Initial workout permissions check: $hasPermission");

        if (!hasPermission) {
          print("[HEALTH] No workout permissions, requesting them now");
          hasPermission = await requestPermissions();
          print(
            "[HEALTH] After requesting workout permissions: $hasPermission",
          );
        }
      } catch (e) {
        print("[HEALTH] Error checking/requesting workout permissions: $e");
      }

      List<WorkoutData> workouts = [];

      if (hasPermission) {
        try {
          print("[HEALTH] Starting to fetch workout data");
          List<HealthDataPoint> workoutData = await _health
              .getHealthDataFromTypes(
                startTime: startDate,
                endTime: endDate,
                types: [HealthDataType.WORKOUT],
              );

          print(
            "[HEALTH] Successfully fetched ${workoutData.length} workout data points",
          );

          for (HealthDataPoint point in workoutData) {
            try {
              if (point.type == HealthDataType.WORKOUT) {
                var workoutValue = point.value as WorkoutHealthValue;
                print(
                  "[HEALTH] Processing workout: ${workoutValue.workoutActivityType} from ${point.dateFrom}",
                );

                workouts.add(
                  WorkoutData(
                    workoutType:
                        workoutValue.workoutActivityType
                            .toString()
                            .split('.')
                            .last,
                    startTime: point.dateFrom,
                    endTime: point.dateTo,
                    caloriesBurned:
                        workoutValue.totalEnergyBurned?.toDouble() ?? 0.0,
                    distance: workoutValue.totalDistance?.toDouble() ?? 0.0,
                    activeDuration:
                        point.dateTo.difference(point.dateFrom).inMinutes,
                  ),
                );
              }
            } catch (e) {
              print("[HEALTH] Error processing workout data point: $e");
            }
          }
        } catch (e) {
          print("[HEALTH] Error fetching workout data: $e");
        }
      } else {
        print(
          "[HEALTH] No workout permissions available, returning empty list",
        );
      }

      print("[HEALTH] Returning ${workouts.length} workouts");
      return workouts;
    } catch (e) {
      print("[HEALTH] Unhandled error in fetchWorkouts: $e");
      return [];
    }
  }

  Future<List<HealthMetric>> fetchWeeklyMetrics(
    HealthDataType type,
    DateTime startDate,
  ) async {
    await initialize();

    // On Android, for distance metrics, we use a different approach
    bool isDistanceOnAndroid = _isDistanceRequestOnAndroid(type);

    // Check if permissions are granted
    bool hasPermission = await hasPermissions();
    if (!hasPermission) {
      hasPermission = await requestPermissions();
      if (!hasPermission) {
        return [];
      }
    }

    // Generate a list of 7 days
    List<DateTime> dates =
        List.generate(7, (index) {
          return DateTime(
            startDate.year,
            startDate.month,
            startDate.day - index,
          );
        }).reversed.toList();

    List<HealthMetric> metrics = [];

    for (DateTime date in dates) {
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      try {
        double value = 0;
        String unit = '';
        String title = '';

        if (isDistanceOnAndroid) {
          // For Android and distance, use workout data
          List<HealthDataPoint> workoutData = await _health
              .getHealthDataFromTypes(
                startTime: date,
                endTime: endOfDay,
                types: [HealthDataType.WORKOUT],
              );

          for (var point in workoutData) {
            if (point.type == HealthDataType.WORKOUT) {
              var workoutValue = point.value as WorkoutHealthValue;
              if (workoutValue.totalDistance != null) {
                value += workoutValue.totalDistance!.toDouble();
              }
            }
          }

          unit = 'km';
          title = 'Distance';
        } else {
          // For all other metrics and iOS distance, use normal data fetch
          List<HealthDataPoint> healthData = await _health
              .getHealthDataFromTypes(
                startTime: date,
                endTime: endOfDay,
                types: [type],
              );

          switch (type) {
            case HealthDataType.STEPS:
              // Try to get steps from the dedicated method first
              int? steps = await _health.getTotalStepsInInterval(
                date,
                endOfDay,
              );
              if (steps != null) {
                value = steps.toDouble();
              } else {
                // Sum up steps from data points
                for (var point in healthData) {
                  value +=
                      (point.value as NumericHealthValue).numericValue
                          .toDouble();
                }
              }
              unit = 'steps';
              title = 'Steps';
              break;

            case HealthDataType.ACTIVE_ENERGY_BURNED:
              for (var point in healthData) {
                value +=
                    (point.value as NumericHealthValue).numericValue.toDouble();
              }
              unit = 'kcal';
              title = 'Calories';
              break;

            case HealthDataType.DISTANCE_WALKING_RUNNING:
              for (var point in healthData) {
                value +=
                    (point.value as NumericHealthValue).numericValue.toDouble();
              }
              unit = 'km';
              title = 'Distance';
              break;

            default:
              // Skip unsupported types
              continue;
          }
        }

        metrics.add(
          HealthMetric(
            title: title,
            value: value.toStringAsFixed(1),
            type: type, // Store the original type requested
            unit: unit,
            date: date,
          ),
        );
      } catch (e) {
        print('Error fetching ${type.toString()} for $date: $e');
        // Add a zero value for this day to maintain the sequence
        metrics.add(
          HealthMetric(
            title: type.toString().split('.').last,
            value: '0',
            type: type,
            unit: '',
            date: date,
          ),
        );
      }
    }

    return metrics;
  }

  Future<bool> writeWorkout({
    required String workoutType,
    required DateTime startTime,
    required DateTime endTime,
    int? calories,
    int? distance,
  }) async {
    await initialize();

    try {
      // Request more comprehensive permissions for workout writing
      List<HealthDataType> typesToRequest = [HealthDataType.WORKOUT];

      // Add calories permissions if calories are provided
      if (calories != null && calories > 0) {
        typesToRequest.add(HealthDataType.ACTIVE_ENERGY_BURNED);

        // On Android, also request TOTAL_CALORIES_BURNED permissions
        if (Platform.isAndroid) {
          try {
            // This is a specific fix for Android Health Connect to ensure we have the right calories permissions
            await _health.requestAuthorization(
              [HealthDataType.ACTIVE_ENERGY_BURNED],
              permissions: [HealthDataAccess.READ_WRITE],
            );
          } catch (e) {
            print('Error requesting Android calories permissions: $e');
          }
        }
      }

      // Add distance permissions if distance is provided
      if (distance != null && distance > 0 && !Platform.isAndroid) {
        // On iOS, request the distance permission
        typesToRequest.add(HealthDataType.DISTANCE_WALKING_RUNNING);
      }

      // For Android, distance is handled through the workout data itself
      // so we don't need to request separate distance permissions

      // Request write permissions for all needed types
      bool hasPermission = await _health.requestAuthorization(
        typesToRequest,
        permissions: List.generate(
          typesToRequest.length,
          (_) => HealthDataAccess.READ_WRITE,
        ),
      );

      if (!hasPermission) {
        print('Workout permission request denied');
        return false;
      }

      // Map string to a workout activity type
      var workoutActivityType = _stringToWorkoutActivityType(workoutType);

      // Calculate workout duration in minutes
      final durationMinutes = endTime.difference(startTime).inMinutes;

      print('[HEALTH_SERVICE] Writing workout with following details:');
      print('[HEALTH_SERVICE] Type: $workoutType => $workoutActivityType');
      print(
        '[HEALTH_SERVICE] Start: $startTime, End: $endTime, Duration: $durationMinutes min',
      );
      print('[HEALTH_SERVICE] Calories: $calories, Distance: $distance');
      print(
        '[HEALTH_SERVICE] Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}',
      );

      // For Android, distance is automatically handled through the workout data
      // On iOS, we may need to add a separate distance entry, but the health plugin
      // handles this automatically with the writeWorkoutData method

      final result = await _health.writeWorkoutData(
        activityType: workoutActivityType,
        start: startTime,
        end: endTime,
        totalEnergyBurned: calories,
        totalDistance: distance,
      );

      print('[HEALTH_SERVICE] Workout write result: $result');
      return result;
    } catch (e) {
      print('[HEALTH_SERVICE] Error writing workout: $e');
      return false;
    }
  }

  // Convert string to workout activity type
  HealthWorkoutActivityType _stringToWorkoutActivityType(String type) {
    // Default to OTHER if not found
    HealthWorkoutActivityType activityType = HealthWorkoutActivityType.OTHER;

    // Try to match with available types
    for (var value in HealthWorkoutActivityType.values) {
      if (value.toString().split('.').last == type.toUpperCase()) {
        activityType = value;
        break;
      }
    }

    return activityType;
  }
}
