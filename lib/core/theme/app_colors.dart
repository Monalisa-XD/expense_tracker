import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Theme Colors (Deep Emerald/Sage Teal & Premium Slate)
  static const Color primaryLight = Color(0xFF0F766E); // Deep Teal
  static const Color onPrimaryLight = Colors.white;
  static const Color primaryContainerLight = Color(0xFFCCFBF1);
  static const Color onPrimaryContainerLight = Color(0xFF115E59);

  static const Color primaryDark = Color(0xFF2DD4BF); // Vibrant Teal/Mint
  static const Color onPrimaryDark = Color(0xFF003732);
  static const Color primaryContainerDark = Color(0xFF0D9488);
  static const Color onPrimaryContainerDark = Color(0xFFF0FDFA);

  // Secondary/Accent (Rose gold/Amber for modern warm accents)
  static const Color secondaryLight = Color(0xFFD97706); // Warm Amber
  static const Color onSecondaryLight = Colors.white;
  static const Color secondaryDark = Color(0xFFFBBF24);
  static const Color onSecondaryDark = Color(0xFF78350F);

  // Neutral Colors (Backgrounds, Cards, Borders)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Very light slate/blue-gray
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle slate borders
  static const Color textPrimaryLight = Color(0xFF0F172A); // Dark slate
  static const Color textSecondaryLight = Color(0xFF64748B); // Muted slate

  static const Color backgroundDark = Color(0xFF0F172A); // Deep Navy Slate
  static const Color surfaceDark = Color(0xFF1E293B); // Rich Dark Slate
  static const Color borderDark = Color(0xFF334155); // Slate borders
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Light Gray
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted Gray

  // Semantic Status Colors (Subtle premium variations)
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444); // Rose/Red
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B); // Yellow
  static const Color info = Color(0xFF3B82F6); // Blue
}
