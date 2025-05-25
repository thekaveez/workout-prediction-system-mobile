import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_prediction_system_mobile/features/home/models/water_balance.dart';

part 'water_balance_provider.g.dart';

@riverpod
class WaterBalanceNotifier extends _$WaterBalanceNotifier {
  static const String _prefsKeyWaterConsumed = 'water_consumed';
  static const String _prefsKeyWaterGoal = 'water_goal';
  static const String _prefsKeyDefaultCupSize = 'default_cup_size';
  static const String _prefsKeyEntries = 'water_entries';

  @override
  Future<WaterBalance> build() async {
    return _loadWaterData();
  }

  Future<WaterBalance> _loadWaterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get water consumed amount for today
      final todayKey = _getTodayKey();
      final double totalWaterConsumed =
          prefs.getDouble('${_prefsKeyWaterConsumed}_$todayKey') ?? 0;

      // Get water goal (default 2500ml if not set)
      final double waterGoal = prefs.getDouble(_prefsKeyWaterGoal) ?? 2500;

      // Get default cup size (medium by default)
      final String cupSizeStr =
          prefs.getString(_prefsKeyDefaultCupSize) ?? WaterCupSize.medium.name;
      final WaterCupSize defaultCupSize = WaterCupSize.values.firstWhere(
        (e) => e.name == cupSizeStr,
        orElse: () => WaterCupSize.medium,
      );

      // Get water entries for today
      final List<String>? entriesJson = prefs.getStringList(
        '${_prefsKeyEntries}_$todayKey',
      );
      final List<WaterEntry> entries = [];

      if (entriesJson != null) {
        for (final entryStr in entriesJson) {
          final parts = entryStr.split('|');
          if (parts.length == 3) {
            entries.add(
              WaterEntry(
                id: parts[0],
                amount: double.parse(parts[1]),
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(parts[2]),
                ),
              ),
            );
          }
        }
      }

      return WaterBalance(
        totalWaterConsumed: totalWaterConsumed,
        waterGoal: waterGoal,
        entries: entries,
        defaultCupSize: defaultCupSize,
      );
    } catch (e) {
      debugPrint('Error loading water data: $e');
      return WaterBalance.empty();
    }
  }

  // Add water entry
  Future<void> addWater(double amount) async {
    final currentState = await future;

    // Create new entry
    final entry = WaterEntry(amount: amount, timestamp: DateTime.now());

    final updatedEntries = List<WaterEntry>.from(currentState.entries)
      ..add(entry);
    final newTotalConsumed = currentState.totalWaterConsumed + amount;

    // Update state with optimistic update
    state = AsyncValue.data(
      currentState.copyWith(
        totalWaterConsumed: newTotalConsumed,
        entries: updatedEntries,
      ),
    );

    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _getTodayKey();

      // Save total consumed
      await prefs.setDouble(
        '${_prefsKeyWaterConsumed}_$todayKey',
        newTotalConsumed,
      );

      // Save entries
      final entriesStr =
          updatedEntries
              .map(
                (e) =>
                    '${e.id}|${e.amount}|${e.timestamp.millisecondsSinceEpoch}',
              )
              .toList();

      await prefs.setStringList('${_prefsKeyEntries}_$todayKey', entriesStr);
    } catch (e) {
      debugPrint('Error saving water data: $e');
      // Revert optimistic update on error
      state = AsyncValue.data(currentState);
    }
  }

  // Remove water entry
  Future<void> removeWaterEntry(String entryId) async {
    final currentState = await future;
    final entry = currentState.entries.firstWhere((e) => e.id == entryId);

    final updatedEntries = List<WaterEntry>.from(currentState.entries)
      ..removeWhere((e) => e.id == entryId);

    final newTotalConsumed = currentState.totalWaterConsumed - entry.amount;

    // Update state with optimistic update
    state = AsyncValue.data(
      currentState.copyWith(
        totalWaterConsumed: newTotalConsumed < 0 ? 0 : newTotalConsumed,
        entries: updatedEntries,
      ),
    );

    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _getTodayKey();

      // Save total consumed
      await prefs.setDouble(
        '${_prefsKeyWaterConsumed}_$todayKey',
        newTotalConsumed < 0 ? 0 : newTotalConsumed,
      );

      // Save entries
      final entriesStr =
          updatedEntries
              .map(
                (e) =>
                    '${e.id}|${e.amount}|${e.timestamp.millisecondsSinceEpoch}',
              )
              .toList();

      await prefs.setStringList('${_prefsKeyEntries}_$todayKey', entriesStr);
    } catch (e) {
      debugPrint('Error removing water entry: $e');
      // Revert optimistic update on error
      state = AsyncValue.data(currentState);
    }
  }

  // Update water goal
  Future<void> updateWaterGoal(double newGoal) async {
    if (newGoal <= 0) return;

    final currentState = await future;

    // Update state with optimistic update
    state = AsyncValue.data(currentState.copyWith(waterGoal: newGoal));

    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefsKeyWaterGoal, newGoal);
    } catch (e) {
      debugPrint('Error updating water goal: $e');
      // Revert optimistic update on error
      state = AsyncValue.data(currentState);
    }
  }

  // Update default cup size
  Future<void> updateDefaultCupSize(WaterCupSize cupSize) async {
    final currentState = await future;

    // Update state with optimistic update
    state = AsyncValue.data(currentState.copyWith(defaultCupSize: cupSize));

    // Save to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyDefaultCupSize, cupSize.name);
    } catch (e) {
      debugPrint('Error updating default cup size: $e');
      // Revert optimistic update on error
      state = AsyncValue.data(currentState);
    }
  }

  // Helper to get today's date as a string key
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
