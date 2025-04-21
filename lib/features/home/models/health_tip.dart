import 'package:equatable/equatable.dart';

class HealthTip extends Equatable {
  final String title;
  final String description;
  final String icon;
  final String category; // e.g., 'nutrition', 'activity', 'rest'

  const HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });

  @override
  List<Object?> get props => [title, description, icon, category];
}
