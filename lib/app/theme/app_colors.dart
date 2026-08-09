import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4438B8);
  static const Color secondary = Color(0xFF2D9CDB);

  // Semantic actions
  static const Color success = Color(0xFF2ECF9F);
  static const Color destructive = Color(0xFFFF5C6C);
  static const Color favorite = Color(0xFFF7B731);

  // Light
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7F0);
  static const Color textPrimaryLight = Color(0xFF171A2B);
  static const Color textSecondaryLight = Color(0xFF6B7085);
  static const Color textDisabledLight = Color(0xFFAEB3C2);

  // Dark
  static const Color backgroundDark = Color(0xFF0E1020);
  static const Color surfaceDark = Color(0xFF181B2D);
  static const Color surfaceElevatedDark = Color(0xFF22263A);
  static const Color borderDark = Color(0xFF30354C);
  static const Color textPrimaryDark = Color(0xFFF5F6FA);
  static const Color textSecondaryDark = Color(0xFFA9AFC3);
  static const Color primaryLight = Color(0xFF8B7CF6);
  static const Color destructiveDark = Color(0xFFFF6B78);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
