import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Widgets/snack_bar.dart';
import '../../Services/saving_service.dart';
import '../../Models/saving_model.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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
                  color: const Color(0xFF1E3C72),
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
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha(76),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total $_selectedFilter Savings",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  formatter.format(totalSavings),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            // Modern Date Filter Popup
                            _buildDateFilterIcon(),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFilter == "Month"
                                        ? "Status for ${DateFormat('MMMM yyyy').format(_focusedDate)}"
                                        : "Status for ${DateFormat('yyyy').format(_focusedDate)}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    totalSavings > 0
                                        ? "Great Progress!"
                                        : "Deposit to Start",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 30.h),

            FadeInLeft(
              child: Text(
                "Add to Savings",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 15.h),

            // Input Section
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _amountController,
                      label: "Deposit Amount",
                      hint: "₹ 0.00",
                      icon: Icons.account_balance_wallet_rounded,
                      isNumber: true,
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
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_amountController.text.isEmpty) {
                            KSnackBar.showError(
                              context,
                              message: "Please enter an amount!",
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

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
                              KSnackBar.showError(
                                context,
                                message: "Error: $e",
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00b09b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFF00b09b).withAlpha(100),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Deposit Now",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
          color: Colors.white,
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
              Icon(Icons.calendar_view_month, size: 20, color: Color(0xFF00b09b)),
              SizedBox(width: 10),
              Text("Show Month View"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "Year",
          child: Row(
            children: [
              Icon(Icons.calendar_view_day, size: 20, color: Color(0xFF00b09b)),
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
              Icon(Icons.edit_calendar_rounded, size: 20, color: Color(0xFF00b09b)),
              SizedBox(width: 10),
              Text("Choose Month/Year"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF00b09b)),
            filled: true,
            fillColor: Colors.grey.withAlpha(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 15.h,
            ),
          ),
        ),
      ],
    );
  }
}
