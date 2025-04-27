import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String musclesTargeted;
  final String howTo;
  final String? commonMistakes;
  final String? tips;
  final String caloriesBurned;
  final String timeRecommendation;
  final String detailedDescription;
  final String url;
  final String difficulty; // Derived from the level in the JSON
  final String? thumbnailUrl; // For displaying thumbnails in the app

  ExerciseModel({
    required this.id,
    required this.name,
    required this.musclesTargeted,
    required this.howTo,
    this.commonMistakes,
    this.tips,
    required this.caloriesBurned,
    required this.timeRecommendation,
    required this.detailedDescription,
    required this.url,
    required this.difficulty,
    this.thumbnailUrl,
  });

  // Create from Firestore document
  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseModel(
      id: doc.id,
      name: data['name'] ?? '',
      musclesTargeted: data['muscles_targeted'] ?? '',
      howTo: data['how_to'] ?? '',
      commonMistakes: data['common_mistakes'],
      tips: data['tips'],
      caloriesBurned: data['calories_burned'] ?? '',
      timeRecommendation: data['time_recommendation'] ?? '',
      detailedDescription: data['detailed_description'] ?? '',
      url: data['url'] ?? '',
      difficulty: data['difficulty'] ?? 'Beginner',
      thumbnailUrl: data['thumbnail_url'],
    );
  }

  // Convert to a format that can be stored in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscles_targeted': musclesTargeted,
      'how_to': howTo,
      'common_mistakes': commonMistakes,
      'tips': tips,
      'calories_burned': caloriesBurned,
      'time_recommendation': timeRecommendation,
      'detailed_description': detailedDescription,
      'url': url,
      'difficulty': difficulty,
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Extract numeric calories value from the string (e.g., "~15 kcal" -> 15)
  int get calories {
    final regex = RegExp(r'~?(\d+)(?:\-\-\d+)?\s*kcal');
    final match = regex.firstMatch(caloriesBurned);
    if (match != null && match.groupCount >= 1) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  // Extract duration in minutes from the exercise description if available
  String get duration {
    // Try to extract from name first (e.g., "Neck Rolls (30 sec each side)")
    final nameRegex = RegExp(
      r'\((\d+)\s*(?:sec|min|seconds|minutes)\s*(?:each|per)?\s*(?:side|direction|leg|foot)?\)',
    );
    final nameMatch = nameRegex.firstMatch(name);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      final value = int.parse(nameMatch.group(1)!);
      // If it's seconds, convert to a minute format
      if (name.contains('sec')) {
        if (value < 60) {
          return '00:$value';
        } else {
          final minutes = value ~/ 60;
          final seconds = value % 60;
          return '$minutes:${seconds.toString().padLeft(2, '0')}';
        }
      } else {
        return '$value min';
      }
    }

    // Try to extract from time recommendation
    final timeRegex = RegExp(r'(\d+)\s*(?:sec|min|seconds|minutes)');
    final timeMatch = timeRegex.firstMatch(timeRecommendation);
    if (timeMatch != null && timeMatch.groupCount >= 1) {
      final value = int.parse(timeMatch.group(1)!);
      if (timeRecommendation.contains('sec')) {
        if (value < 60) {
          return '00:$value';
        } else {
          final minutes = value ~/ 60;
          final seconds = value % 60;
          return '$minutes:${seconds.toString().padLeft(2, '0')}';
        }
      } else {
        return '$value min';
      }
    }

    // Default
    return '1 min';
  }

  // Create a simplified view model for the exercise screen
  ExerciseData toExerciseData() {
    final youtubeId = _extractYoutubeId(url);
    final thumbnail =
        thumbnailUrl ??
        (youtubeId != null
            ? 'https://img.youtube.com/vi/$youtubeId/0.jpg'
            : null);

    return ExerciseData(
      id: id,
      title: name,
      description: detailedDescription,
      thumbnailUrl: thumbnail,
      videoUrl: url,
      duration: duration,
      difficulty: difficulty,
      calories: calories,
    );
  }

  // Helper to extract YouTube ID from a URL
  String? _extractYoutubeId(String url) {
    RegExp regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/|youtube\.com\/user\/[\w-]+\/\w+\/|youtube\.com\/[\w-]+\/[\w-]+\/|youtube\.com\/shorts\/)([\w-]{11})(?:\?|&|\b)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}

// This is the data model used by the UI components
class ExerciseData {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String videoUrl;
  final String duration;
  final String difficulty;
  final int calories;

  ExerciseData({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.difficulty,
    required this.calories,
  });
}
