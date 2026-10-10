import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Exact typography hierarchy specified in Stitch design tokens.
class AppTextStyles {
  AppTextStyles._();

  // --- Display & Headlines (Manrope) ---
  static TextStyle displayLg = GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.64,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.36,
    letterSpacing: -0.22,
    color: AppColors.onSurface,
  );

  static TextStyle titleMd = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.09,
    color: AppColors.onSurface,
  );

  // --- Body, Labels & Captions (Hanken Grotesk) ---
  static TextStyle bodyLg = GoogleFonts.hankenGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.53,
    letterSpacing: -0.085,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.hankenGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.46,
    color: AppColors.onSurface,
  );

  static TextStyle labelMd = GoogleFonts.hankenGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: 0.26,
    color: AppColors.onSurface,
  );

  static TextStyle captionSm = GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.22,
    color: AppColors.onSurfaceVariant,
  );
}
