import 'package:flutter/material.dart';
import 'color_utility.dart';

class TextStyleUtility {
  // Private constructor
  TextStyleUtility._();

  // Singleton instance
  static final TextStyleUtility _instance = TextStyleUtility._();

  // Getter to access the singleton instance
  static TextStyleUtility get instance => _instance;

  // Heading Styles
  static const TextStyle welcomeTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ColorUtility.primaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: ColorUtility.secondaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  // Button Text Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: ColorUtility.fontFamily,
  );

  // Body Text Styles
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: ColorUtility.secondaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  static const TextStyle linkText = TextStyle(
    color: ColorUtility.linkColor,
    fontFamily: ColorUtility.fontFamily,
  );

  // Small Text Styles
  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    color: ColorUtility.secondaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  // App Bar Title Style
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorUtility.primaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  // Section Title Style
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ColorUtility.primaryText,
    fontFamily: ColorUtility.fontFamily,
  );

  // Action Text Style (for clickable text)
  static const TextStyle actionText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorUtility.primaryColor,
    fontFamily: ColorUtility.fontFamily,
  );
}
