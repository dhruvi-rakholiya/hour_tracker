import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/for_ads/utils/app_constants.dart';
import 'package:hour_tracker/screens/privacy_policy_screen.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/screens/premium_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String iosAppId = "";

  void shareAppOnTap() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    showLog(packageName);
    if (Platform.isIOS) {
      final String url = 'https://apps.apple.com/app/id$iosAppId';

      final params = ShareParams(uri: Uri.parse(url));

      await SharePlus.instance.share(params);
    } else {
      final String webUrl =
          'https://play.google.com/store/apps/details?id=$packageName';
      final params = ShareParams(uri: Uri.parse(webUrl));

      await SharePlus.instance.share(params);
    }
  }

  Future<void> submitRating(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    showLog(packageName);
    if (Platform.isIOS) {
      try {
        String appId = iosAppId;
        final InAppReview inAppReview = InAppReview.instance;
        await inAppReview.openStoreListing(appStoreId: appId);
      } catch (e) {
        showLog('Error requesting in-app review: $e');
      }
    } else {
      final String url = 'market://details?id=$packageName';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        final String webUrl =
            'https://play.google.com/store/apps/details?id=$packageName';
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl));
        } else {
          throw 'Could not launch Play Store.';
        }
      }
    }
  }

  /*void _showRateDialog(BuildContext context) {
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
                  child: const CustomAppText(text: "Later", color: textMuted),
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
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 18.sp,
          ),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
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
                          text:
                              "Unlock 100% ad-free experience, unlimited PDF report exports & advanced overtime calculator rules.",
                          fontSize: 12.sp,
                          color: white.withValues(alpha: 0.92),
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
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
                    subtitle:
                        "Tell your colleagues and friends about Hour Tracker",
                    onTap: shareAppOnTap,
                  ),

                  Divider(height: 1.h, color: dividerColor, indent: 56.w),

                  // 2. Rate App
                  _buildSettingTile(
                    icon: Icons.star_rate_rounded,
                    iconColor: Colors.amber,
                    title: "Rate App",
                    subtitle: "Leave a rating or review on the App Store",
                    onTap: () {
                      submitRating(context);
                    },
                  ),

                  Divider(height: 1.h, color: dividerColor, indent: 56.w),

                  // 3. Privacy Policy
                  _buildSettingTile(
                    icon: Icons.privacy_tip_rounded,
                    iconColor: billableColor,
                    title: "Privacy Policy",
                    subtitle: "Read how your data & privacy are protected",
                    onTap: () {
                      Get.to(() => PrivacyPolicyScreen());
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
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
              child: Icon(icon, color: iconColor, size: 20.sp),
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
