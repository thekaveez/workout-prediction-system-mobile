import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/exercise/repositories/user_exercise_repository.dart';

// Provider for the user exercise repository
final userExerciseRepositoryProvider = Provider<UserExerciseRepository>((ref) {
  return UserExerciseRepository();
});

// Provider for recording a completed exercise
final recordExerciseProvider = Provider<
  Future<void> Function({
    required String exerciseId,
    required String exerciseName,
    required int duration,
    required int caloriesBurned,
    String? difficulty,
  })
>((ref) {
  final repository = ref.watch(userExerciseRepositoryProvider);

  return ({
    required String exerciseId,
    required String exerciseName,
    required int duration,
    required int caloriesBurned,
    String? difficulty,
  }) async {
    return repository.recordCompletedExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      duration: duration,
      caloriesBurned: caloriesBurned,
      difficulty: difficulty,
    );
  };
});

// Provider for user exercise history
final userExerciseHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final repository = ref.watch(userExerciseRepositoryProvider);
  return repository.getUserExerciseHistory();
});

// Provider for user exercise stats
final userExerciseStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(userExerciseRepositoryProvider);
  return repository.getUserExerciseStats();
});

// Provider for user favorite exercises
final userFavoriteExercisesProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final repository = ref.watch(userExerciseRepositoryProvider);
      return repository.getUserFavoriteExercises();
    });
