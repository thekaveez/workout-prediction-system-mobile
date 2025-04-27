import 'dart:math';

class UserSetupData {
  final int age;
  final double weight; // kg
  final double height; // cm
  final String gender; // "male" or "female"
  final String activityLevel;

  // Calculated values
  final double bmi;
  final double bmr;
  final double caloriesNeeded;
  final int bmiTag;

  UserSetupData({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
  }) : // Calculate BMI: weight (kg) / height (m)^2
       bmi = weight / pow(height / 100, 2),
       // Calculate BMR using Harris-Benedict formula
       bmr =
           gender.toLowerCase() == "male"
               ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
               : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age),
       // Calculate calories needed based on activity level
       caloriesNeeded =
           (gender.toLowerCase() == "male"
               ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
               : 447.593 +
                   (9.247 * weight) +
                   (3.098 * height) -
                   (4.330 * age)) *
           _getActivityMultiplier(activityLevel),
       // Determine BMI tag: 0 = Underweight, 1 = Normal, 2 = Overweight, 3 = Obese
       bmiTag = _getBmiTag(weight / pow(height / 100, 2));

  static double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'Sedentary':
        return 1.2;
      case 'Lightly Active':
        return 1.375;
      case 'Moderately Active':
        return 1.55;
      case 'Very Active':
        return 1.725;
      case 'Extra Active':
        return 1.9;
      default:
        return 1.375; // Default to lightly active
    }
  }

  static int _getBmiTag(double bmi) {
    if (bmi < 18.5) {
      return 0; // Underweight
    } else if (bmi >= 18.5 && bmi < 25) {
      return 1; // Normal
    } else if (bmi >= 25 && bmi < 30) {
      return 2; // Overweight
    } else {
      return 3; // Obese
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
      'bmi': bmi,
      'bmr': bmr,
      'caloriesNeeded': caloriesNeeded,
      'bmiTag': bmiTag,
    };
  }

  // For API prediction request
  List<dynamic> toApiInputList() {
    return [
      age,
      weight,
      height / 100, // Convert height to meters for API
      bmi,
      bmr,
      _getActivityMultiplier(activityLevel),
      caloriesNeeded,
      bmiTag,
    ];
  }

  factory UserSetupData.fromJson(Map<String, dynamic> json) {
    return UserSetupData(
      age: json['age'],
      weight: json['weight'].toDouble(),
      height: json['height'].toDouble(),
      gender: json['gender'],
      activityLevel: json['activityLevel'],
    );
  }
}
