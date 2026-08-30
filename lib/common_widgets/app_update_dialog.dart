import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/utils/app_colors.dart';

void showAppUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: !AdsVariable.isForceUpdate,
    builder: (context) {
      return PopScope(
        canPop: !AdsVariable.isForceUpdate,
        child: Dialog(
          backgroundColor: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Rocket / Update Animated Badge Icon
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: white,
                    size: 36.sp,
                  ),
                ),

                SizedBox(height: 18.h),

                // Title
                CustomAppText(
                  text: AdsVariable.updateTitle.isNotEmpty
                      ? AdsVariable.updateTitle
                      : "New Version Available! 🚀",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Description message
                CustomAppText(
                  text: AdsVariable.updateMessage.isNotEmpty
                      ? AdsVariable.updateMessage
                      : "We've added exciting new features, performance updates, and bug fixes to enhance your experience. Update now!",
                  fontSize: 13.sp,
                  color: textSecondary,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Primary Action Button - Update Now
                CustomOpacityWidget(
                  onTap: () async {
                    try {
                      final inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        await inAppReview.openStoreListing();
                      } else {
                        Get.snackbar(
                          "Redirecting to Store",
                          "Opening application page...",
                          backgroundColor: primaryColor,
                          colorText: white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (_) {
                      Get.snackbar(
                        "Store Unavailable",
                        "Please update the application from your App Store.",
                        backgroundColor: primaryColor,
                        colorText: white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: CustomAppText(
                        text: "UPDATE NOW",
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                  ),
                ),

                // Optional "Later" button if force_update is false
                if (!AdsVariable.isForceUpdate) ...[
                  SizedBox(height: 10.h),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: CustomAppText(
                      text: "Maybe Later",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
