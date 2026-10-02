import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hour_tracker/utils/app_input_formatters.dart';

void main() {
  group('AppInputFormatters.hour tests', () {
    final formatter = AppInputFormatters.hour(maxHours: 24.0, decimalPlaces: 2);

    TextEditingValue format(String oldText, String newText) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('Allows valid integer hours', () {
      final res = format('', '8');
      expect(res.text, '8');
    });

    test('Allows valid decimal hours', () {
      expect(format('8', '8.').text, '8.');
      expect(format('8.', '8.5').text, '8.5');
      expect(format('8.5', '8.50').text, '8.50');
    });

    test('Blocks multiple dots like 8......9', () {
      // Trying to add a second dot
      expect(format('8.', '8..').text, '8.');
      // Direct paste of corrupted string
      expect(format('', '8......9').text, '');
      expect(format('8', '8.9.1').text, '8');
    });

    test('Blocks letters and symbols', () {
      expect(format('', '8a').text, '');
      expect(format('8', '8-').text, '8');
      expect(format('', '-8').text, '');
      expect(format('', '8,5').text, '');
    });

    test('Blocks values exceeding maxHours (24)', () {
      expect(format('2', '24').text, '24');
      expect(format('24', '24.5').text, '24');
      expect(format('2', '25').text, '2');
      expect(format('', '99').text, '');
    });

    test('Auto-prefixes 0. when user starts with dot', () {
      final res = format('', '.');
      expect(res.text, '0.');
      expect(res.selection.baseOffset, 2);
    });

    test('Blocks more than allowed decimal places (2)', () {
      expect(format('8.25', '8.255').text, '8.25');
    });

    test('Blocks multiple leading zeros', () {
      expect(format('', '0').text, '0');
      expect(format('0', '00').text, '0');
      expect(format('0', '08').text, '0');
      expect(format('0', '0.5').text, '0.5');
    });
  });

  group('AppInputFormatters.multiplier tests', () {
    final formatter = AppInputFormatters.multiplier(maxMultiplier: 10.0);

    TextEditingValue format(String oldText, String newText) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('Allows valid multiplier', () {
      expect(format('', '1.5').text, '1.5');
      expect(format('', '2.0').text, '2.0');
      expect(format('', '10').text, '10');
    });

    test('Rejects multiplier above 10 or multiple dots', () {
      expect(format('1.', '1..5').text, '1.');
      expect(format('', '15').text, '');
    });
  });

  group('AppInputFormatters.rate and minutes tests', () {
    test('Rate allows currency decimal', () {
      final rateFormatter = AppInputFormatters.rate();
      final res = rateFormatter.formatEditUpdate(
        const TextEditingValue(text: '25'),
        const TextEditingValue(text: '25.50'),
      );
      expect(res.text, '25.50');
    });

    test('Minutes allows digits only', () {
      final minutesFormatters = AppInputFormatters.minutes();
      TextEditingValue val = const TextEditingValue(text: '30m');
      for (final f in minutesFormatters) {
        val = f.formatEditUpdate(
          const TextEditingValue(text: ''),
          val,
        );
      }
      expect(val.text, '30');
    });
  });
}
