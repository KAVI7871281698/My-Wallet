import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Core/app_image.dart';
import 'OnBoardingScreen/walk_through_screen.dart';
import '../Widgets/responsive_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for the animation to play
    await Future.delayed(const Duration(seconds: 3), () {});
    
    if (mounted) {
      // Check if user is already logged in
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Direct to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        // Go to Walkthrough/Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WalkThroughScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor, // Deep royal color
              const Color(0xFF0B132B), // Very dark navy
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsiveLayout(
          mobile: _buildSplashContent(),
          tablet: _buildSplashContent(),
          desktop: _buildSplashContent(),
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15 * value),
                        blurRadius: 50 * value,
                        spreadRadius: 10 * value,
                      ),
                    ],
                  ),
                  child: Image.asset(AppImage.appIcon, width: 200.w, height: 200.h),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 40.h),
        Text(
          'MY WALLET',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 6.w,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'PREMIUM SECURE',
          style: TextStyle(
            color: Colors.amber.shade300,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.w,
          ),
        ),
        SizedBox(height: 80.h),
        CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          strokeWidth: 2,
        ),
      ],
    );
  }
}
