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
            FadeInDown(
              child: Text(
                "Add Expense",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Amount Input Card
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(76),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Amount",
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: "₹ 0.00",
                        hintStyle: TextStyle(
                          color: Colors.white24,
                          fontSize: 36.sp,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            FadeInLeft(
              child: Text(
                "Category",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            SizedBox(height: 15.h),

            // Category Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 15.w,
                childAspectRatio: 0.8,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                bool isSelected = _selectedCategory == category["name"];

                return FadeIn(
                  delay: Duration(milliseconds: 100 * index),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = category["name"]),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category["color"]
                                : category["color"].withAlpha(25),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: category["color"].withAlpha(76),
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
                            size: 28.sp,
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
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                      KSnackBar.showError(context, message: "Please enter an amount!");
                      return;
                    }
                    
                    final double? amount = double.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) {
                      KSnackBar.showError(context, message: "Please enter a valid amount!");
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
                            message: "₹ ${_amountController.text} saved under $_selectedCategory"
                          );
                          _amountController.clear();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        KSnackBar.showError(context, message: "Failed to save expense: $e");
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
