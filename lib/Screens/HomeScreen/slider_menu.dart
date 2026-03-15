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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
        ),
      ),
      padding: EdgeInsets.only(top: 80.h, left: 24.w, right: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section with Glassmorphism feel
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 35.r, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 50.h),

          // Menu Items
          _drawerItem(Icons.dashboard_rounded, "Home", selectedTitle == "Home"),
          _drawerItem(
            Icons.account_balance_wallet_rounded,
            "My Wallet",
            selectedTitle == "My Wallet",
          ),
          _drawerItem(
            Icons.analytics_rounded,
            "Statistics",
            selectedTitle == "Statistics",
          ),
          _drawerItem(
            Icons.notifications_rounded,
            "Notifications",
            selectedTitle == "Notifications",
          ),
          _drawerItem(
            Icons.settings_rounded,
            "Settings",
            selectedTitle == "Settings",
          ),

          const Spacer(),

          // Logout Section
          Container(
            margin: EdgeInsets.only(bottom: 40.h),
            child: _drawerItem(
              Icons.logout_rounded,
              "Logout",
              false,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    bool isSelected, {
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: () => onItemClick(title),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.redAccent.shade100 : Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                color: isLogout ? Colors.redAccent.shade100 : Colors.white,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
