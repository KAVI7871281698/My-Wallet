import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SliderMenu extends StatelessWidget {
  final Function(String) onItemClick;
  final String selectedTitle;
  final String userName;
  final String userEmail;

  const SliderMenu({
    super.key,
    required this.onItemClick,
    this.selectedTitle = "Home",
    this.userName = "User",
    this.userEmail = "user@mail.com",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B132B), // Deep royal navy background
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 30.h, left: 30.w, bottom: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleek Modern Profile Card
              Container(
                margin: EdgeInsets.only(right: 30.w),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      child: Icon(
                        Icons.person_rounded,
                        size: 30.r,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "Premium Member",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // Massive Typography Menu Items
              _drawerItem("Home", selectedTitle == "Home"),
              _drawerItem("My Wallet", selectedTitle == "My Wallet"),
              _drawerItem("Statistics", selectedTitle == "Statistics"),
              _drawerItem("Notifications", selectedTitle == "Notifications"),
              _drawerItem("Settings", selectedTitle == "Settings"),

              const Spacer(),

              // Minimalist Logout
              InkWell(
                onTap: () => onItemClick("Logout"),
                child: Row(
                  children: [
                    Icon(
                      Icons.power_settings_new_rounded,
                      color: Colors.redAccent,
                      size: 22.sp,
                    ),
                    SizedBox(width: 15.w),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(String title, bool isSelected) {
    return InkWell(
      onTap: () => onItemClick(title),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(bottom: 25.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 8.w : 0,
              height: 8.w,
              margin: EdgeInsets.only(right: isSelected ? 15.w : 0),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 10)],
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                fontSize: isSelected ? 28.sp : 24.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
