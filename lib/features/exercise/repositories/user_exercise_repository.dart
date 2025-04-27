import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';

class UserExerciseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserExerciseRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _userExerciseCollection =>
      _firestore.collection('user_exercises');

  // Get user ID
  String? get _userId => _auth.currentUser?.uid;

  // Record a completed exercise session
  Future<void> recordCompletedExercise({
    required String exerciseId,
    required String exerciseName,
    required int duration,
    required int caloriesBurned,
    String? difficulty,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create a document in the user_exercises collection
      await _userExerciseCollection.add({
        'user_id': userId,
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'duration': duration,
        'calories_burned': caloriesBurned,
        'difficulty': difficulty,
        'completed_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording completed exercise: $e');
      rethrow;
    }
  }

  // Get user's exercise history
  Stream<List<Map<String, dynamic>>> getUserExerciseHistory() {
    final userId = _userId;
    if (userId == null) {
      // Return empty stream if user is not authenticated
      return Stream.value([]);
    }

    return _userExerciseCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;

            // Convert Firestore timestamp to DateTime
            if (data['completed_at'] != null) {
              data['completed_at'] =
                  (data['completed_at'] as Timestamp).toDate();
            } else {
              data['completed_at'] = DateTime.now();
            }

            return data;
          }).toList();
        });
  }

  // Get user's exercise stats (total calories, duration, etc.)
  Stream<Map<String, dynamic>> getUserExerciseStats() {
    final userId = _userId;
    if (userId == null) {
      // Return empty stats if user is not authenticated
      return Stream.value({
        'total_exercises': 0,
        'total_calories': 0,
        'total_duration': 0,
        'beginner_count': 0,
        'intermediate_count': 0,
        'advanced_count': 0,
      });
    }

    return _userExerciseCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          int totalExercises = snapshot.docs.length;
          int totalCalories = 0;
          int totalDuration = 0;
          int beginnerCount = 0;
          int intermediateCount = 0;
          int advancedCount = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            // Sum up calories and duration
            totalCalories += (data['calories_burned'] as int? ?? 0);
            totalDuration += (data['duration'] as int? ?? 0);

            // Count by difficulty
            switch (data['difficulty']) {
              case 'Beginner':
                beginnerCount++;
                break;
              case 'Intermediate':
                intermediateCount++;
                break;
              case 'Advanced':
                advancedCount++;
                break;
            }
          }

          return {
            'total_exercises': totalExercises,
            'total_calories': totalCalories,
            'total_duration': totalDuration,
            'beginner_count': beginnerCount,
            'intermediate_count': intermediateCount,
            'advanced_count': advancedCount,
          };
        });
  }

  // Get user's favorite exercises (most completed)
  Stream<List<Map<String, dynamic>>> getUserFavoriteExercises() {
    final userId = _userId;
    if (userId == null) {
      // Return empty list if user is not authenticated
      return Stream.value([]);
    }

    return _userExerciseCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Group exercises by exercise_id and count occurrences
          final Map<String, Map<String, dynamic>> exerciseCounts = {};

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final exerciseId = data['exercise_id'] as String;

            if (exerciseCounts.containsKey(exerciseId)) {
              exerciseCounts[exerciseId]!['count'] =
                  (exerciseCounts[exerciseId]!['count'] as int) + 1;
              exerciseCounts[exerciseId]!['total_calories'] =
                  (exerciseCounts[exerciseId]!['total_calories'] as int) +
                  (data['calories_burned'] as int? ?? 0);
            } else {
              exerciseCounts[exerciseId] = {
                'exercise_id': exerciseId,
                'exercise_name': data['exercise_name'],
                'difficulty': data['difficulty'],
                'count': 1,
                'total_calories': data['calories_burned'] as int? ?? 0,
              };
            }
          }

          // Convert to list and sort by count (descending)
          final favoriteExercises = exerciseCounts.values.toList();
          favoriteExercises.sort(
            (a, b) => (b['count'] as int).compareTo(a['count'] as int),
          );

          // Return top 5 or all if less than 5
          return favoriteExercises.take(5).toList();
        });
  }
}
