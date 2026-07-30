import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Core/app_image.dart';
import 'login_screen.dart';

class WalkThroughScreen extends StatefulWidget {
  const WalkThroughScreen({super.key});

  @override
  State<WalkThroughScreen> createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Widget _buildImage(String assetPath) {
    return Center(
      child: Image.asset(
        assetPath,
        width: 300.w,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image, size: 200.w, color: Colors.grey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 18.sp,
        color: Colors.white.withOpacity(0.7),
        height: 1.5,
      ),
      bodyPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
      pageColor: Colors.transparent, // Let gradient show through
      imagePadding: EdgeInsets.only(top: 80.h, bottom: 20.h),
      imageAlignment: Alignment.center,
      bodyAlignment: Alignment.center,
    );

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
        child: IntroductionScreen(
          key: introKey,
          globalBackgroundColor: Colors.transparent,
          allowImplicitScrolling: true,
          autoScrollDuration: 3000,
          infiniteAutoScroll: false,
          pages: [
            PageViewModel(
              title: "Manage Your Money",
              body: "Keep track of your expenses and savings with elegant ease and perfect security.",
              image: _buildImage(AppImage.walk1),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Secure Payments",
              body: "Your transactions are shielded by state-of-the-art encryption protocols.",
              image: _buildImage(AppImage.walk2),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Stay Organized",
              body: "Unlock powerful insights into your spending habits to build true wealth.",
              image: _buildImage(AppImage.walk3),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16.sp)),
          ),
          next: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ),
          done: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: Text('Done', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16.sp)),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: EdgeInsets.all(24.r),
          controlsPadding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 4.h),
          dotsDecorator: DotsDecorator(
            size: Size(10.r, 10.r),
            color: Colors.white.withOpacity(0.2),
            activeColor: Colors.amber,
            activeSize: Size(25.r, 10.r),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.r)),
            ),
          ),
        ),
      ),
    );
  }
}
