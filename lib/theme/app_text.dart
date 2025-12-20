import 'package:flutter/material.dart';
import 'package:gas_in/theme/app_theme.dart';

/// Helper class for consistent text styling across the app
class AppText {
  // Headings - Poppins
  static TextStyle h1 = AppTheme.heading1;
  static TextStyle h2 = AppTheme.heading2;
  static TextStyle h3 = AppTheme.heading3;
  static TextStyle h4 = AppTheme.heading4;
  static TextStyle h5 = AppTheme.heading5;

  // Body - Open Sans
  static TextStyle bodyL = AppTheme.bodyLarge;
  static TextStyle bodyM = AppTheme.bodyMedium;
  static TextStyle bodyS = AppTheme.bodySmall;

  // Labels
  static TextStyle labelL = AppTheme.labelLarge;
  static TextStyle labelM = AppTheme.labelMedium;

  // Caption
  static TextStyle caption = AppTheme.caption;

  // Button
  static TextStyle button = AppTheme.buttonText;
}
