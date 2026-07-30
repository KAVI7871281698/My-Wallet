import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Widgets/snack_bar.dart';
import '../../Services/saving_service.dart';
import '../../Models/saving_model.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../Widgets/swip_button.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({super.key});

  @override
  State<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final SavingService _savingService = SavingService();
  bool _isLoading = false;
  String _selectedFilter = "Month";
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                "My Savings",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Modern Saving Card
            StreamBuilder<List<SavingModel>>(
              stream: _savingService.getSavings(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return FadeInUp(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 30.sp,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Permission or Index Error!\nPlease update Firestore Rules & Indexes.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allSavings = snapshot.data ?? [];

                // Filtering Logic
                final filteredSavings = allSavings.where((s) {
                  if (_selectedFilter == "Month") {
                    return s.date.month == _focusedDate.month &&
                        s.date.year == _focusedDate.year;
                  } else {
                    return s.date.year == _focusedDate.year;
                  }
                }).toList();

                double totalSavings = filteredSavings.fold(
                  0.0,
                  (sum, item) => sum + item.amount,
                );
                final formatter = NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹ ',
                );

                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF764BA2).withAlpha(76),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Leaf/Savings icon simulation
                            Container(
                              width: 40.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildDateFilterIcon(),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          "Total $_selectedFilter Savings",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          formatter.format(totalSavings),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "STATUS",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10.sp,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  totalSavings > 0 ? "ON TRACK" : "NO DEPOSITS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            // Decorative circles simulation
                            Row(
                              children: [
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(-10, 0),
                                  child: Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Minimalist Deposit Input
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Enter Deposit Amount",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "₹",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF764BA2),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                              fontSize: 50.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.2),
                                fontSize: 50.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Save Button
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: SwipeButton(
                  text: "Deposit Now",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  onSwipe: () async {
                    if (_amountController.text.isEmpty) {
                      KSnackBar.showError(
                        context,
                        message: "Please enter an amount!",
                      );
                      return;
                    }

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) throw "User not logged in";

                      final saving = SavingModel(
                        amount: double.parse(_amountController.text),
                        date: DateTime.now(),
                        userId: user.uid,
                      );

                      await _savingService.addSaving(saving);

                      if (mounted) {
                        KSnackBar.showSuccess(
                          context,
                          message: "Savings updated successfully!",
                        );
                        _amountController.clear();
                      }
                    } catch (e) {
                      if (mounted) {
                        KSnackBar.showError(context, message: "Error: $e");
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterIcon() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(60),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.calendar_month_rounded,
          color: Theme.of(context).colorScheme.surface,
          size: 22.sp,
        ),
      ),
      onSelected: (value) async {
        if (value == "SelectDate") {
          // Open Month/Year Picker
          final DateTime? picked = await showMonthPicker(
            context: context,
            initialDate: _focusedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (picked != null && mounted) {
            setState(() {
              _focusedDate = picked;
              // If we pick a date, we probably want to see the month view
              _selectedFilter = "Month";
            });
          }
        } else {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "Month",
          child: Row(
            children: [
              Icon(
                Icons.calendar_view_month,
                size: 20,
                color: Color(0xFF764BA2),
              ),
              SizedBox(width: 10),
              Text("Show Month View"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "Year",
          child: Row(
            children: [
              Icon(Icons.calendar_view_day, size: 20, color: Color(0xFF764BA2)),
              SizedBox(width: 10),
              Text("Show Year View"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: "SelectDate",
          child: Row(
            children: [
              Icon(
                Icons.edit_calendar_rounded,
                size: 20,
                color: Color(0xFF764BA2),
              ),
              SizedBox(width: 10),
              Text("Choose Month/Year"),
            ],
          ),
        ),
      ],
    );
  }
}
