import 'package:flutter/material.dart';

/// A centralized class for app theming and styling.
/// 
/// This allows for easy modification of colors and styles across the entire app
/// from a single location.
class AppTheme {
  /// Private constructor to prevent instantiation
  AppTheme._();
  
  // App-wide colors
  static final Color primaryColor = Colors.blue.shade700;
  static final Color secondaryColor = Colors.teal.shade600;
  static const Color backgroundColor = Colors.white;
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Colors.black87;
  static final Color errorColor = Colors.red.shade700;
  
  // Feature-specific colors (makes it easy to have different colors per feature)
  static final Map<String, Color> featureColors = {
    'home': primaryColor,
    'clients': Colors.green.shade700,
    'vehicles': Colors.orange.shade700,
    'appointments': Colors.blue.shade700,
    'quotations': Colors.indigo.shade600,
    'settings': Colors.purple.shade700,
    // Add more features as needed
  };
  
  // Get color for a specific feature (falls back to primaryColor if not defined)
  static Color getFeatureColor(String feature) {
    return featureColors[feature] ?? primaryColor;
  }
  
  // AppBar styling
  static const double appBarElevation = 3.0;
  static const double appBarBottomRadius = 16.0;
  static const TextStyle appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  
  // Button styling
  static const double buttonElevation = 3.0;
  static const double buttonBorderRadius = 16.0;
  
  // Card styling
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Spacing values
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
}
