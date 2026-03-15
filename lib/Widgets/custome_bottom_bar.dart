import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const CustomBottomBar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Reduced margin to prevent overflow on smaller screens
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white, // Background changed to White
        borderRadius: BorderRadius.all(Radius.circular(30.r)),
        border: Border.all(
          color: Colors.blue.withAlpha(51), // Subtle blue border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withAlpha(
              20,
            ), // Softer shadow for white background
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        // Reduced horizontal padding to fix overflow
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: GNav(
          rippleColor: Colors.blue.withAlpha(51),
          hoverColor: Colors.blue.withAlpha(25),
          haptic: true,
          tabBorderRadius: 20.r,
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 400),
          gap: 4, // Reduced gap to fix overflow
          color: Colors.black45, // Unselected icon color
          activeColor: Colors.blue, // Active color changed to Blue
          iconSize: 22.sp, // Slightly reduced icon size to save space
          tabBackgroundColor: Colors.blue.withAlpha(
            25,
          ), // Light blue background for active tab
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          selectedIndex: index,
          onTabChange: onTap,
          tabs: const [
            GButton(icon: Icons.dashboard_rounded, text: 'Home'),
            GButton(
              icon: Icons.account_balance_wallet_rounded,
              text: 'Expense',
            ),
            GButton(icon: Icons.savings_rounded, text: 'Savings'),
            GButton(icon: Icons.person_rounded, text: 'Profile'),
          ],
        ),
      ),
    );
  }
}
