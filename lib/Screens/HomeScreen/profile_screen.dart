import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/expense_service.dart';
import '../../Services/saving_service.dart';
import '../../Models/expense_model.dart';
import '../../Models/saving_model.dart';
import '../OnBoardingScreen/login_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExpenseService _expenseService = ExpenseService();
  final SavingService _savingService = SavingService();

  String _userName = "User";
  String _userEmail = "user@mail.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "User";
      _userEmail =
          prefs.getString('user_email') ??
          _auth.currentUser?.email ??
          "user@mail.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final String userId = user?.uid ?? "";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Background Gradient Header
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30.r),
                  ),
                ),
              ),
              // Profile Image with Ring
              Positioned(
                bottom: -50.h,
                child: ZoomIn(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).dividerColor,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60.r,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withAlpha(30),
                      child: Icon(
                        Icons.person_rounded,
                        size: 70.r,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60.h),

          // User Info
          FadeInUp(
            child: Column(
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  _userEmail,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),

          // Stats Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: StreamBuilder<List<ExpenseModel>>(
              stream: _expenseService.getExpenses(userId),
              builder: (context, expenseSnapshot) {
                return StreamBuilder<List<SavingModel>>(
                  stream: _savingService.getSavings(userId),
                  builder: (context, savingSnapshot) {
                    final expenses = expenseSnapshot.data ?? [];
                    final savings = savingSnapshot.data ?? [];

                    double totalExpense = expenses.fold(
                      0.0,
                      (sum, item) => sum + item.amount,
                    );
                    double totalSaving = savings.fold(
                      0.0,
                      (sum, item) => sum + item.amount,
                    );

                    final formatter = NumberFormat.compact();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Wallets", "${expenses.length}"),
                        _buildStatItem(
                          "Expenses",
                          "₹${formatter.format(totalExpense)}",
                        ),
                        _buildStatItem(
                          "Savings",
                          "₹${formatter.format(totalSaving)}",
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          SizedBox(height: 30.h),

          // Menu Options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildProfileMenu(
                    Icons.person_outline_rounded,
                    "Edit Profile",
                    Colors.blue,
                  ),
                ),
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: _buildProfileMenu(
                    Icons.security_rounded,
                    "Security & Privacy",
                    Colors.green,
                  ),
                ),
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: _buildProfileMenu(
                    Icons.notifications_none_rounded,
                    "Notification Settings",
                    Colors.orange,
                  ),
                ),
                FadeInLeft(
                  delay: const Duration(milliseconds: 500),
                  child: _buildProfileMenu(
                    Icons.help_outline_rounded,
                    "Help Center",
                    Colors.purple,
                  ),
                ),
                FadeInLeft(
                  delay: const Duration(milliseconds: 600),
                  child: _buildProfileMenu(
                    Icons.logout_rounded,
                    "Logout",
                    Colors.red,
                    isLogout: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 100.h), // Spacing for bottom bar
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return FadeIn(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(
    IconData icon,
    String title,
    Color color, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isLogout
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16.sp,
          color: Colors.grey,
        ),
        onTap: onTap ?? () {},
      ),
    );
  }
}
