import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration matching BookMind editorial aesthetic.
class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.lora(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.n900,
        height: 1.25,
      );

  static TextStyle get displayMedium => GoogleFonts.lora(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.n900,
        height: 1.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.lora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.n900,
        height: 1.35,
      );

  static TextStyle get headlineMedium => GoogleFonts.lora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.n900,
        height: 1.4,
      );

  static TextStyle get quoteText => GoogleFonts.lora(
        fontSize: 15,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: AppColors.n900,
        height: 1.5,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.n900,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.n900,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: AppColors.n700,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.n700,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.n500,
      );
}
