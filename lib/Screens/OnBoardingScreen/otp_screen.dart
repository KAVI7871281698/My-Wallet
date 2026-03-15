import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Widgets/snack_bar.dart';
import '../../Services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpScreen({
    super.key, 
    required this.phoneNumber, 
    required this.verificationId
  });

  /// Shows the OTP screen as a bottom sheet popup.
  static Future<String?> show(BuildContext context, {
    required String phoneNumber,
    required String verificationId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OtpScreen(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
      ),
    );
  }

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final SmartAuth _smartAuth = SmartAuth.instance;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startSmsListener();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startSmsListener() async {
    try {
      // Priority 1: User Consent API (Shows a system popup for permission)
      final res = await _smartAuth.getSmsWithUserConsentApi();
      final smsData = res.data;
      if (smsData != null && smsData.code != null && mounted) {
        setState(() {
          _pinController.text = smsData.code!;
        });
        // Auto verify if code is received
        _verifyOtp(smsData.code!);
      }
    } catch (e) {
      debugPrint("SmartAuth Error: $e");
    }
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  void _verifyOtp(String code) async {
    if (code.length < 6) return; // Firebase OTPs are 6 digits
    
    debugPrint("VERIFYING ENTERED OTP: $code");

    setState(() => _isLoading = true);
    try {
      debugPrint("Verifying OTP: $code for Verification ID: ${widget.verificationId}");
      
      await _authService.signInWithOtp(widget.verificationId, code);
      
      if (mounted) {
        setState(() => _isLoading = false);
        KSnackBar.showSuccess(context, message: "Phone number verified successfully!");
        Navigator.pop(context, code);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("OTP Verification Error: $e");
        KSnackBar.showError(context, message: "Invalid OTP. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Beautiful Modern Pin Theme
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Handle Bar
            Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 30.h),
            
            // Icon & Title
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security_rounded, size: 40.r, color: Colors.black),
            ),
            SizedBox(height: 20.h),
            Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 10.h),
            Text.rich(
              TextSpan(
                text: 'We have sent a verification code to\n',
                children: [
                  TextSpan(
                    text: widget.phoneNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Pin Input
            Pinput(
              length: 6,
              controller: _pinController,
              focusNode: _focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              autofocus: true,
              onCompleted: _verifyOtp,
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 9.h),
                    width: 22.w,
                    height: 1.h,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Resend Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed: _canResend ? _startResendTimer : null,
                  child: Text(
                    _canResend ? "Resend" : "Resend in ${_resendTimer}s",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _canResend ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _verifyOtp(_pinController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
