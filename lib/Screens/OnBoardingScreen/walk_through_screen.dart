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
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 19.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      bodyPadding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      pageColor: Theme.of(context).colorScheme.surface,
      imagePadding: EdgeInsets.only(top: 40.h),
      imageAlignment: Alignment.center,
      bodyAlignment: Alignment.center,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000,
      infiniteAutoScroll: false,
      pages: [
        PageViewModel(
          title: "Manage Your Money",
          body: "Keep track of your expenses and savings with ease.",
          image: _buildImage(AppImage.walk1),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Secure Payments",
          body: "Your transactions are always safe and encrypted.",
          image: _buildImage(AppImage.walk2),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stay Organized",
          body: "Get insights into your spending habits.",
          image: _buildImage(AppImage.walk3),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Theme.of(context).primaryColor.withAlpha(50),
        activeColor: Theme.of(context).primaryColor,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
