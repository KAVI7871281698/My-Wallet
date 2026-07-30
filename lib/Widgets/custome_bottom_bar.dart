import 'dart:ui';
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
      // Keep it floating above the bottom edge with margins
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 25.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.r),
        boxShadow: [
          // Soft ambient drop shadow for the 3D floating effect
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(30),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ), // Glassmorphism blur
          child: Container(
            // Translucent surface for the frosted glass effect
            color: Theme.of(context).colorScheme.surface.withAlpha(220),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            // Faint border for the glass edge highlight
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.surface.withAlpha(100),
                width: 1.5,
              ),
            ),
            child: GNav(
              rippleColor: Colors.grey.shade300,
              hoverColor: Colors.grey.shade100,
              gap: 8,
              activeColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              iconSize: 24.sp,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.transparent,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), // Inactive icon color
              // A vibrant gradient for the active tab (trending)
              tabBackgroundGradient: index == 2 
                  ? const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              tabBorderRadius: 25.r,
              curve: Curves.easeOutExpo,
              tabs: [
                GButton(
                  icon: index == 0 ? Icons.home_rounded : Icons.home_outlined,
                  text: 'Home',
                ),
                GButton(
                  icon: index == 1
                      ? Icons.account_balance_wallet_rounded
                      : Icons.account_balance_wallet_outlined,
                  text: 'Wallet',
                ),
                GButton(
                  icon: index == 2
                      ? Icons.savings_rounded
                      : Icons.savings_outlined,
                  text: 'Savings',
                ),
                GButton(
                  icon: index == 3
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  text: 'Profile',
                ),
              ],
              selectedIndex: index,
              onTabChange: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
