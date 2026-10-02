import 'package:flutter/services.dart';

/// Centralized input formatters with robust RegExp validation
/// tailored for hours, currencies, counts, and text inputs across the app.
class AppInputFormatters {
  /// Formatter for hour fields (Daily Goal, Overtime Threshold).
  /// - Only allows digits and at most ONE decimal point
  /// - Supports up to [decimalPlaces] decimal digits (default 2)
  /// - Restricts value to [maxHours] (default 24.0 hours for daily limit)
  /// - Blocks multiple dots (e.g., '8......9', '1..2', '..5')
  /// - Prevents minus signs, commas, letters, spaces
  /// - Auto-prefixes '0.' if user starts by typing '.'
  /// - Rejects multiple leading zeros (e.g. '00', '008')
  static TextInputFormatter hour({
    double maxHours = 24.0,
    int decimalPlaces = 2,
  }) {
    return _DecimalTextInputFormatter(
      max: maxHours,
      decimalRange: decimalPlaces,
    );
  }

  /// Formatter for overtime multiplier (e.g. 1.0x to 10.0x).
  static TextInputFormatter multiplier({
    double maxMultiplier = 10.0,
    int decimalPlaces = 2,
  }) {
    return _DecimalTextInputFormatter(
      max: maxMultiplier,
      decimalRange: decimalPlaces,
    );
  }

  /// Formatter for hourly rates / currency amounts.
  /// - Digits and at most ONE decimal point
  /// - Up to 2 decimal places
  /// - Max rate up to 999,999.0
  static TextInputFormatter rate({
    double maxRate = 999999.0,
    int decimalPlaces = 2,
  }) {
    return _DecimalTextInputFormatter(
      max: maxRate,
      decimalRange: decimalPlaces,
    );
  }

  /// Formatter for project total target hours.
  /// - Allows up to 99,999 hours with 2 decimal places
  static TextInputFormatter projectHours({
    double maxHours = 99999.0,
    int decimalPlaces = 2,
  }) {
    return _DecimalTextInputFormatter(
      max: maxHours,
      decimalRange: decimalPlaces,
    );
  }

  /// Formatter for break duration in minutes (integer only).
  /// - Digits only
  /// - Maximum [maxDigits] digits (default 4, up to 9999 mins)
  static List<TextInputFormatter> minutes({int maxDigits = 4}) {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxDigits),
    ];
  }

  /// Formatter for single-line text fields (Project Name, Client Name, Task Name).
  /// - Denies leading spaces
  /// - Limits length to [maxLength]
  static List<TextInputFormatter> singleLineText({int maxLength = 60}) {
    return [
      FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  /// Formatter for notes / description fields.
  static List<TextInputFormatter> notes({int maxLength = 500}) {
    return [
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }
}

/// Internal decimal formatter that uses strict regular expressions and numerical bounds.
class _DecimalTextInputFormatter extends TextInputFormatter {
  final double? max;
  final int decimalRange;

  _DecimalTextInputFormatter({
    this.max,
    this.decimalRange = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow deleting / empty text
    if (text.isEmpty) {
      return newValue;
    }

    // Auto-convert single dot '.' to '0.'
    if (text == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    // Strict regex:
    // ^\d*(\.\d{0,decimalRange})?$
    // Disallows multiple dots (e.g. '8......9'), letters, symbols, negative signs
    final regEx = RegExp('^\\d*\\.?\\d{0,$decimalRange}\$');
    if (!regEx.hasMatch(text)) {
      return oldValue;
    }

    // Disallow multiple leading zeroes like '00', '008', but allow '0' and '0.xx'
    if (text.length > 1 && text.startsWith('0') && !text.startsWith('0.')) {
      return oldValue;
    }

    // Check maximum boundary if specified
    if (max != null) {
      final parsed = double.tryParse(text);
      if (parsed != null && parsed > max!) {
        return oldValue;
      }
    }

    return newValue;
  }
}
