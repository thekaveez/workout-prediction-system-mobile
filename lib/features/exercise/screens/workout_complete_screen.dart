import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';
import 'package:workout_prediction_system_mobile/features/exercise/providers/user_exercise_provider.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  final ExerciseData exercise;

  const WorkoutCompleteScreen({super.key, required this.exercise});

  @override
  ConsumerState<WorkoutCompleteScreen> createState() =>
      _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends ConsumerState<WorkoutCompleteScreen> {
  bool _isRecording = true;
  bool _recordingComplete = false;
  String? _recordingError;

  @override
  void initState() {
    super.initState();
    _recordCompletedExercise();
  }

  Future<void> _recordCompletedExercise() async {
    try {
      // Extract duration in seconds from the exercise duration string
      final durationInSeconds = _parseDurationToSeconds(
        widget.exercise.duration,
      );

      // Record the completed exercise
      final recordExercise = ref.read(recordExerciseProvider);
      await recordExercise(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.title,
        duration: durationInSeconds,
        caloriesBurned: widget.exercise.calories,
        difficulty: widget.exercise.difficulty,
      );

      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingComplete = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingError = 'Failed to record exercise: ${e.toString()}';
        });
      }
      print('Error recording exercise: $e');
    }
  }

  // Parse duration string (e.g., "15 min" or "00:30") to seconds
  int _parseDurationToSeconds(String durationStr) {
    if (durationStr.contains('min')) {
      // Format like "15 min"
      final minutes = int.tryParse(durationStr.split(' ').first) ?? 0;
      return minutes * 60;
    } else if (durationStr.contains(':')) {
      // Format like "mm:ss"
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return (minutes * 60) + seconds;
      }
    }

    // Default to 60 seconds if parsing fails
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration animation (simplified with icon for this demo)
              _isRecording
                  ? CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  )
                  : Icon(
                    _recordingComplete
                        ? Icons.emoji_events
                        : Icons.error_outline,
                    color: _recordingComplete ? Colors.amber : Colors.red,
                    size: 120.sp,
                  ),

              SizedBox(height: 32.h),

              // Congratulations text
              Text(
                _recordingComplete
                    ? 'Congratulations!'
                    : _recordingError != null
                    ? 'Oops!'
                    : 'Recording workout...',
                style: TextUtils.kHeading(context).copyWith(
                  fontSize: 32.sp,
                  color:
                      _recordingComplete
                          ? Theme.of(context).colorScheme.primary
                          : _recordingError != null
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              if (_recordingError != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    _recordingError!,
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(fontSize: 16.sp, color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Text(
                  'You completed',
                  style: TextUtils.kBodyText(
                    context,
                  ).copyWith(fontSize: 18.sp, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),

              SizedBox(height: 8.h),

              Text(
                widget.exercise.title,
                style: TextUtils.kSubHeading(context).copyWith(
                  fontSize: 24.sp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // Achievements section
              if (_recordingComplete) _buildAchievementCard(context),

              SizedBox(height: 48.h),

              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    // Back to exercises button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('More Exercises'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // Home button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            Helpers.routeNavigation(
                              context,
                              const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Go to Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Achievements',
            style: TextUtils.kSubHeading(context).copyWith(
              fontSize: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementItem(
                context,
                icon: Icons.local_fire_department,
                value: '${widget.exercise.calories}',
                label: 'Calories',
                color: Colors.orange,
              ),
              _buildAchievementItem(
                context,
                icon: Icons.timer,
                value: widget.exercise.duration,
                label: 'Duration',
                color: Colors.blue,
              ),
              _buildAchievementItem(
                context,
                icon: Icons.emoji_events,
                value: '+15',
                label: 'Points',
                color: Colors.amber,
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Badge unlock notification
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Badge Unlocked!',
                        style: TextUtils.kSubHeading(
                          context,
                        ).copyWith(color: Colors.amber, fontSize: 16.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getBadgeName(widget.exercise),
                        style: TextUtils.kBodyText(
                          context,
                        ).copyWith(color: Colors.white, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
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
          child: Icon(icon, color: color, size: 32.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextUtils.kSubHeading(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextUtils.kBodyText(
            context,
          ).copyWith(color: Colors.grey[400], fontSize: 14.sp),
        ),
      ],
    );
  }

  String _getBadgeName(ExerciseData exercise) {
    // Generate a badge name based on the exercise properties
    if (exercise.difficulty == 'Advanced') {
      return 'Master Athlete';
    } else if (exercise.calories > 200) {
      return 'Calorie Crusher';
    } else if (exercise.title.toLowerCase().contains('hiit')) {
      return 'HIIT Warrior';
    } else {
      return 'Fitness Enthusiast';
    }
  }
}
