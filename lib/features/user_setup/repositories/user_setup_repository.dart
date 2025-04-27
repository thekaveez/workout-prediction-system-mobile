import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/models/user_setup_data.dart';

class UserSetupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserSetupRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Save user setup data to Firestore
  Future<void> saveUserSetupData(UserSetupData setupData) async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('users').doc(userId).update({
        'setupData': setupData.toJson(),
        'hasCompletedSetup': true,
      });
    } catch (e) {
      throw Exception('Failed to save user setup data: $e');
    }
  }

  // Get user setup data from Firestore
  Future<UserSetupData?> getUserSetupData() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists ||
          !docSnapshot.data()!.containsKey('setupData')) {
        return null;
      }

      return UserSetupData.fromJson(docSnapshot.data()!['setupData']);
    } catch (e) {
      throw Exception('Failed to get user setup data: $e');
    }
  }

  // Check if user has completed setup
  Future<bool> hasUserCompletedSetup() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        return false;
      }

      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        return false;
      }

      return docSnapshot.data()!['hasCompletedSetup'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
