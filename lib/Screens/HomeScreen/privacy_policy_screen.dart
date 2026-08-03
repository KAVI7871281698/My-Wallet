import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for My Wallet',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '1. Information We Collect',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We may collect personal information such as your name, email address, and financial data when you use the My Wallet application. We only collect information that is necessary to provide you with our services.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 20.h),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We use your information to operate, maintain, and provide the features and functionality of the Service. We will not share or sell your personal information to third parties.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 20.h),
            Text(
              '3. Data Security',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We care about the security of your information and employ physical, administrative, and technological safeguards designed to preserve the integrity and security of all information collected through our Service.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
