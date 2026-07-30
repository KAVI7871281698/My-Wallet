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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _buildLoginContent(context),
        tablet: _buildLoginContent(context),
        desktop: _buildLoginContent(context),
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
            TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Image.asset(
                AppImage.app_logo,
                width: 120.w,
                height: 120.h,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Login to your account to continue managing your finances effortlessly.",
              style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            SizedBox(height: 40.h),
            Form(
              key: _formKey,
              child: IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withAlpha(50),
                    ),
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

                              if (otp != null && mounted) {
                                setState(() => _isLoading = true);
                                // Fetch and cache user data for immediate show in Dashboard
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // NOW we check if they are registered!
                                  bool userExists = await _authService.checkUserExists(_phoneNumber);
                                  
                                  if (!userExists) {
                                    // If they authenticated but aren't registered in the DB
                                    await FirebaseAuth.instance.signOut();
                                    if (mounted) {
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

                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Dashboard(),
                                    ),
                                  );
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
                                    if (otp != null && mounted) {
                                      setState(() => _isLoading = true);
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

                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Dashboard(),
                                          ),
                                        );
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
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surface,
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
                  style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
