import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Verify Phone Number
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    bool forceMock = false, // Add this for testing
  }) async {
    if (forceMock) {
      // Generate a random 6-digit OTP
      String mockOtp = (Random().nextInt(900000) + 100000).toString();
      
      debugPrint("***************************************");
      debugPrint("[MOCK MODE] OTP FOR $phoneNumber: $mockOtp");
      debugPrint("***************************************");
      
      await Future.delayed(const Duration(seconds: 1));
      onCodeSent("mock_id:$mockOtp");
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onVerificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint("Firebase Verify Error: $e");
      rethrow;
    }
  }

  /// Sign In with OTP (Supports Mock)
  Future<UserCredential?> signInWithOtp(String verificationId, String smsCode) async {
    if (verificationId.startsWith("mock_id:")) {
      String expectedOtp = verificationId.split(":")[1];
      debugPrint("[MOCK] Verifying OTP: $smsCode (Expected: $expectedOtp)");
      
      if (smsCode == expectedOtp) {
        debugPrint("[MOCK] OTP Verified! Signing in anonymously for Firestore permissions...");
        // This gives us a real Firebase UID so that Firestore Security Rules work
        return await _auth.signInAnonymously();
      } else {
        debugPrint("[MOCK] Invalid OTP entered.");
        throw FirebaseAuthException(
          code: "invalid-verification-code",
          message: "The verification code is invalid.",
        );
      }
    }
    
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }
}
