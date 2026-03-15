import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../Core/app_image.dart';
import '../../Widgets/responsive_widgets.dart';
import '../../Widgets/snack_bar.dart';
import 'login_screen.dart';
import '../HomeScreen/dashboard.dart';
import '../../Services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _phoneNumber = "";
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getDeviceAndLocation() async {
    String lat = "0.0";
    String lng = "0.0";
    String deviceId = "Unknown";

    try {
      // 1. Get Location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          // Try to get last known position first (it's instant)
          Position? position = await Geolocator.getLastKnownPosition();
          
          if (position == null) {
            // If not available, get current position with a strict timeout
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 3),
            );
          }

          lat = position.latitude.toString();
          lng = position.longitude.toString();
        } catch (e) {
          debugPrint("Location fetch failed or timed out: $e");
        }
      }

      // 2. Get Device ID
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown";
      }
      
      // Store in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lat', lat);
      await prefs.setString('lng', lng);
      await prefs.setString('deviceId', deviceId);

    } catch (e) {
      debugPrint("Error fetching device/location: $e");
    }
    return {"lat": lat, "lng": lng, "deviceId": deviceId};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        mobile: _buildBody(context),
        tablet: _buildBody(context, isTablet: true),
        desktop: _buildBody(context, isDesktop: true),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {bool isTablet = false, bool isDesktop = false}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60.h),
            // App Logo
            TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                AppImage.app_logo,
                width: 100.w,
                height: 100.h,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Join us and start managing your wallet',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 40.h),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'John Doe',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  
                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'example@mail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  
                  // Mobile Field
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '98765 43210',
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red.shade300),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      _phoneNumber = phone.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      try {
                        if (!phone.isValidNumber()) {
                          return 'Please enter a valid phone number';
                        }
                      } catch (e) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_phoneNumber.isEmpty) {
                      KSnackBar.showError(context, message: "Please enter your mobile number");
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      // 1. Fetch device and location details
                      final details = await _getDeviceAndLocation();
                      
                      // 2. Start Phone Verification
                      await _authService.verifyPhone(
                        phoneNumber: _phoneNumber, 
                        onCodeSent: (verificationId) async {
                          debugPrint("OTP Code Sent! Verification ID: $verificationId");
                          setState(() => _isLoading = false);
                          
                          // 3. Show OTP Popup
                          final code = await OtpScreen.show(
                            context, 
                            phoneNumber: _phoneNumber, 
                            verificationId: verificationId,
                          );

                          if (code != null) {
                            // 4. OTP Verified! Now save to Firestore
                            setState(() => _isLoading = true);
                            
                            debugPrint("======= SIGNUP DATA =======");
                            debugPrint("Name: ${_nameController.text.trim()}");
                            debugPrint("Email: ${_emailController.text.trim()}");
                            debugPrint("Mobile: $_phoneNumber");
                            debugPrint("Latitude: ${details['lat']}");
                            debugPrint("Longitude: ${details['lng']}");
                            debugPrint("Device ID: ${details['deviceId']}");
                            debugPrint("===========================");

                            await _authService.signUp(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              mobile: _phoneNumber,
                            );

                            // 4. Update local cache for instant Dashboard greeting
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('user_name', _nameController.text.trim());
                            await prefs.setString('user_email', _emailController.text.trim());

                            if (mounted) KSnackBar.showSuccess(context, message: "Account created successfully!");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Dashboard()),
                            );
                            setState(() => _isLoading = false);
                          }
                        }, 
                        onVerificationFailed: (e) {
                          if (e.code == "billing-not-enabled" || 
                              e.code == "too-many-requests" ||
                              e.message?.contains("BILLING_NOT_ENABLED") == true ||
                              e.message?.contains("too-many-requests") == true) {
                            debugPrint("[DEV MODE] Firebase issue (${e.code}). Switching to Manual Testing...");
                            _authService.verifyPhone(
                              phoneNumber: _phoneNumber, 
                              onCodeSent: (mockId) async {
                                setState(() => _isLoading = false);
                                final otp = await OtpScreen.show(context, phoneNumber: _phoneNumber, verificationId: mockId);
                                if (otp != null && mounted) {
                                  // SAVE TO FIRESTORE EVEN IN MOCK MODE
                                  setState(() => _isLoading = true);
                                  await _authService.signUp(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    mobile: _phoneNumber,
                                  );
                                  
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('user_name', _nameController.text.trim());
                                  await prefs.setString('user_email', _emailController.text.trim());

                                  if (mounted) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
                                  }
                                }
                              }, 
                              onVerificationFailed: (e) {},
                              forceMock: true,
                            );
                            return;
                          }
                          setState(() => _isLoading = false);
                          debugPrint("Phone Verification Failed: $e");
                          KSnackBar.showError(context, message: "Verification failed: ${e.message}");
                        },
                      );
                    } catch (e) {
                      if (!mounted) return;
                      debugPrint("Registration Error: $e");
                      KSnackBar.showError(context, message: "An error occurred. Please try again.");
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  } else {
                    KSnackBar.showError(context, message: "Please fill all fields correctly");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.blue.withAlpha(150),
                ),
                child: _isLoading 
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Footer text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.black45, fontSize: 14.sp),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black54, size: 22.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.black87, fontSize: 14.sp),
        hintStyle: TextStyle(color: Colors.black26, fontSize: 14.sp),
      ),
    );
  }
}
