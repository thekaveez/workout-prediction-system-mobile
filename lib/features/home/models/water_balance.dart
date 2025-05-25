import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WaterBalance extends Equatable {
  final double totalWaterConsumed; // in milliliters
  final double waterGoal; // in milliliters
  final List<WaterEntry> entries;
  final WaterCupSize defaultCupSize;

  const WaterBalance({
    required this.totalWaterConsumed,
    required this.waterGoal,
    required this.entries,
    required this.defaultCupSize,
  });

  double get progress => totalWaterConsumed / waterGoal;

  String get formattedTotalWater {
    if (totalWaterConsumed >= 1000) {
      return '${(totalWaterConsumed / 1000).toStringAsFixed(1)} L';
    }
    return '${totalWaterConsumed.toInt()} ml';
  }

  String get formattedGoalWater {
    if (waterGoal >= 1000) {
      return '${(waterGoal / 1000).toStringAsFixed(1)} L';
    }
    return '${waterGoal.toInt()} ml';
  }

  factory WaterBalance.empty() {
    return const WaterBalance(
      totalWaterConsumed: 0,
      waterGoal: 2500, // Default goal: 2.5L
      entries: [],
      defaultCupSize: WaterCupSize.medium,
    );
  }

  WaterBalance copyWith({
    double? totalWaterConsumed,
    double? waterGoal,
    List<WaterEntry>? entries,
    WaterCupSize? defaultCupSize,
  }) {
    return WaterBalance(
      totalWaterConsumed: totalWaterConsumed ?? this.totalWaterConsumed,
      waterGoal: waterGoal ?? this.waterGoal,
      entries: entries ?? this.entries,
      defaultCupSize: defaultCupSize ?? this.defaultCupSize,
    );
  }

  @override
  List<Object?> get props => [
    totalWaterConsumed,
    waterGoal,
    entries,
    defaultCupSize,
  ];
}

class WaterEntry {
  final String id;
  final double amount; // in milliliters
  final DateTime timestamp;

  WaterEntry({required this.amount, required this.timestamp, String? id})
    : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

enum WaterCupSize {
  small(amount: 200, label: 'Small (200ml)', icon: Icons.local_drink),
  medium(amount: 300, label: 'Medium (300ml)', icon: Icons.local_drink),
  large(amount: 500, label: 'Large (500ml)', icon: Icons.local_drink),
  extraLarge(
    amount: 750,
    label: 'Extra Large (750ml)',
    icon: Icons.local_drink,
  ),
  custom(amount: 0, label: 'Custom', icon: Icons.edit);

  const WaterCupSize({
    required this.amount,
    required this.label,
    required this.icon,
  });

  final double amount;
  final String label;
  final IconData icon;
}
