import 'package:flutter/material.dart';

/// Design tokens and colors matching the Modern Material Utility design system in DESIGN.md
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF004AC6); // Technical Blue
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Accent
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);

  // Secondary
  static const Color secondary = Color(0xFF505F76);
  static const Color secondaryContainer = Color(0xFFD0E1FB);
  static const Color onSecondaryContainer = Color(0xFF54647A);
  static const Color secondaryLight = Color(0xFFEFF6FF);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF9F9FF);
  static const Color canvasBg = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F3FF);
  static const Color surfaceContainer = Color(0xFFE9EDFF);
  static const Color surfaceContainerHigh = Color(0xFFE1E8FD);
  static const Color surfaceContainerHighest = Color(0xFFDCE2F7);

  // Typography / Neutral
  static const Color onSurface = Color(0xFF141B2B);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFE2E8F0);
  static const Color outlineBorder = Color(0xFFC3C6D7);

  // Tertiary / Success
  static const Color tertiary = Color(0xFF006329);
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFC7FFCA);

  // Error / PDF Badge
  static const Color error = Color(0xFFBA1A1A);
  static const Color pdfRed = Color(0xFFE11D48);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.05),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.03),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Color.fromRGBO(37, 99, 235, 0.28),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
