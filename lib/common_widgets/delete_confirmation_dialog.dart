import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/utils/app_colors.dart';

void showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trash Icon Header
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: dangerColor,
                  size: 32.sp,
                ),
              ),

              SizedBox(height: 14.h),

              // Title
              CustomAppText(
                text: title,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // Description Message
              CustomAppText(
                text: message,
                fontSize: 13.sp,
                color: textSecondary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Action Buttons Row (Cancel & Delete)
              Row(
                children: [
                  Expanded(
                    child: CustomOpacityWidget(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: CustomAppText(
                            text: "Cancel",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: CustomOpacityWidget(
                      onTap: () {
                        Get.back();
                        onDelete();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: dangerColor,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: dangerColor.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomAppText(
                            text: "Delete",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
