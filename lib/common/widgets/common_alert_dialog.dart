import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';
import '../utilities/text_utility.dart';

enum AlertType { success, error, warning, info, confirmation }

class CommonAlertDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    AlertType type = AlertType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) async {
    Color iconColor;
    IconData iconData;

    switch (type) {
      case AlertType.success:
        iconColor = ColorUtility.successColor;
        iconData = Icons.check_circle;
        break;
      case AlertType.error:
        iconColor = ColorUtility.errorColor;
        iconData = Icons.error;
        break;
      case AlertType.warning:
        iconColor = ColorUtility.warningColor;
        iconData = Icons.warning;
        break;
      case AlertType.info:
        iconColor = ColorUtility.infoColor;
        iconData = Icons.info;
        break;
      case AlertType.confirmation:
        iconColor = ColorUtility.primaryColor;
        iconData = Icons.help;
        break;
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorUtility.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(iconData, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyleUtility.welcomeTitle.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(message, style: TextStyleUtility.bodyText),
          actions: [
            if (cancelText != null || type == AlertType.confirmation)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onCancel?.call();
                },
                child: Text(
                  cancelText ?? TextUtility.cancel,
                  style: TextStyleUtility.bodyText.copyWith(
                    color: ColorUtility.secondaryText,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              child: Text(
                confirmText ?? TextUtility.ok,
                style: TextStyleUtility.bodyText.copyWith(
                  color: ColorUtility.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> success(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.success,
      confirmText: confirmText,
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> error(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.error,
      confirmText: confirmText,
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> warning(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.warning,
      confirmText: confirmText,
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> confirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = TextUtility.confirm,
    String cancelText = TextUtility.cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.confirmation,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
