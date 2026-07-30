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

  /// Save User data to Firestore
  Future<void> signUp({
    required String name,
    required String email,
    required String mobile,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        debugPrint("No authenticated user found. Signing in anonymously...");
        UserCredential creds = await _auth.signInAnonymously();
        currentUser = creds.user;
      }
      
      String uid = currentUser!.uid;

      UserModel userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        mobile: mobile,
        createdAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _usersCollection.doc(uid).set(userModel.toMap());
      debugPrint("User data saved to Firestore for UID: $uid");
    } catch (e) {
      debugPrint("Error in signUp (saving data): $e");
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

  /// Verify Phone Number (via Twilio Cloud Function)
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    bool forceMock = false, // Ignored in Twilio flow, kept for compatibility
  }) async {
    try {
      final callable = _functions.httpsCallable('sendOtp');
      await callable.call({
        'phone': phoneNumber,
      });
      // Return the phone number as verificationId
      onCodeSent(phoneNumber);
    } catch (e) {
      debugPrint("Twilio Verify Error: $e");
      onVerificationFailed(
        FirebaseAuthException(
          code: 'twilio-send-failed',
          message: e.toString(),
        )
      );
    }
  }

  /// Sign In with OTP (via Twilio Cloud Function and Custom Auth)
  Future<UserCredential?> signInWithOtp(String verificationId, String smsCode) async {
    try {
      final callable = _functions.httpsCallable('verifyOtp');
      final result = await callable.call({
        'phone': verificationId,
        'otp': smsCode,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['success'] != true) {
        throw FirebaseAuthException(
          code: "invalid-verification-code",
          message: "The verification code is invalid.",
        );
      }

      final customToken = data['customToken'];
      if (customToken == null) {
        throw FirebaseAuthException(
          code: "custom-token-missing",
          message: "Failed to receive auth token from backend.",
        );
      }

      // Complete login with Custom Token
      return await _auth.signInWithCustomToken(customToken);
    } catch (e) {
      debugPrint("Twilio Sign In Error: $e");
      rethrow;
    }
  }
}
