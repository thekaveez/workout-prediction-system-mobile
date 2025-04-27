import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';
import 'package:workout_prediction_system_mobile/features/exercise/repositories/exercise_repository.dart';

// Provider for the exercise repository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

// Provider for all exercises
final exercisesProvider = StreamProvider<List<ExerciseModel>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAllExercises();
});

// Provider for exercises filtered by difficulty
final exercisesByDifficultyProvider =
    StreamProvider.family<List<ExerciseModel>, String>((ref, difficulty) {
      if (difficulty == 'All') {
        return ref.watch(exercisesProvider.stream);
      } else {
        final repository = ref.watch(exerciseRepositoryProvider);
        return repository.getExercisesByDifficulty(difficulty);
      }
    });

// Provider for exercise search
final exerciseSearchProvider =
    StreamProvider.family<List<ExerciseModel>, String>((ref, query) {
      if (query.isEmpty) {
        return ref.watch(exercisesProvider.stream);
      } else {
        final repository = ref.watch(exerciseRepositoryProvider);
        return repository.searchExercises(query);
      }
    });

// Provider for a single exercise by ID
final exerciseByIdProvider = FutureProvider.family<ExerciseModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseById(id);
});

// Provider that converts ExerciseModel list to ExerciseData list for UI
final exerciseDataProvider =
    Provider.family<List<ExerciseData>, List<ExerciseModel>>((ref, exercises) {
      return exercises.map((exercise) => exercise.toExerciseData()).toList();
    });

// Combined provider that provides ExerciseData objects filtered by difficulty
final filteredExerciseDataProvider =
    StreamProvider.family<List<ExerciseData>, String>((ref, difficulty) async* {
      final exercisesStream = ref.watch(
        exercisesByDifficultyProvider(difficulty).stream,
      );

      await for (final exercises in exercisesStream) {
        yield exercises.map((e) => e.toExerciseData()).toList();
      }
    });

// Search provider that returns ExerciseData
final searchExerciseDataProvider =
    StreamProvider.family<List<ExerciseData>, String>((ref, query) async* {
      final exercisesStream = ref.watch(exerciseSearchProvider(query).stream);

      await for (final exercises in exercisesStream) {
        yield exercises.map((e) => e.toExerciseData()).toList();
      }
    });
