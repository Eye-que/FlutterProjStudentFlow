import 'package:flutter/material.dart';

/// App Colors - Consistent color definitions for StudyFlow
/// Ensures gradients and colors look identical in debug and release builds
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // StudyFlow Brand Colors (consistent across themes)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGreen = Color(0xFF10B981);

  // Gradient Colors (these are fixed and don't change with theme)
  /// Main brand gradient: Blue to Green
  static const List<Color> brandGradient = [
    primaryBlue,
    secondaryGreen,
  ];

  /// Light gradient for cards/backgrounds
  static const List<Color> lightGradient = [
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
  ];

  /// Success gradient
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  /// Warning gradient
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];

  /// Purple gradient
  static const List<Color> purpleGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  /// Get gradient with specified colors
  static LinearGradient getGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }

  /// Get brand gradient (blue to green)
  static LinearGradient getBrandGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return getGradient(
      colors: brandGradient,
      begin: begin,
      end: end,
    );
  }
}

