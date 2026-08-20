import 'package:flutter/material.dart';

const white = Color(0xffFFFFFF);
const black = Color(0xff000000);

const Color primaryColor = Color(0xFF6C5CE7);
const Color primaryDark = Color(0xFF4834DF);
const Color primaryLight = Color(0xFFA29BFE);
const Color accentColor = Color(0xFF00CEC9);

const Color appBgColor = Color(0xFFF8F9FE);
const Color cardBgColor = Color(0xFFFFFFFF);
const Color surfaceColor = Color(0xFFF1F5F9);

const Color textPrimary = Color(0xFF1E293B);
const Color textSecondary = Color(0xFF64748B);
const Color textMuted = Color(0xFF94A3B8);

const Color billableColor = Color(0xFF10B981);
const Color nonBillableColor = Color(0xFFF59E0B);
const Color overtimeColor = Color(0xFF8B5CF6);
const Color breakColor = Color(0xFFEC4899);
const Color dangerColor = Color(0xFFEF4444);
const Color successColor = Color(0xFF10B981);

const Color dividerColor = Color(0xFFE2E8F0);
const Color shadowColor = Color(0x1A6C5CE7);

const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF6C5CE7), Color(0xFF4834DF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient timerGradient = LinearGradient(
  colors: [Color(0xFF00CEC9), Color(0xFF6C5CE7)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient billableGradient = LinearGradient(
  colors: [Color(0xFF34D399), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

Color parseColorHex(String? hexString, {Color fallback = primaryColor}) {
  if (hexString == null || hexString.trim().isEmpty) return fallback;
  try {
    String cleanHex = hexString.trim().replaceAll('#', '');
    if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
      cleanHex = cleanHex.substring(2);
    }
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    if (cleanHex.length == 8) {
      final val = int.parse(cleanHex, radix: 16);
      return Color(val);
    }
  } catch (_) {}
  return fallback;
}
