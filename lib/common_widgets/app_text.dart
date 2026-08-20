import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:hour_tracker/utils/app_colors.dart';

class CustomAppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final Paint? foreground;
  final TextDecoration? textDecoration;
  final List<Shadow>? shadows;
  final double? letterSpacing;
  final Color? decorationColor;

  final TextOverflow? overflow;

  const CustomAppText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.color,
    this.maxLines,
    this.textAlign,
    this.textDecoration,
    this.fontStyle,
    this.foreground,
    this.shadows,
    this.letterSpacing,
    this.decorationColor,
    this.overflow,
  });


  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: true,
      style: TextStyle(
        color: color ?? textPrimary,
        fontSize: fontSize ?? 14.sp,
        fontWeight: fontWeight ?? FontWeight.w500,
        fontFamily: fontFamily,
        fontStyle: fontStyle,
        shadows: shadows,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
        decorationColor: decorationColor,
        foreground: foreground,
      ),
    );
  }
}


class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.gradient, this.style});

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text.tr, style: style),
    );
  }
}
