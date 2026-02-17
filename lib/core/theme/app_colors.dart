import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const primary = Color(0xFF2563EB); // Royal Blue
  static const primaryDark = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFF60A5FA);

  // Main Background - darker than before
  static const deepNavy = Color(0xFF050810);

  // Card Surfaces
  static const cardSurface =
      Color(0xFF101522); // For "Rank Faster" and "Your Progress" cards

  // Accents
  static const accentCyan = Color(0xFF67E8F9); // "Your next achievement..."
  static const accentGreen =
      Color(0xFF34D399); // "+50 Points", "+12% this week"
  static const accentOrange = Color(0xFFFBBF24); // "Boost Your Score"
  static const accentPurple = Color(0xFFA78BFA); // "Collab Now"
  static const accentBlue = Color(0xFF3B82F6); // Primary Blue

  // Gradients
  static const reputationGradientStart =
      Color(0xFF2563EB); // Brighter Blue start
  static const reputationGradientEnd = Color(0xFF1E3A8A); // Darker Blue end

  // Aliases for compatibility
  static const secondary = accentGreen;
  static const tertiary = accentPurple;
  static const error = Color(0xFFEF4444);
  static const warning = accentOrange;
  static const surfaceDark = cardSurface;
  static const surfaceLighter = Color(
      0xFF1F2937); // Keeping original lighter for some elements? Or map to cardSurface? Let's keep it distinct for now.

  // Neutral
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral700 = Color(0xFF374151);
  static const neutral900 = Color(0xFF111827);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const textLight = Color(0xFFF9FAFB); // White/Off-white for dark mode

  // Light Mode Colors (Screenshot)
  static const lightBackground = Color(0xFFF1F5F9); // Very light blue-grey
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF111827); // Almost black
  static const lightTextSecondary = Color(0xFF6B7280); // Grey
  static const lightCardShadow = Color(0x0D000000); // Very subtle shadow
  static const lightPrimary = Color(0xFF0EA5E9); // Sky Blue / Cyan (Ask AI)
}
