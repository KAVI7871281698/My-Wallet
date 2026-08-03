import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../Widgets/snack_bar.dart';
import '../../Services/expense_service.dart';
import '../../Models/expense_model.dart';
import '../../Core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Widgets/swip_button.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = "Food";
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = AppConstants.categories;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimalist Amount Input
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Enter Amount",
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
                            color: Theme.of(context).primaryColor,
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

            SizedBox(height: 30.h),

            // Category Selection Panel
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withAlpha(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 15.h,
                      crossAxisSpacing: 15.w,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      bool isSelected = _selectedCategory == category["name"];

                      return FadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory = category["name"],
                          ),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? category["color"]
                                      : category["color"].withAlpha(15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: category["color"].withAlpha(
                                              76,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  category["icon"],
                                  color: isSelected
                                      ? Colors.white
                                      : category["color"],
                                  size: 26.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                category["name"],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Save Button
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: SwipeButton(
                  text: "Save Expense",
                  onSwipe: () async {
                    if (_amountController.text.isEmpty) {
                      KSnackBar.showError(
                        context,
                        message: "Please enter an amount!",
                      );
                      return;
                    }

                    final double? amount = double.tryParse(
                      _amountController.text,
                    );
                    if (amount == null || amount <= 0) {
                      KSnackBar.showError(
                        context,
                        message: "Please enter a valid amount!",
                      );
                      return;
                    }

                    try {
                      final User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final expense = ExpenseModel(
                          amount: amount,
                          category: _selectedCategory,
                          date: DateTime.now(),
                          userId: user.uid,
                        );

                        await _expenseService.addExpense(expense);

                        if (mounted) {
                          KSnackBar.showSuccess(
                            context,
                            message:
                                "₹ ${_amountController.text} saved under $_selectedCategory",
                          );
                          _amountController.clear();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        KSnackBar.showError(
                          context,
                          message: "Failed to save expense: $e",
                        );
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
}
