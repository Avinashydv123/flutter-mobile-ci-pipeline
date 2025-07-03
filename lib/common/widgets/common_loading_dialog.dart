import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';

class CommonLoadingDialog {
  static bool _isDialogShowing = false;

  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return PopScope(
          canPop: barrierDismissible,
          child: Dialog(
            backgroundColor: backgroundColor ?? ColorUtility.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      indicatorColor ?? ColorUtility.primaryColor,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyleUtility.bodyText,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  static void hide(BuildContext context) {
    if (_isDialogShowing && Navigator.canPop(context)) {
      Navigator.of(context).pop();
      _isDialogShowing = false;
    }
  }

  static bool get isShowing => _isDialogShowing;
}

class CommonLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? indicatorColor;
  final double? size;

  const CommonLoadingWidget({
    super.key,
    this.message,
    this.indicatorColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                indicatorColor ?? ColorUtility.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyleUtility.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
