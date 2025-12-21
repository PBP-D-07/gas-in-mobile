import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Text Styles - Headings (Poppins)
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF1A1A2E),
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF1A1A2E),
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF1A1B4B),
  );

  static TextStyle heading4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1B4B),
  );

  static TextStyle heading5 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1A1B4B),
  );

  // Text Styles - Body (Open Sans)
  static TextStyle bodyLarge = GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF333333),
  );

  static TextStyle bodyMedium = GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF333333),
  );

  static TextStyle bodySmall = GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF666666),
  );

  // Text Styles - Label/Button
  static TextStyle labelLarge = GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle labelMedium = GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Text Styles - Caption/Helper
  static TextStyle caption = GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF999999),
  );

  // Button Text Style
  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Get theme data
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'OpenSans',
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        headlineSmall: heading3,
        titleLarge: heading4,
        titleMedium: heading5,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      ),
    );
  }
}
