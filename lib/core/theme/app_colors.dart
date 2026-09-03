import 'package:flutter/material.dart';

/// Color system (section 7 of the design spec).
class AppColors {
  AppColors._();

  // Light theme
  static const Color lightBackground = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF4C5FD5);
  static const Color lightSecondary = Color(0xFF2FB5A6);
  static const Color lightTextPrimary = Color(0xFF23232B);
  static const Color lightTextSecondary = Color(0xFF6B6B76);
  static const Color lightBorder = Color(0xFFE4E4EA);

  // Dark theme
  static const Color darkBackground = Color(0xFF12131A);
  static const Color darkSurface = Color(0xFF1B1D27);
  static const Color darkPrimary = Color(0xFF7C8CF0);
  static const Color darkSecondary = Color(0xFF3FCDBC);
  static const Color darkTextPrimary = Color(0xFFF2F2F5);
  static const Color darkTextSecondary = Color(0xFFA0A0AC);
  static const Color darkBorder = Color(0xFF2C2E3B);

  // Semantic
  static const Color success = Color(0xFF34B37E);
  static const Color error = Color(0xFFE0555A);
  static const Color warning = Color(0xFFE0A93F);
}
