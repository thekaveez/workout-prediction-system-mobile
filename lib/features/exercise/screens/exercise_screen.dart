import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';
import 'package:workout_prediction_system_mobile/features/exercise/providers/exercise_provider.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/exercise_detail_screen.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/video_player_screen.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/workout_complete_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize exercises data in Firestore if needed
    _initializeExercises();
  }

  Future<void> _initializeExercises() async {
    try {
      final repository = ref.read(exerciseRepositoryProvider);
      await repository.initializeExercisesFromJson();
    } catch (e) {
      print('Error initializing exercises: $e');
      // Handle error, possibly show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the search provider if searching, otherwise use the filtered provider
    final exercisesProvider =
        _isSearching && _searchQuery.isNotEmpty
            ? searchExerciseDataProvider(_searchQuery)
            : filteredExerciseDataProvider(_selectedFilter);

    final exercisesAsyncValue = ref.watch(exercisesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Exercise Library',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter
          _buildSearchAndFilter(),

          // Exercise list
          Expanded(
            child: exercisesAsyncValue.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Text(
                      'No exercises found for the selected filter',
                      style: TextUtils.kBodyText(context),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseCard(context, exercises[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Error loading exercises: $error',
                      style: TextUtils.kBodyText(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              hintStyle: TextUtils.kBodyText(
                context,
              ).copyWith(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
                _isSearching = _searchQuery.isNotEmpty;
              });
            },
          ),
          SizedBox(height: 16.h),

          // Filter chips
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  _filterOptions.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              // Clear search when changing filters
                              _isSearching = false;
                              _searchQuery = '';
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        showCheckmark: false,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseData exercise) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: () => _navigateToVideoPlayer(context, exercise),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180.h,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child:
                      exercise.thumbnailUrl != null
                          ? Image.network(
                            exercise.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 64.sp,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          )
                          : Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 64.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                ),
                Icon(
                  Icons.play_circle_fill,
                  size: 64.sp,
                  color: Colors.white70,
                ),
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      exercise.duration,
                      style: TextUtils.kBodyText(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(exercise.difficulty),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      exercise.difficulty,
                      style: TextUtils.kBodyText(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Exercise details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.title,
                          style: TextUtils.kSubHeading(
                            context,
                          ).copyWith(fontSize: 18.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${exercise.calories} kcal',
                        style: TextUtils.kBodyText(context).copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    exercise.description,
                    style: TextUtils.kBodyText(
                      context,
                    ).copyWith(color: Colors.grey[400], fontSize: 14.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
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

  void _navigateToVideoPlayer(BuildContext context, ExerciseData exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }
}
