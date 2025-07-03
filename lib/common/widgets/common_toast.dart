import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';

enum ToastType { success, error, warning, info }

class CommonToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    Color backgroundColor;
    Color textColor = ColorUtility.whiteColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        backgroundColor = ColorUtility.successColor;
        iconData = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = ColorUtility.errorColor;
        iconData = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = ColorUtility.warningColor;
        iconData = Icons.warning;
        break;
      case ToastType.info:
        backgroundColor = ColorUtility.infoColor;
        iconData = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyleUtility.bodyText.copyWith(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }
}
