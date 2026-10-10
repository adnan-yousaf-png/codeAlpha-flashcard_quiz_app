import 'package:flutter/material.dart';

/// Exact color palette extracted from Stitch "FlashLearn Tactile" design system.
class AppColors {
  AppColors._();

  // Primary Violet Palette
  static const Color primary = Color(0xFF6B38D4);
  static const Color primaryContainer = Color(0xFF8455EF);
  static const Color primaryFixed = Color(0xFFE9DDFF);
  static const Color onPrimaryFixed = Color(0xFF23005C);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary Indigo Palette
  static const Color secondary = Color(0xFF4B41E1);
  static const Color secondaryContainer = Color(0xFF645EFB);
  static const Color secondaryFixed = Color(0xFFE2DFFF);
  static const Color onSecondaryFixed = Color(0xFF0F0069);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary Emerald Palette
  static const Color tertiary = Color(0xFF006B2D);
  static const Color tertiaryContainer = Color(0xFF00873B);
  static const Color tertiaryFixed = Color(0xFF6BFF8F);
  static const Color onTertiaryFixed = Color(0xFF002109);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface & Canvas Neutrals
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);

  // Content Typography Neutrals
  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF494454);
  static const Color outline = Color(0xFF7B7486);
  static const Color outlineVariant = Color(0xFFCBC3D7);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Functional & Error Feedback
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);

  // Rating Button Custom Backgrounds
  static const Color ratingAgainBg = Color(0xFFFFDAD6);
  static const Color ratingHardBg = Color(0xFFDEE8FF);
  static const Color ratingGoodBg = Color(0xFFE7EEFF);
  static const Color ratingEasyBg = Color(0xFF6BFF8F);

  // Shadows
  static const List<BoxShadow> ambientCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(30, 41, 59, 0.03),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color.fromRGBO(107, 56, 212, 0.06),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> floatingCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(30, 41, 59, 0.08),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color.fromRGBO(107, 56, 212, 0.12),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
