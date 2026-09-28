import 'package:flutter/material.dart';

/// Design tokens based on BookMind Color Guide and Visual Identity.
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryCoffee = Color(0xFF6B4E3D);
  static const Color primaryTerracotta = Color(0xFFD97757);
  static const Color primaryCream = Color(0xFFF8EEDD);

  // Neutral Colors
  static const Color n900 = Color(0xFF1A1A1A); // Teks utama
  static const Color n700 = Color(0xFF4A4A4A); // Teks sekunder
  static const Color n500 = Color(0xFF7A7A7A); // Teks tersier
  static const Color n300 = Color(0xFFC9C9C9); // Garis / border
  static const Color n200 = Color(0xFFE9E9E9); // Background sekunder
  static const Color n100 = Color(0xFFFAFAF8); // Background utama

  // Semantic Colors
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color active = Color(0xFF8B5CF6);

  // Supporting Colors
  static const Color sand = Color(0xFFF3E8D6);
  static const Color peach = Color(0xFFFDE2D9);
  static const Color blush = Color(0xFFFAD4E1);
  static const Color lavender = Color(0xFFEDE9FE);
  static const Color sky = Color(0xFFE0F2FE);
  static const Color slate = Color(0xFFE2E8F0);

  // Highlight Colors
  static const Color highlightYellow = Color(0xFFFEF08A);
  static const Color highlightGreen = Color(0xFFBBF7D0);
  static const Color highlightBlue = Color(0xFFBAE6FD);
  static const Color highlightPeach = Color(0xFFFED7AA);

  // Gradients
  static const LinearGradient coffeeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B4E3D), Color(0xFFA67C52)],
  );

  static const LinearGradient terracottaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97757), Color(0xFFF4A07A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBF5), Color(0xFFF8EEDD)],
  );
}
