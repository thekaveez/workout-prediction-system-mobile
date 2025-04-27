import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workout_prediction_system_mobile/features/meal_prediction/models/meal_plan.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/models/user_setup_data.dart';

class MealPredictionRepository {
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  final String _apiUrl =
      'https://meal-prediction-app-458020.uc.r.appspot.com/predict';

  MealPredictionRepository({
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _httpClient = httpClient ?? http.Client();

  // Get meal prediction from API
  Future<int> getMealPrediction(UserSetupData userData) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': userData.toApiInputList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prediction'];
      } else {
        throw Exception(
          'Failed to get meal prediction: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get meal prediction: $e');
    }
  }

  // Get meal plan by label from Firestore
  Future<MealPlan> getMealPlanByLabel(int labelNumber) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('meal_plans')
              .doc('label$labelNumber')
              .get();

      if (querySnapshot.exists == false) {
        throw Exception('No meal plan found for label: label$labelNumber');
      }

      return MealPlan.fromJson(querySnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get meal plan: $e');
    }
  }

  // Get all available meal plans from Firestore
  Future<List<MealPlan>> getAllMealPlans() async {
    try {
      final querySnapshot = await _firestore.collection('meal_plans').get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all meal plans: $e');
    }
  }
}
