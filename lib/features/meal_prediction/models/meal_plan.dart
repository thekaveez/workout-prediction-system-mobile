class MealPlan {
  final String id;
  final String label;
  final List<MealItem> breakfast;
  final List<MealItem> lunch;
  final List<MealItem> dinner;
  final String description;

  MealPlan({
    required this.id,
    required this.label,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.description,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      breakfast: _parseMealItems(json['breakfast']),
      lunch: _parseMealItems(json['lunch']),
      dinner: _parseMealItems(json['dinner']),
    );
  }

  static List<MealItem> _parseMealItems(dynamic mealData) {
    if (mealData == null) return [];

    // Handle case where mealData is a Map instead of a List
    if (mealData is Map<String, dynamic>) {
      // Convert single map to a list with one item
      return [MealItem.fromJson(mealData)];
    }

    // Handle case where mealData is already a List
    if (mealData is List) {
      return mealData.map((meal) => MealItem.fromJson(meal)).toList();
    }

    // If we can't parse the data, return an empty list
    return [];
  }
}

class MealItem {
  final String id;
  final String name;
  final List<String> images;
  final int calories;
  final List<String> benefits;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, dynamic>? nutritionInfo;

  MealItem({
    required this.id,
    required this.name,
    required this.images,
    required this.calories,
    required this.benefits,
    required this.ingredients,
    required this.instructions,
    this.nutritionInfo,
  });

  String get imageUrl => images.isNotEmpty ? images.first : '';

  List<String> get imageUrls => images;

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      images: _parseImagesList(json['images']),
      calories: json['calories'] is int ? json['calories'] : 0,
      benefits: _parseStringList(json['benefits']),
      ingredients: _parseStringList(json['ingredients']),
      instructions: _parseStringList(json['instructions']),
      nutritionInfo:
          json['nutritionInfo'] is Map ? json['nutritionInfo'] : null,
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';

    // Handle case where a list is provided instead of a string
    if (value is List) {
      return value.isNotEmpty ? value.first.toString() : '';
    }

    return value.toString();
  }

  static List<String> _parseImagesList(dynamic images) {
    if (images == null) return [];

    if (images is String) {
      return [images];
    }

    if (images is List) {
      return images.map((img) => img.toString()).toList();
    }

    return [];
  }

  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];

    // If a single string is provided instead of a list
    if (list is String) {
      return [list];
    }

    // Handle case where list is already a List
    if (list is List) {
      return list.map((item) => item.toString()).toList();
    }

    return [];
  }
}
