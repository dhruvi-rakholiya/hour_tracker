import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/utils/app_colors.dart';

enum PremiumPlanType { yearly, weekly }

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  PremiumPlanType _selectedPlan = PremiumPlanType.yearly;

  void _onSubscribe() {
    AdsVariable.isPurchase = true;
    Get.snackbar(
      "PRO Activated!",
      "Thank you for subscribing to Hour Tracker PRO!",
      backgroundColor: primaryColor,
      colorText: white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.r),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: Stack(
        children: [
          // Ambient App Theme Background Glows
          Positioned(
            top: -50.h,
            left: -40.w,
            child: Container(
              width: 260.r,
              height: 260.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60.h,
            right: -40.w,
            child: Container(
              width: 280.r,
              height: 280.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: primaryColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            CustomAppText(
                              text: "HOUR TRACKER PRO",
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      CustomOpacityWidget(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: textPrimary,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Hero Crown Section
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 22.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 46.sp,
                      color: white,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Title & Subtitle
                  CustomAppText(
                    text: "Unlock Premium Powers",
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 4.h),

                  CustomAppText(
                    text: "Supercharge your productivity with unlimited tracking, PDF exports & ad-free experience.",
                    fontSize: 12.sp,
                    color: textSecondary,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),

                  const Spacer(),

                  // Pro Features List Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 14.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.all_inclusive_rounded, "Unlimited Client Projects & Tasks"),
                        SizedBox(height: 10.h),
                        _buildFeatureRow(Icons.block_rounded, "100% Ad-Free Across All Screens"),
                        SizedBox(height: 10.h),
                        _buildFeatureRow(Icons.picture_as_pdf_rounded, "1-Tap PDF Invoice & Report Export"),
                        SizedBox(height: 10.h),
                        _buildFeatureRow(Icons.bolt_rounded, "Advanced Overtime & Custom Rates"),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Full Width Column Stacked Plan Containers
                  Column(
                    children: [
                      // Plan 1: Yearly Card (Full Width)
                      _buildFullWidthPlanCard(
                        planType: PremiumPlanType.yearly,
                        title: "Yearly Pass",
                        price: "\$29.99 / Year",
                        subPrice: "\$2.49 / Month (Billed Annually)",
                        badgeText: "SAVE 60% • BEST VALUE",
                      ),

                      SizedBox(height: 12.h),

                      // Plan 2: Weekly Card (Full Width)
                      _buildFullWidthPlanCard(
                        planType: PremiumPlanType.weekly,
                        title: "Weekly Pass",
                        price: "\$2.99 / Week",
                        subPrice: "Billed weekly • Cancel anytime",
                        badgeText: null,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Subscribe Action Button (App Primary Gradient)
                  CustomOpacityWidget(
                    onTap: _onSubscribe,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 16.r,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          CustomAppText(
                            text: _selectedPlan == PremiumPlanType.yearly
                                ? "START 3-DAY FREE TRIAL"
                                : "SUBSCRIBE NOW • \$2.99",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  CustomAppText(
                    text: "Auto-renewable. Cancel anytime in App Store settings.",
                    fontSize: 10.5.sp,
                    color: textMuted,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 10.h),

                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFooterLink("Restore"),
                      CustomAppText(text: "•", fontSize: 10.sp, color: textMuted),
                      _buildFooterLink("Privacy Policy"),
                      CustomAppText(text: "•", fontSize: 10.sp, color: textMuted),
                      _buildFooterLink("Terms of Service"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 14.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CustomAppText(
            text: text,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFullWidthPlanCard({
    required PremiumPlanType planType,
    required String title,
    required String price,
    required String subPrice,
    required String? badgeText,
  }) {
    final isSelected = _selectedPlan == planType;

    return CustomOpacityWidget(
      onTap: () {
        setState(() {
          _selectedPlan = planType;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.03)
                  : cardBgColor,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelected ? primaryColor : borderColor,
                width: isSelected ? 2.w : 1.w,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Radio Selection Icon
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? primaryColor : textMuted,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),

                // Title & Details
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
                        text: subPrice,
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),

                // Price Tag
                CustomAppText(
                  text: price,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : textPrimary,
                ),
              ],
            ),
          ),

          // Top Right Highlight Badge
          if (badgeText != null)
            Positioned(
              top: -8.h,
              right: 14.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomAppText(
                  text: badgeText,
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return CustomOpacityWidget(
      onTap: () {},
      child: CustomAppText(
        text: text,
        fontSize: 10.5.sp,
        color: textSecondary,
      ),
    );
  }
}
