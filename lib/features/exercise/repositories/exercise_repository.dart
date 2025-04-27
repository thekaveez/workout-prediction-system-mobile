import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:workout_prediction_system_mobile/features/exercise/models/exercise_model.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore;

  ExerciseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _exercisesCollection =>
      _firestore.collection('exercises');

  // Get all exercises
  Stream<List<ExerciseModel>> getAllExercises() {
    return _exercisesCollection
        .orderBy('difficulty') // Order by difficulty level
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExerciseModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get exercises by difficulty
  Stream<List<ExerciseModel>> getExercisesByDifficulty(String difficulty) {
    return _exercisesCollection
        .where('difficulty', isEqualTo: difficulty)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExerciseModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single exercise by ID
  Future<ExerciseModel?> getExerciseById(String id) async {
    final docSnap = await _exercisesCollection.doc(id).get();
    if (docSnap.exists) {
      return ExerciseModel.fromFirestore(docSnap);
    }
    return null;
  }

  // Search exercises by name or muscles targeted
  Stream<List<ExerciseModel>> searchExercises(String query) {
    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();

    // Firebase doesn't directly support case-insensitive search, so we'll filter client-side
    return _exercisesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ExerciseModel.fromFirestore(doc)).where(
        (exercise) {
          return exercise.name.toLowerCase().contains(lowercaseQuery) ||
              exercise.musclesTargeted.toLowerCase().contains(lowercaseQuery) ||
              exercise.detailedDescription.toLowerCase().contains(
                lowercaseQuery,
              );
        },
      ).toList();
    });
  }

  // Initialize Firestore with exercises from the JSON file
  Future<void> initializeExercisesFromJson() async {
    try {
      // Check if exercises already exist in Firestore
      final snapshot = await _exercisesCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Exercises already initialized in Firestore');
        return;
      }

      // Load exercises from JSON file
      final jsonString = await rootBundle.loadString('excercises.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Batch write to Firestore for better performance
      final batch = _firestore.batch();

      // Process each difficulty level
      for (final level in jsonData.keys) {
        // Convert level to a more standardized difficulty name
        final String difficulty = _mapLevelToDifficulty(level);

        // Process exercises in this level
        final exercises = jsonData[level] as List<dynamic>;
        for (final exerciseData in exercises) {
          final data = exerciseData as Map<String, dynamic>;

          // Add difficulty field
          data['difficulty'] = difficulty;

          // Create document reference with a unique ID
          final docRef = _exercisesCollection.doc();
          batch.set(docRef, data);
        }
      }

      // Commit the batch
      await batch.commit();
      print('Successfully initialized exercises in Firestore');
    } catch (e) {
      print('Error initializing exercises: $e');
      rethrow;
    }
  }

  // Map the level from JSON to a standardized difficulty
  String _mapLevelToDifficulty(String level) {
    switch (level) {
      case 'Beginner Level':
        return 'Beginner';
      case 'Intermediate Level':
        return 'Intermediate';
      case 'Advanced Level':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
