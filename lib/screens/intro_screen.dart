import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/screens/main_dashboard_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroItemData> _introItems = [
    IntroItemData(
      stepText: "STEP 01 / 03",
      title: "Master Your Time & Maximize Earnings",
      subtitle:
          "Track work sessions with precision. Automatic overtime detection, real-time earnings tracker, and instant break management.",
      type: IntroMockupType.timer,
    ),
    IntroItemData(
      stepText: "STEP 02 / 03",
      title: "Seamless Client & Shift Management",
      subtitle:
          "Organize multiple projects with custom hourly rates, track client budgets, and maintain detailed historical work logs.",
      type: IntroMockupType.projectsAndLogs,
    ),
    IntroItemData(
      stepText: "STEP 03 / 03",
      title: "Smart Analytics & Instant PDF Reports",
      subtitle:
          "Analyze weekly earnings trends, view overtime insights, and export professional PDF invoices for clients in one tap.",
      type: IntroMockupType.reportsAndPdf,
    ),
  ];

  void _onNext() {
    if (_currentPage < _introItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Get.off(() => const MainDashboardScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: Stack(
        children: [
          // Background ambient ambient glows
          Positioned(
            top: -60.h,
            left: -40.w,
            child: Container(
              width: 240.r,
              height: 240.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 120.h,
            right: -50.w,
            child: Container(
              width: 260.r,
              height: 260.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.05.sp),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header (Logo & Skip)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              gradient: primaryGradient,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.timer_rounded,
                              color: white,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          CustomAppText(
                            text: "Hour Tracker",
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ],
                      ),
                      CustomOpacityWidget(
                        onTap: _navigateToDashboard,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: borderColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomAppText(
                                text: "Skip",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16.sp,
                                color: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView with Custom Layouts per page
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _introItems.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final item = _introItems[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // Feature Visual Layout Canvas
                            Expanded(
                              child: Center(
                                child: _buildPageLayout(item.type),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Step Badge Tag
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: CustomAppText(
                                text: item.stepText,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // Title
                            CustomAppText(
                              text: item.title,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),

                            SizedBox(height: 8.h),

                            // Subtitle
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: CustomAppText(
                                text: item.subtitle,
                                fontSize: 13.sp,
                                color: textSecondary,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                            ),

                            SizedBox(height: 10.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Floating Control Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    children: [
                      // Animated Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _introItems.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 7.h,
                            width: _currentPage == index ? 32.w : 8.w,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? primaryColor
                                  : textMuted.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.5),
                                        blurRadius: 8.r,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Primary Action Next / Get Started Button
                      CustomOpacityWidget(
                        onTap: _onNext,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            gradient: primaryGradient,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 14.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomAppText(
                                text: _currentPage == _introItems.length - 1
                                    ? "Get Started Now"
                                    : "Continue",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                _currentPage == _introItems.length - 1
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: white,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Router for Layouts
  Widget _buildPageLayout(IntroMockupType type) {
    switch (type) {
      case IntroMockupType.timer:
        return _buildPage1TimerLayout();
      case IntroMockupType.projectsAndLogs:
        return _buildPage2ProjectsLayout();
      case IntroMockupType.reportsAndPdf:
        return _buildPage3ReportsLayout();
    }
  }

  // PAGE 1 LAYOUT: Modern Hero Stopwatch Dashboard with Floating Satellite Badges
  Widget _buildPage1TimerLayout() {
    return SizedBox(
      height: 320.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Radial Glow Circle
          Container(
            width: 250.r,
            height: 250.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Central Hero Card
          Container(
            width: 270.w,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20.r,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        CustomAppText(
                          text: "TRACKING ACTIVE",
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: successColor,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.more_horiz_rounded,
                      color: textMuted,
                      size: 18.sp,
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Digital Timer Clock Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: appBgColor,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomAppText(
                        text: "03 : 42 : 18",
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      SizedBox(height: 2.h),
                      CustomAppText(
                        text: "ELAPSED WORK TIME",
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Project & Rate Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppText(
                          text: "Mobile App Redesign",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        CustomAppText(
                          text: "Rate: \$80.00 / hr",
                          fontSize: 11.sp,
                          color: textSecondary,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause_rounded,
                        color: primaryColor,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating Satellite Badge 1 (Top-Right: Live Earnings)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: successColor.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withValues(alpha: 0.25),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    color: successColor,
                    size: 16.sp,
                  ),
                  CustomAppText(
                    text: "\$296.40 Earned",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: successColor,
                  ),
                ],
              ),
            ),
          ),

          // Floating Satellite Badge 2 (Bottom-Left: Overtime Badge)
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: accentColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  CustomAppText(
                    text: "Overtime 1.5x Active",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 2 LAYOUT: Interactive Project Hub & Dynamic Task Chips
  Widget _buildPage2ProjectsLayout() {
    return SizedBox(
      height: 320.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow Aura
          Container(
            width: 260.r,
            height: 260.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Main Hero Project Hub Card
          Container(
            width: 280.w,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.5),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 22.r,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Project Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            gradient: timerGradient,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.dashboard_customize_rounded,
                            color: white,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomAppText(
                              text: "E-Commerce App",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            CustomAppText(
                              text: "Acme Corp • \$95.00/hr",
                              fontSize: 10.sp,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: CustomAppText(
                        text: "ACTIVE",
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Task Chips Section
                CustomAppText(
                  text: "Project Sub-tasks & Shift Items",
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),

                SizedBox(height: 8.h),

                // Task Chip 1
                _buildTaskChip("UI Design Systems", "3.5 hrs", true),
                SizedBox(height: 6.h),
                // Task Chip 2
                _buildTaskChip("Stripe Payment API", "4.0 hrs", true),
                SizedBox(height: 6.h),
                // Task Chip 3
                _buildTaskChip("Client Review Session", "1.0 hr", false),

                SizedBox(height: 12.h),

                // Shift Summary Footer
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: appBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppText(
                        text: "Total Today: 8.5 Hours",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      CustomAppText(
                        text: "\$807.50",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Top-Left Badge (Calendar Shift)
          Positioned(
            top: 5.h,
            left: 5.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  CustomAppText(
                    text: "Calendar Logged",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom-Right Badge (Budget Progress)
          Positioned(
            bottom: 5.h,
            right: 5.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: successColor.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withValues(alpha: 0.25),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pie_chart_rounded,
                    color: successColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  CustomAppText(
                    text: "\$3,240 / \$4k Budget",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: successColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskChip(String name, String time, bool isDone) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: appBgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDone ? successColor.withValues(alpha: 0.3) : borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isDone ? successColor : textMuted,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              CustomAppText(
                text: name,
                fontSize: 11.sp,
                color: textPrimary,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ],
          ),
          CustomAppText(
            text: time,
            fontSize: 10.sp,
            color: textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  // PAGE 3 LAYOUT: Analytics Dashboard Spotlight with Glowing Gradient Chart & Invoice PDF Card
  Widget _buildPage3ReportsLayout() {
    return SizedBox(
      height: 320.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Analytics Container Card
          Container(
            width: 290.w,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20.r,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Revenue Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppText(
                          text: "Monthly Earnings",
                          fontSize: 11.sp,
                          color: textSecondary,
                        ),
                        SizedBox(height: 2.h),
                        CustomAppText(
                          text: "\$3,420.00",
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: successColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: successColor,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          CustomAppText(
                            text: "+22.4%",
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: successColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Chart Bars Representation
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: appBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  height: 90.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGlowingChartBar("W1", 0.45, primaryColor),
                      _buildGlowingChartBar("W2", 0.65, primaryColor),
                      _buildGlowingChartBar("W3", 0.85, accentColor),
                      _buildGlowingChartBar("W4", 1.00, successColor),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // PDF Export Banner Mockup
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.25),
                        accentColor.withValues(alpha: 0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomAppText(
                              text: "PDF Invoice Ready",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            CustomAppText(
                              text: "Export & share with client in 1 tap",
                              fontSize: 10.sp,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.download_rounded,
                        color: successColor,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingChartBar(String label, double heightFactor, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32.w,
          height: 48.h * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        CustomAppText(
          text: label,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
      ],
    );
  }
}

enum IntroMockupType {
  timer,
  projectsAndLogs,
  reportsAndPdf,
}

class IntroItemData {
  final String stepText;
  final String title;
  final String subtitle;
  final IntroMockupType type;

  IntroItemData({
    required this.stepText,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}
