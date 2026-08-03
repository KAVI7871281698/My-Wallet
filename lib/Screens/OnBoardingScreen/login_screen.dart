import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../Core/app_image.dart';
import '../../Services/auth_service.dart';
import '../../Models/user_model.dart';
import '../../Widgets/responsive_widgets.dart';
import '../../Widgets/snack_bar.dart';
import '../HomeScreen/dashboard.dart';

import 'regiester_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = "";
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  final AuthService _authService = AuthService();

  Future<void> _saveDeviceDetails() async {
    try {
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
                    child: Column(
                      children: [
                        IntlPhoneField(
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
                    SizedBox(height: 20.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.white70, size: 22.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(color: Color(0xFFFF8C00), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: Colors.red.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        labelStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14.sp),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
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
                        if (!_formKey.currentState!.validate()) return;
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
                          await _authService.loginWithPassword(
                            mobile: _phoneNumber,
                            password: _passwordController.text,
                          );

                          // Fetch and cache user data for immediate show in Dashboard
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
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
                            KSnackBar.showError(context, message: "Login failed: $e");
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => _isLoading = false);
                          }
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
                        "Login",
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
