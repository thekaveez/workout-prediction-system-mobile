import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_prediction_system_mobile/features/progress/models/health_data.dart';
import 'package:workout_prediction_system_mobile/features/progress/providers/health_providers.dart';
import 'package:workout_prediction_system_mobile/features/progress/screens/workout_recorder_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class ProgressTrackingScreen extends ConsumerStatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  ConsumerState<ProgressTrackingScreen> createState() =>
      _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends ConsumerState<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'Week'; // Week, Month, Year
  final List<String> _timeframeOptions = ['Week', 'Month', 'Year'];
  DateTime _selectedDate = DateTime.now();
  bool _isHealthConnectAvailable = true;

  // Health Connect Google Play Store URL
  final String _healthConnectPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to update UI when tab changes (for FAB visibility)
    _tabController.addListener(() {
      setState(() {});
    });

    // Request health permissions and check for Health Connect availability
    Future.microtask(() async {
      final healthService = ref.read(healthServiceProvider);

      // On Android, check if Health Connect is installed
      if (Platform.isAndroid) {
        try {
          // Try to configure health to check if Health Connect is available
          final health = Health();
          await health.configure();

          // Try to access a simple health data type to check availability
          final hasPermissions = await health.hasPermissions([
            HealthDataType.STEPS,
          ]);
          if (hasPermissions == null || hasPermissions == false) {
            // Try to request permissions to see if Health Connect is available
            final permissionsGranted = await health.requestAuthorization([
              HealthDataType.STEPS,
            ]);
            if (!permissionsGranted) {
              if (mounted) {
                setState(() {
                  _isHealthConnectAvailable = false;
                });
              }
              return;
            }
          }
        } catch (e) {
          print('Error checking Health Connect availability: $e');
          if (mounted) {
            setState(() {
              _isHealthConnectAvailable = false;
            });
          }
          return;
        }
      }

      // Request permissions if Health Connect is available or on iOS
      await healthService.requestPermissions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Open the Google Play Store for Health Connect
  Future<void> _openHealthConnectPlayStore() async {
    final Uri url = Uri.parse(_healthConnectPlayStoreUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Play Store'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Progress Tracking',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAllData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Activity'), Tab(text: 'Exercise History')],
        ),
      ),
      body:
          !_isHealthConnectAvailable && Platform.isAndroid
              ? _buildHealthConnectNotAvailable()
              : TabBarView(
                controller: _tabController,
                children: [_buildActivityTab(), _buildExerciseHistoryTab()],
              ),
      floatingActionButton:
          _tabController.index == 1 && _isHealthConnectAvailable
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutRecorderScreen(),
                    ),
                  ).then((_) {
                    // Refresh the workouts when returning from recorder
                    _refreshWorkoutsData();
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildHealthConnectNotAvailable() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 64.sp,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Health Connect Required',
              style: TextUtils.kHeading(context).copyWith(fontSize: 24.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'This app uses Google Health Connect to track your fitness data. Please install Health Connect from the Google Play Store to use this feature.',
              style: TextUtils.kBodyText(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _openHealthConnectPlayStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text('Install Health Connect'),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: () async {
                    // Check again for Health Connect
                    try {
                      final health = Health();
                      await health.configure();
                      final hasPermissions = await health.hasPermissions([
                        HealthDataType.STEPS,
                      ]);
                      setState(() {
                        _isHealthConnectAvailable = hasPermissions != null;
                      });
                    } catch (e) {
                      setState(() {
                        _isHealthConnectAvailable = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text('Check Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    final dailySummaryAsync = ref.watch(
      dailyHealthSummaryProvider(_selectedDate),
    );
    final weeklyStepsAsync = ref.watch(weeklyStepsProvider(_selectedDate));
    final weeklyCaloriesAsync = ref.watch(
      weeklyCaloriesProvider(_selectedDate),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeframe selector
          _buildTimeframeSelector(),

          SizedBox(height: 24.h),

          // Today's summary card
          dailySummaryAsync.when(
            data: (summary) => _buildTodaySummaryCard(summary),
            loading: () => _buildLoadingCard('Today\'s Summary'),
            error: (error, stack) {
              print('Error in dailyHealthSummary provider: $error');
              print(stack);
              return _buildErrorCard(
                'Could not load health data. Please make sure Health Connect is installed and permissions are granted.',
              );
            },
          ),

          SizedBox(height: 24.h),

          // Step count chart card
          weeklyStepsAsync.when(
            data:
                (steps) => _buildChartCard(
                  title: 'Step Count',
                  child: _buildStepChart(steps),
                ),
            loading:
                () => _buildChartCard(
                  title: 'Step Count',
                  child: const Center(child: CircularProgressIndicator()),
                ),
            error: (error, stack) {
              print('Error in weeklySteps provider: $error');
              return _buildChartCard(
                title: 'Step Count',
                child: Center(
                  child: Text(
                    'Could not load step data. Please check permissions.',
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Calories burned chart card
          weeklyCaloriesAsync.when(
            data:
                (calories) => _buildChartCard(
                  title: 'Calories Burned',
                  child: _buildCaloriesChart(calories),
                ),
            loading:
                () => _buildChartCard(
                  title: 'Calories Burned',
                  child: const Center(child: CircularProgressIndicator()),
                ),
            error: (error, stack) {
              print('Error in weeklyCalories provider: $error');
              return _buildChartCard(
                title: 'Calories Burned',
                child: Center(
                  child: Text(
                    'Could not load calorie data. Please check permissions.',
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildExerciseHistoryTab() {
    // Create a date range for the past 30 days
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 30);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final workoutsAsync = ref.watch(
      workoutsProvider((startDate: startDate, endDate: endDate)),
    );

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64.sp,
                  color: Colors.grey[700],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No workout history found',
                  style: TextUtils.kSubHeading(context),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your workouts will appear here once you\nstart recording them with your device',
                  style: TextUtils.kBodyText(
                    context,
                  ).copyWith(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            return _buildWorkoutHistoryItem(workouts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Could not load workout history',
                  style: TextUtils.kSubHeading(context),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: _refreshWorkoutsData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Try Again'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _timeframeOptions.map((option) {
            final isSelected = option == _selectedTimeframe;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTimeframe = option;

                      // Adjust the selected date based on timeframe
                      final now = DateTime.now();
                      if (option == 'Week') {
                        _selectedDate = now;
                      } else if (option == 'Month') {
                        _selectedDate = DateTime(now.year, now.month, 1);
                      } else if (option == 'Year') {
                        _selectedDate = DateTime(now.year, 1, 1);
                      }
                    });
                  }
                },
                backgroundColor: Colors.grey[800],
                selectedColor: Theme.of(context).colorScheme.secondary,
                labelStyle: TextUtils.kBodyText(context).copyWith(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.surface
                          : Colors.white,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTodaySummaryCard(DailyHealthSummary summary) {
    final stepGoal = 10000; // Example goal
    final stepProgress = summary.steps / stepGoal;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: TextUtils.kSubHeading(context).copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                context,
                icon: Icons.directions_walk,
                value: summary.steps.toString(),
                label: 'Steps',
                color: Colors.blue,
              ),
              _buildSummaryItem(
                context,
                icon: Icons.local_fire_department,
                value: summary.caloriesBurned.toStringAsFixed(0),
                label: 'Calories',
                color: Colors.orange,
              ),
              _buildSummaryItem(
                context,
                icon: Icons.access_time,
                value: summary.activeMinutes.toString(),
                label: 'Active Min',
                color: Colors.green,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LinearProgressIndicator(
            value: stepProgress.clamp(
              0.0,
              1.0,
            ), // Clamp to ensure value is between 0 and 1
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 8.h),
          Text(
            '${summary.steps} / $stepGoal steps - ${(stepProgress * 100).toStringAsFixed(0)}% of daily goal',
            style: TextUtils.kBodyText(
              context,
            ).copyWith(color: Colors.grey[400], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextUtils.kSubHeading(context).copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextUtils.kBodyText(
            context,
          ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextUtils.kSubHeading(context).copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildStepChart(List<HealthMetric> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No step data available',
          style: TextUtils.kBodyText(context).copyWith(color: Colors.grey[400]),
        ),
      );
    }

    // Calculate max steps for relative height
    final maxSteps = data
        .map((e) => double.parse(e.value))
        .reduce((a, b) => a > b ? a : b);

    // A simplified bar chart representation
    return SizedBox(
      height: 200.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            data.map((metric) {
              // Calculate relative height
              final steps = double.parse(metric.value);
              final relativeHeight =
                  maxSteps > 0 ? (steps / maxSteps * 160.h) : 0.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30.w,
                    height: relativeHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatWeekday(metric.date),
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCaloriesChart(List<HealthMetric> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No calorie data available',
          style: TextUtils.kBodyText(context).copyWith(color: Colors.grey[400]),
        ),
      );
    }

    // Calculate max calories for relative height
    final maxCalories = data
        .map((e) => double.parse(e.value))
        .reduce((a, b) => a > b ? a : b);

    // A simplified bar chart representation
    return SizedBox(
      height: 200.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            data.map((metric) {
              // Calculate relative height
              final calories = double.parse(metric.value);
              final relativeHeight =
                  maxCalories > 0 ? (calories / maxCalories * 160.h) : 0.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30.w,
                    height: relativeHeight,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatWeekday(metric.date),
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWorkoutHistoryItem(WorkoutData workout) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Exercise icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getExerciseIcon(workout.workoutType),
                color: Theme.of(context).colorScheme.secondary,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Exercise details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatWorkoutType(workout.workoutType),
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDateTime(workout.startTime),
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
                  ),
                ],
              ),
            ),

            // Duration and calories
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${workout.activeDuration} min',
                  style: TextUtils.kBodyText(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${workout.caloriesBurned.toStringAsFixed(0)} kcal',
                  style: TextUtils.kBodyText(context).copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextUtils.kSubHeading(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _refreshAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String title) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextUtils.kSubHeading(context).copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 40.h),
          Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // Helper methods
  String _formatWeekday(DateTime date) {
    return DateFormat('E').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }

  String _formatWorkoutType(String workoutType) {
    // Convert RUNNING to Running
    return workoutType
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  IconData _getExerciseIcon(String exerciseName) {
    final lowercase = exerciseName.toLowerCase();

    if (lowercase.contains('yoga') || lowercase.contains('pilates'))
      return Icons.self_improvement;
    if (lowercase.contains('run') ||
        lowercase.contains('walk') ||
        lowercase.contains('jog'))
      return Icons.directions_run;
    if (lowercase.contains('hiit') || lowercase.contains('cardio'))
      return Icons.flash_on;
    if (lowercase.contains('strength') || lowercase.contains('weight'))
      return Icons.fitness_center;
    if (lowercase.contains('cycle') || lowercase.contains('bike'))
      return Icons.directions_bike;
    if (lowercase.contains('swim')) return Icons.pool;
    if (lowercase.contains('dance')) return Icons.music_note;

    return Icons.sports_gymnastics;
  }

  // Helper method to refresh all data
  void _refreshAllData() {
    setState(() {
      // This will trigger a UI refresh
    });

    // Refresh all providers
    ref.refresh(dailyHealthSummaryProvider(_selectedDate));
    ref.refresh(weeklyStepsProvider(_selectedDate));
    ref.refresh(weeklyCaloriesProvider(_selectedDate));

    // Refresh workouts
    _refreshWorkoutsData();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Helper method to refresh workouts data
  void _refreshWorkoutsData() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 30);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    ref.refresh(workoutsProvider((startDate: startDate, endDate: endDate)));
  }
}
