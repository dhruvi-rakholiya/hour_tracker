import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/utils/app_colors.dart';

/// Reusable AppBar title widget that ensures screen titles never cut off
/// on any device screen or display cutout by providing dedicated horizontal padding,
/// safe auto-scaling (FittedBox), and single-line ellipsis handling.
class ScreenAppBarTitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  const ScreenAppBarTitle({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: CustomAppText(
          text: text,
          fontSize: fontSize ?? 18.sp,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color ?? textPrimary,
          textAlign: textAlign ?? TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
