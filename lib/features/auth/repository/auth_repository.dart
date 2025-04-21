import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workout_prediction_system_mobile/exceptions/auth_exceptions.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure we have a user
      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      final user = userCredential.user!;

      // Create user data in Firestore
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthExceptionCodes(errorCode: e.code);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure we have a user
      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      final user = userCredential.user!;

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // If user document doesn't exist for some reason, create it
        final userModel = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        return userModel;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthExceptionCodes(errorCode: e.code);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (metadata != null) {
        updateData['metadata'] = metadata;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }

      // Get updated user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw e.toString();
    }
  }

  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');

      // Upload the file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile with photo URL
      await updateUserProfile(userId: userId, photoUrl: downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw e.toString();
    }
  }
}
