import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KSnackBar {
  /// Shows a success toast.
  static void showSuccess(BuildContext context, {required String message, String? title}) {
    MotionToast.success(
      title: title != null ? Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)) : null,
      description: Text(message, style: TextStyle(fontSize: 14.sp)),
      borderRadius: 16.r,
      width: 300.w,
    ).show(context);
  }

  /// Shows an error toast.
  static void showError(BuildContext context, {required String message, String? title}) {
    MotionToast.error(
      title: title != null ? Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)) : null,
      description: Text(message, style: TextStyle(fontSize: 14.sp)),
      borderRadius: 16.r,
      width: 300.w,
    ).show(context);
  }

  /// Shows a warning toast.
  static void showWarning(BuildContext context, {required String message, String? title}) {
    MotionToast.warning(
      title: title != null ? Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)) : null,
      description: Text(message, style: TextStyle(fontSize: 14.sp)),
      borderRadius: 16.r,
      width: 300.w,
    ).show(context);
  }

  /// Shows an info toast.
  static void showInfo(BuildContext context, {required String message, String? title}) {
    MotionToast.info(
      title: title != null ? Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)) : null,
      description: Text(message, style: TextStyle(fontSize: 14.sp)),
      borderRadius: 16.r,
      width: 300.w,
    ).show(context);
  }
}
