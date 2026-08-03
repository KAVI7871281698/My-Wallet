import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');

  // Collection Reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Helper to generate a dummy email from mobile number
  String _generateEmailFromMobile(String mobile) {
    // Remove non-digit characters if any
    String cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    return '$cleanMobile@mywallet.app';
  }

  /// Sign Up with Mobile and Password
  Future<UserCredential?> signUpWithPassword({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      String synthesizedEmail = _generateEmailFromMobile(mobile);
      
      UserCredential creds = await _auth.createUserWithEmailAndPassword(
        email: synthesizedEmail,
        password: password,
      );
      
      User? currentUser = creds.user;
      
      if (currentUser != null) {
        String uid = currentUser.uid;

        UserModel userModel = UserModel(
          uid: uid,
          name: name,
          email: email, // Store their real email in Firestore
          mobile: mobile,
          createdAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _usersCollection.doc(uid).set(userModel.toMap());
        debugPrint("User data saved to Firestore for UID: $uid");
      }
      return creds;
    } catch (e) {
      debugPrint("Error in signUpWithPassword: $e");
      rethrow;
    }
  }

  /// Login with Mobile and Password
  Future<UserCredential?> loginWithPassword({
    required String mobile,
    required String password,
  }) async {
    try {
      String synthesizedEmail = _generateEmailFromMobile(mobile);
      
      return await _auth.signInWithEmailAndPassword(
        email: synthesizedEmail,
        password: password,
      );
    } catch (e) {
      debugPrint("Error in loginWithPassword: $e");
      rethrow;
    }
  }

  /// Update User Data
  Future<void> updateUser(String uid, {required String name, required String email}) async {
    try {
      await _usersCollection.doc(uid).update({
        'name': name,
        'email': email,
      });
      debugPrint("User data updated in Firestore for UID: $uid");
    } catch (e) {
      debugPrint("Error updating user data: $e");
      rethrow;
    }
  }

  /// Get Current User Data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if User Exists by Phone Number
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final querySnapshot = await _usersCollection
          .where('mobile', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking if user exists: $e");
      return false;
    }
  }
}
