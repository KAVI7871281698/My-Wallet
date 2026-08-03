import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
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
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'By accessing and using My Wallet, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you may not use our service.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 20.h),
            Text(
              '2. User Accounts',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'When you create an account with us, you guarantee that the information you provide is accurate, complete, and current at all times. Inaccurate information may result in immediate termination of your account.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 20.h),
            Text(
              '3. Changes to Terms',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion.',
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
