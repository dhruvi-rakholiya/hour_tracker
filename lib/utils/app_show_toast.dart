import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/utils/app_colors.dart';

Future<void> showToast(
  String message, {
  Toast? toastLength,
  double? fontSize,
}) async {
  await Fluttertoast.showToast(
    msg: message.tr,
    toastLength: toastLength ?? Toast.LENGTH_SHORT,
    backgroundColor: white,
    fontSize: fontSize ?? 18.sp,
    textColor: black,
    gravity: ToastGravity.BOTTOM,
  );
}
