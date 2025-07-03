import 'package:flutter/material.dart';

class ColorUtility {
  // Private constructor
  ColorUtility._();

  // Singleton instance
  static final ColorUtility _instance = ColorUtility._();

  // Getter to access the singleton instance
  static ColorUtility get instance => _instance;

  // PRIMARY COLORS (Orange/Red tones) - Brand Colors
  static const Color primary50 = Color(0xFFFDF2F2);
  static const Color primary100 = Color(0xFFFCE4E4);
  static const Color primary200 = Color(0xFFFAC5C5);
  static const Color primary300 = Color(0xFFF87171);
  static const Color primary400 = Color(0xFFF56565);
  static const Color primary500 = Color(0xFFEF4444); // Main brand color
  static const Color primary600 = Color(0xFFDC2626);
  static const Color primary700 = Color(0xFFB91C1C);
  static const Color primary800 = Color(0xFF991B1B);
  static const Color primary900 = Color(0xFF7F1D1D);

  // NEUTRAL COLORS (Gray tones) - Text and backgrounds
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // SUCCESS COLORS (Green tones) - Success states
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFFBBF7D0);
  static const Color success300 = Color(0xFF86EFAC);
  static const Color success400 = Color(0xFF4ADE80);
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);
  static const Color success700 = Color(0xFF15803D);
  static const Color success800 = Color(0xFF166534);
  static const Color success900 = Color(0xFF14532D);

  // WARNING COLORS (Yellow/Orange tones) - Warning states
  static const Color warning50 = Color(0xFFFEFCE8);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFFCD34D);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning700 = Color(0xFFB45309);
  static const Color warning800 = Color(0xFF92400E);
  static const Color warning900 = Color(0xFF78350F);

  // DESTRUCTIVE COLORS (Red tones) - Error and destructive actions
  static const Color destructive50 = Color(0xFFFEF2F2);
  static const Color destructive100 = Color(0xFFFEE2E2);
  static const Color destructive200 = Color(0xFFFECACA);
  static const Color destructive300 = Color(0xFFFCA5A5);
  static const Color destructive400 = Color(0xFFF87171);
  static const Color destructive500 = Color(0xFFEF4444);
  static const Color destructive600 = Color(0xFFDC2626);
  static const Color destructive700 = Color(0xFFB91C1C);
  static const Color destructive800 = Color(0xFF991B1B);
  static const Color destructive900 = Color(0xFF7F1D1D);

  // SEMANTIC COLORS - Easy access for common use cases
  static const Color backgroundColor = neutral50;
  static const Color primaryText = neutral900;
  static const Color secondaryText = neutral600;
  static const Color tertiaryText = neutral400;
  static const Color borderColor = neutral200;
  static const Color linkColor = primary500;
  static const Color dividerColor = neutral100;

  // BUTTON COLORS
  static const Color buttonBackground = Colors.white;
  static const Color buttonForeground = neutral700;
  static const Color buttonBorderColor = neutral300;
  static const Color primaryButtonBackground = primary500;
  static const Color primaryButtonForeground = Colors.white;

  // STATE COLORS - For common UI states
  static const Color primaryColor = primary500;
  static const Color successColor = success500;
  static const Color errorColor = destructive500;
  static const Color warningColor = warning500;
  static const Color infoColor = primary400;

  // BASIC COLORS
  static const Color blackColor = neutral900;
  static const Color whiteColor = Colors.white;
  static const Color transparentColor = Colors.transparent;

  // SURFACE COLORS
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color overlayColor = Color(0x80000000); // 50% black overlay

  // FONT FAMILY
  static const String fontFamily = 'PlusJakartaSans';

  // HELPER METHODS for getting color variations
  static Color getPrimaryShade(int shade) {
    switch (shade) {
      case 50:
        return primary50;
      case 100:
        return primary100;
      case 200:
        return primary200;
      case 300:
        return primary300;
      case 400:
        return primary400;
      case 500:
        return primary500;
      case 600:
        return primary600;
      case 700:
        return primary700;
      case 800:
        return primary800;
      case 900:
        return primary900;
      default:
        return primary500;
    }
  }

  static Color getNeutralShade(int shade) {
    switch (shade) {
      case 50:
        return neutral50;
      case 100:
        return neutral100;
      case 200:
        return neutral200;
      case 300:
        return neutral300;
      case 400:
        return neutral400;
      case 500:
        return neutral500;
      case 600:
        return neutral600;
      case 700:
        return neutral700;
      case 800:
        return neutral800;
      case 900:
        return neutral900;
      default:
        return neutral500;
    }
  }

  static Color getSuccessShade(int shade) {
    switch (shade) {
      case 50:
        return success50;
      case 100:
        return success100;
      case 200:
        return success200;
      case 300:
        return success300;
      case 400:
        return success400;
      case 500:
        return success500;
      case 600:
        return success600;
      case 700:
        return success700;
      case 800:
        return success800;
      case 900:
        return success900;
      default:
        return success500;
    }
  }

  static Color getWarningShade(int shade) {
    switch (shade) {
      case 50:
        return warning50;
      case 100:
        return warning100;
      case 200:
        return warning200;
      case 300:
        return warning300;
      case 400:
        return warning400;
      case 500:
        return warning500;
      case 600:
        return warning600;
      case 700:
        return warning700;
      case 800:
        return warning800;
      case 900:
        return warning900;
      default:
        return warning500;
    }
  }

  static Color getDestructiveShade(int shade) {
    switch (shade) {
      case 50:
        return destructive50;
      case 100:
        return destructive100;
      case 200:
        return destructive200;
      case 300:
        return destructive300;
      case 400:
        return destructive400;
      case 500:
        return destructive500;
      case 600:
        return destructive600;
      case 700:
        return destructive700;
      case 800:
        return destructive800;
      case 900:
        return destructive900;
      default:
        return destructive500;
    }
  }
}
