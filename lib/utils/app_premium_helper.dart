import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/screens/premium_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';

class AppPremiumHelper {
  /// Remote Config Project limit for free users (default 2)
  static int get freeProjectLimit => AdsVariable.freeProjectLimit;

  /// Check if user has active PRO subscription
  static bool get isPremium => AdsVariable.isPurchase;

  /// Returns true if user can add a project (either is PRO or hasn't reached limit)
  static bool canAddProject([int? currentCount]) {
    if (isPremium) return true;
    final count = currentCount ??
        (Get.isRegistered<ProjectController>()
            ? Get.find<ProjectController>().projects.length
            : 0);
    return count < freeProjectLimit;
  }

  /// Checks project limit and shows bottom sheet if limit is reached.
  /// Returns true if allowed to proceed to project creation.
  static bool checkProjectLimitAndPrompt(BuildContext context) {
    if (canAddProject()) {
      return true;
    }
    showProjectLimitBottomSheet(context);
    return false;
  }

  /// High-Premium Bottom Sheet when Free User hits Project Limit
  static void showProjectLimitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle indicator bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Crown Icon Badge Container
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  gradient: primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    color: white, size: 34.sp),
              ),
              SizedBox(height: 16.h),

              CustomAppText(
                text: "Project Limit Reached",
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              CustomAppText(
                text:
                    "Free plan allows creating up to $freeProjectLimit projects. Upgrade to Hour Tracker PRO to create unlimited client projects!",
                fontSize: 13.sp,
                color: textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // PRO Features List
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: appBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(Icons.folder_special_rounded,
                        "Unlimited Client & Freelance Projects"),
                    SizedBox(height: 8.h),
                    _buildFeatureItem(Icons.bolt_rounded,
                        "Advanced Overtime & Custom Rates"),
                    SizedBox(height: 8.h),
                    _buildFeatureItem(Icons.block_rounded,
                        "100% Ad-Free Experience"),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Upgrade Button
              CustomOpacityWidget(
                onTap: () {
                  Get.back();
                  Get.to(() => const PremiumScreen());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: white, size: 20.sp),
                        SizedBox(width: 8.w),
                        CustomAppText(
                          text: "UNLOCK UNLIMITED PROJECTS",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              TextButton(
                onPressed: () => Get.back(),
                child: CustomAppText(
                  text: "Maybe Later",
                  fontSize: 14.sp,
                  color: textMuted,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  /// High-Premium Bottom Sheet when Free User taps Locked Overtime Multiplier
  static void showOvertimeLockedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),

              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  gradient: primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: white, size: 34.sp),
              ),
              SizedBox(height: 16.h),

              CustomAppText(
                text: "Unlock Overtime Multiplier",
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              CustomAppText(
                text:
                    "Custom overtime pay multipliers (1.5x, 2.0x) are exclusive to PRO users. Upgrade to automatically calculate overtime pay accurately!",
                fontSize: 13.sp,
                color: textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              CustomOpacityWidget(
                onTap: () {
                  Get.back();
                  Get.to(() => const PremiumScreen());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_open_rounded, color: white, size: 20.sp),
                        SizedBox(width: 8.w),
                        CustomAppText(
                          text: "UPGRADE TO UNLOCK OVERTIME",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              TextButton(
                onPressed: () => Get.back(),
                child: CustomAppText(
                  text: "Cancel",
                  fontSize: 14.sp,
                  color: textMuted,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildFeatureItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: CustomAppText(
            text: title,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
