import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../Core/app_image.dart';
import '../../Services/auth_service.dart';
import '../../Models/user_model.dart';
import '../../Widgets/responsive_widgets.dart';
import '../../Widgets/snack_bar.dart';
import '../HomeScreen/dashboard.dart';
import 'otp_screen.dart';
import 'regiester_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = "";
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _saveDeviceDetails() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        debugPrint("Location: ${position.latitude}, ${position.longitude}");
      }

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceModel = "";
      String deviceVersion = "";

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        deviceVersion = iosInfo.systemVersion;
      }

      debugPrint("Device: $deviceModel ($deviceVersion)");
    } catch (e) {
      debugPrint("Error saving device details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2C2E33),
        ),
        child: ResponsiveLayout(
          mobile: _buildLoginContent(context),
          tablet: _buildLoginContent(context),
          desktop: _buildLoginContent(context),
        ),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),
            Center(
              child: Image.asset(
                AppImage.loginIllustration,
                height: 250.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "Login to Your Account",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            
            Column(
              children: [
                  Form(
                    key: _formKey,
                    child: IntlPhoneField(
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      dropdownTextStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                      dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                        ),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        _phoneNumber = phone.completeNumber;
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_phoneNumber.isEmpty) {
                          KSnackBar.showError(
                            context,
                            message: "Please enter your phone number!",
                          );
                          return;
                        }
                        setState(() => _isLoading = true);

                        // Save location and device info
                        await _saveDeviceDetails();

                        try {
                          // We will check if the user is registered AFTER they successfully authenticate with OTP.
                          // This avoids Firestore Permission Denied errors because unauthenticated users cannot read the DB.

                          await _authService.verifyPhone(
                            phoneNumber: _phoneNumber,
                            onCodeSent: (verificationId) async {
                              debugPrint(
                                "OTP Code Sent! Verification ID: $verificationId",
                              );
                              setState(() => _isLoading = false);

                              final otp = await OtpScreen.show(
                                context,
                                phoneNumber: _phoneNumber,
                                verificationId: verificationId,
                              );

                              if (otp != null && context.mounted) {
                                setState(() => _isLoading = true);
                                try {
                                  // Fetch and cache user data for immediate show in Dashboard
                                  User? user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    // NOW we check if they are registered!
                                    bool userExists = await _authService.checkUserExists(_phoneNumber);
                                    
                                    if (!userExists) {
                                      // If they authenticated but aren't registered in the DB
                                      await FirebaseAuth.instance.signOut();
                                      if (context.mounted) {
                                        setState(() => _isLoading = false);
                                        KSnackBar.showError(
                                          context,
                                          message: "Number not registered. Please sign up first.",
                                        );
                                      }
                                      return;
                                    }

                                    UserModel? data = await _authService.getUserData(user.uid);
                                    if (data != null) {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      await prefs.setString('user_name', data.name);
                                      await prefs.setString('user_email', data.email);
                                    }
                                  }

                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Dashboard(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => _isLoading = false);
                                    KSnackBar.showError(context, message: "Login failed: $e");
                                  }
                                }
                              }
                            },
                            onVerificationFailed: (e) {
                              if (e.code == "billing-not-enabled" ||
                                  e.code == "too-many-requests" ||
                                  e.message?.contains("BILLING_NOT_ENABLED") ==
                                      true ||
                                  e.message?.contains("too-many-requests") ==
                                      true) {
                                debugPrint(
                                  "[DEV MODE] Firebase issue (${e.code}). Switching to Manual Testing...",
                                );
                                _authService.verifyPhone(
                                  phoneNumber: _phoneNumber,
                                  onCodeSent: (mockId) async {
                                    setState(() => _isLoading = false);
                                    final otp = await OtpScreen.show(
                                      context,
                                      phoneNumber: _phoneNumber,
                                      verificationId: mockId,
                                    );
                                    if (otp != null && context.mounted) {
                                      setState(() => _isLoading = true);
                                      try {
                                        // Fetch and cache user data for immediate show in Dashboard
                                        User? user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          UserModel? data = await _authService
                                              .getUserData(user.uid);
                                          if (data != null) {
                                            SharedPreferences prefs =
                                                await SharedPreferences.getInstance();
                                            await prefs.setString(
                                              'user_name',
                                              data.name,
                                            );
                                            await prefs.setString(
                                              'user_email',
                                              data.email,
                                            );
                                          }
                                        }

                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Dashboard(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          setState(() => _isLoading = false);
                                          KSnackBar.showError(context, message: "Login failed: $e");
                                        }
                                      }
                                    }
                                  },
                                  onVerificationFailed: (e) {
                                    setState(() => _isLoading = false);
                                    debugPrint(
                                      "Manual Verification Failed: $e",
                                    );
                                  },
                                  forceMock: true,
                                );
                                return;
                              }
                              setState(() => _isLoading = false);
                              debugPrint("Phone Verification Failed: $e");
                              KSnackBar.showError(
                                context,
                                message: "Verification failed: ${e.message}",
                              );
                            },
                          );
                        } catch (e) {
                          setState(() => _isLoading = false);
                          debugPrint("Error: $e");
                          KSnackBar.showError(
                            context,
                            message: "An error occurred: $e",
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 10,
                  shadowColor: const Color(0xFFFF8C00).withOpacity(0.5),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFF8C00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
