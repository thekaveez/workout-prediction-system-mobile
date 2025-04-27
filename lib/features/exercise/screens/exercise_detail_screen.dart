import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';
import 'package:workout_prediction_system_mobile/features/exercise/providers/exercise_provider.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/video_player_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final ExerciseData exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the full exercise model from Firestore using the ID
    final exerciseModelAsync = ref.watch(exerciseByIdProvider(exercise.id));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App bar with exercise thumbnail as background
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exercise.title,
                style: TextUtils.kSubHeading(context).copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Exercise thumbnail or placeholder
                  exercise.thumbnailUrl != null
                      ? Image.network(
                        exercise.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.fitness_center,
                              size: 80.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.fitness_center,
                          size: 80.sp,
                          color: Colors.grey[600],
                        ),
                      ),

                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Play button overlay
                  Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.play_circle_fill,
                        size: 80.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () => _navigateToVideoPlayer(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Exercise details
          SliverToBoxAdapter(
            child: exerciseModelAsync.when(
              data: (exerciseModel) {
                if (exerciseModel == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Could not find the exercise details',
                        style: TextUtils.kBodyText(context),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise stats row
                      _buildStatsRow(context),

                      SizedBox(height: 24.h),

                      // Description
                      Text(
                        'Description',
                        style: TextUtils.kSubHeading(context).copyWith(
                          fontSize: 20.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        exerciseModel.detailedDescription,
                        style: TextUtils.kBodyText(
                          context,
                        ).copyWith(fontSize: 16.sp, height: 1.5),
                      ),

                      SizedBox(height: 24.h),

                      // Muscles targeted
                      Text(
                        'Muscles Targeted',
                        style: TextUtils.kSubHeading(context).copyWith(
                          fontSize: 20.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        exerciseModel.musclesTargeted,
                        style: TextUtils.kBodyText(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // How to perform
                      Text(
                        'How to Perform',
                        style: TextUtils.kSubHeading(context).copyWith(
                          fontSize: 20.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildHowToSection(context, exerciseModel.howTo),

                      SizedBox(height: 24.h),

                      // Time recommendation
                      Text(
                        'Time Recommendation',
                        style: TextUtils.kSubHeading(context).copyWith(
                          fontSize: 20.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        exerciseModel.timeRecommendation,
                        style: TextUtils.kBodyText(
                          context,
                        ).copyWith(fontSize: 16.sp, height: 1.5),
                      ),

                      SizedBox(height: 24.h),

                      // Tips and common mistakes
                      _buildTipsAndMistakesSection(
                        context,
                        exerciseModel.tips,
                        exerciseModel.commonMistakes,
                      ),

                      SizedBox(height: 24.h),

                      // Video button
                      _buildWatchVideoButton(context),

                      SizedBox(height: 16.h),

                      // Start workout button
                      _buildStartWorkoutButton(context),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Error loading exercise details: $error',
                        style: TextUtils.kBodyText(context),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.local_fire_department,
            '${exercise.calories}',
            'calories',
            Colors.orange,
          ),
          _buildStatItem(
            context,
            Icons.timer,
            exercise.duration,
            'duration',
            Colors.blue,
          ),
          _buildStatItem(
            context,
            _getDifficultyIcon(exercise.difficulty),
            exercise.difficulty,
            'level',
            _getDifficultyColor(context, exercise.difficulty),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextUtils.kSubHeading(context).copyWith(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextUtils.kBodyText(
            context,
          ).copyWith(fontSize: 14.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHowToSection(BuildContext context, String howTo) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_walk, color: Colors.green),
                SizedBox(width: 8.w),
                Text(
                  'Step-by-Step Instructions',
                  style: TextUtils.kBodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              howTo,
              style: TextUtils.kBodyText(context).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsAndMistakesSection(
    BuildContext context,
    String? tips,
    String? commonMistakes,
  ) {
    // Handle nulls for tips and mistakes
    final tipText =
        tips ??
        'Focus on maintaining proper form throughout the exercise. Quality of movement is more important than quantity.';
    final mistakesText =
        commonMistakes ??
        'Avoid rushing through the movement or using momentum. This reduces effectiveness and increases injury risk.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips & Common Mistakes',
          style: TextUtils.kSubHeading(context).copyWith(
            fontSize: 20.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoCard(
                context,
                'Tips',
                tipText,
                Icons.lightbulb,
                Colors.amber,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildInfoCard(
                context,
                'Common\nMistakes',
                mistakesText,
                Icons.error_outline,
                Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextUtils.kBodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              content,
              style: TextUtils.kBodyText(
                context,
              ).copyWith(fontSize: 14.sp, height: 1.4, color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchVideoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchYoutubeVideo(exercise.videoUrl),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red[400]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.red[400], size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Watch on YouTube',
              style: TextUtils.kBodyText(context).copyWith(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWorkoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToVideoPlayer(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        'Start Workout',
        style: TextUtils.kSubHeading(
          context,
        ).copyWith(fontSize: 18.sp, color: Colors.white),
      ),
    );
  }

  void _navigateToVideoPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoPlayerScreen(
              exercise: exercise,
              onVideoComplete: () {
                // Empty callback as we now handle navigation to WorkoutCompleteScreen
                // directly from VideoPlayerScreen
              },
            ),
      ),
    );
  }

  Future<void> _launchYoutubeVideo(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Icons.sentiment_satisfied;
      case 'Intermediate':
        return Icons.fitness_center;
      case 'Advanced':
        return Icons.whatshot;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
