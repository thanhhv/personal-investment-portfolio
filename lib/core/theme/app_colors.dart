import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF00C896);
  static const Color secondary = Color(0xFF2E6FF3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Semantic
  static const Color profit = Color(0xFF00C896);
  static const Color loss = Color(0xFFFF4757);
  static const Color neutral = Color(0xFF8E9AAE);

  // Surfaces - Light
  static const Color surfaceLight = Color(0xFFF8FAFB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF0F4F8);

  // Surfaces - Dark
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF242938);
  static const Color backgroundDark = Color(0xFF131720);

  // Category accents
  static const Color cryptoAccent = Color(0xFFF7931A);
  static const Color stockAccent = Color(0xFF2E6FF3);
  static const Color fundAccent = Color(0xFF8B5CF6);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color realEstateAccent = Color(0xFF10B981);
  static const Color savingsAccent = Color(0xFF00C896);
  static const Color lendingAccent = Color(0xFFFF6B6B);
  static const Color otherAccent = Color(0xFF8E9AAE);

  // Border / divider
  static const Color dividerLight = Color(0xFFE8EDF2);
  static const Color dividerDark = Color(0xFF2A3142);
}
