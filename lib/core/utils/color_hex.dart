import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Color colorFromHex(String? value) {
  if (value == null || value.length != 7 || !value.startsWith('#')) {
    return AppColors.primary;
  }
  return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
}

String hexFromColor(Color color) {
  final value = color.toARGB32() & 0x00FFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
