import 'package:flutter/services.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue.copyWith(text: '');
    final cleaned = raw.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = cleaned.split('.');
    final intPart = _addCommas(parts[0]);
    final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _addCommas(String s) {
    if (s.isEmpty) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
