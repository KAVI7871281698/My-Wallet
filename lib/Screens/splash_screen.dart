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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _buildSplashContent(),
        tablet: _buildSplashContent(),
        desktop: _buildSplashContent(),
      ),
    );
  }

  Widget _buildSplashContent() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            duration: const Duration(seconds: 2),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: child,
                ),
              );
            },
            child: Image.asset(AppImage.app_logo, width: 250.w, height: 250.h),
          ),
          SizedBox(height: 30.h),
          Text(
            'MY WALLET',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.w,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Secure & Simple',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.w,
            ),
          ),
          SizedBox(height: 80.h),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }
}
