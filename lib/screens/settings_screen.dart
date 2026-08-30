import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/screens/premium_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _shareApp() {
    Share.share(
      'Track your work hours, calculate earnings & export PDF reports effortlessly with ${AppStrings.appName}! Download now.',
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        _showRateDialog(context);
      }
    } catch (_) {
      _showRateDialog(context);
    }
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedStars = 5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 36.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const CustomAppText(
                    text: "Enjoying Hour Tracker?",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomAppText(
                    text: "Tap a star to rate your experience on the App Store",
                    fontSize: 13,
                    color: textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < selectedStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const CustomAppText(
                    text: "Later",
                    color: textMuted,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      "Thank You!",
                      "We appreciate your rating and support!",
                      backgroundColor: primaryColor,
                      colorText: white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const CustomAppText(
                    text: "Submit Rating",
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: dividerColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.privacy_tip_rounded,
                            color: primaryColor,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          CustomAppText(
                            text: "Privacy Policy",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: textMuted),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  Divider(height: 20.h, color: dividerColor),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        CustomAppText(
                          text: "Your Privacy Matters",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomAppText(
                          text:
                              "Hour Tracker values your privacy above all else. This application operates with an offline-first architecture to ensure your data stays safe and secure on your local device.",
                          fontSize: 13.sp,
                          color: textSecondary,
                        ),
                        SizedBox(height: 16.h),
                        CustomAppText(
                          text: "1. Data Collection & Storage",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 6.h),
                        CustomAppText(
                          text:
                              "All project details, work shifts, duration logs, and hourly rate calculations are stored locally in SQLite on your device. No personal time log data is uploaded to external servers.",
                          fontSize: 12.5.sp,
                          color: textSecondary,
                        ),
                        SizedBox(height: 16.h),
                        CustomAppText(
                          text: "2. Advertising & Analytics",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 6.h),
                        CustomAppText(
                          text:
                              "We use Google AdMob to deliver banner and interstitial advertisements. Non-identifiable device identifiers may be processed in compliance with GDPR and App Tracking Transparency guidelines to optimize ad performance.",
                          fontSize: 12.5.sp,
                          color: textSecondary,
                        ),
                        SizedBox(height: 16.h),
                        CustomAppText(
                          text: "3. In-App Purchases",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 6.h),
                        CustomAppText(
                          text:
                              "Subscribing to Hour Tracker PRO unlocks an ad-free environment and PDF export features. Store transactions are securely handled by Apple App Store and Google Play Store payment systems.",
                          fontSize: 12.5.sp,
                          color: textSecondary,
                        ),
                        SizedBox(height: 24.h),
                        Center(
                          child: CustomAppText(
                            text: "Last Updated: August 2026 • Hour Tracker Team",
                            fontSize: 11.sp,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        title: CustomAppText(
          text: "Settings",
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-Premium PRO Banner Card with app primary theme gradient background
            CustomOpacityWidget(
              onTap: () => Get.to(() => const PremiumScreen()),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Stack(
                  children: [
                    // Ambient Background Decorative Circle
                    Positioned(
                      right: -20.w,
                      top: -20.h,
                      child: Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: white,
                                size: 26.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: CustomAppText(
                                text: "PRO UNLOCKED",
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        CustomAppText(
                          text: "Upgrade to Hour Tracker PRO",
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                        SizedBox(height: 4.h),
                        CustomAppText(
                          text: "Unlock 100% ad-free experience, unlimited PDF report exports & advanced overtime calculator rules.",
                          fontSize: 12.sp,
                          color: white.withValues(alpha: 0.92),
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomAppText(
                                text: "Explore PRO Features",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: primaryColor,
                                size: 14.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Section Label
            CustomAppText(
              text: "GENERAL & OPTIONS",
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: textMuted,
            ),

            SizedBox(height: 10.h),

            // Options List Card Container
            Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // 1. Share App
                  _buildSettingTile(
                    icon: Icons.share_rounded,
                    iconColor: primaryColor,
                    title: "Share App",
                    subtitle: "Tell your colleagues and friends about Hour Tracker",
                    onTap: _shareApp,
                  ),

                  Divider(height: 1.h, color: dividerColor, indent: 56.w),

                  // 2. Rate App
                  _buildSettingTile(
                    icon: Icons.star_rate_rounded,
                    iconColor: Colors.amber,
                    title: "Rate App",
                    subtitle: "Leave a rating or review on the App Store",
                    onTap: () => _rateApp(context),
                  ),

                  Divider(height: 1.h, color: dividerColor, indent: 56.w),

                  // 3. Privacy Policy
                  _buildSettingTile(
                    icon: Icons.privacy_tip_rounded,
                    iconColor: billableColor,
                    title: "Privacy Policy",
                    subtitle: "Read how your data & privacy are protected",
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // App Version Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppText(
                          text: AppStrings.appName,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 2.h),
                        CustomAppText(
                          text: "Version 1.0.0 (Build 1) • Premium Edition",
                          fontSize: 11.sp,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomOpacityWidget(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppText(
                    text: title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  SizedBox(height: 2.h),
                  CustomAppText(
                    text: subtitle,
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textMuted,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
