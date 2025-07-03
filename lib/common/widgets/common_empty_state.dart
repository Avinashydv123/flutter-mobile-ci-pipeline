import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';
import '../utilities/text_utility.dart';

class CommonEmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final IconData? iconData;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customButton;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const CommonEmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconData,
    this.buttonText,
    this.onButtonPressed,
    this.customButton,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  const CommonEmptyState.noData({
    super.key,
    this.title = TextUtility.noDataTitle,
    this.subtitle = TextUtility.noDataSubtitle,
    this.icon,
    this.iconData = Icons.inbox_outlined,
    this.buttonText,
    this.onButtonPressed,
    this.customButton,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  const CommonEmptyState.noResults({
    super.key,
    this.title = TextUtility.noResultsTitle,
    this.subtitle = TextUtility.noResultsSubtitle,
    this.icon,
    this.iconData = Icons.search_off,
    this.buttonText,
    this.onButtonPressed,
    this.customButton,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  const CommonEmptyState.noConnection({
    super.key,
    this.title = TextUtility.noConnectionTitle,
    this.subtitle = TextUtility.noConnectionSubtitle,
    this.icon,
    this.iconData = Icons.wifi_off,
    this.buttonText = TextUtility.retry,
    this.onButtonPressed,
    this.customButton,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  const CommonEmptyState.error({
    super.key,
    this.title = TextUtility.errorTitle,
    this.subtitle = TextUtility.errorSubtitle,
    this.icon,
    this.iconData = Icons.error_outline,
    this.buttonText = TextUtility.retry,
    this.onButtonPressed,
    this.customButton,
    this.iconSize = 80,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (icon != null)
              icon!
            else if (iconData != null)
              Icon(
                iconData!,
                size: iconSize,
                color: iconColor ?? ColorUtility.secondaryText,
              ),

            const SizedBox(height: 24),

            // Title
            if (title != null)
              Text(
                title!,
                style: TextStyleUtility.welcomeTitle.copyWith(
                  fontSize: 20,
                  color: ColorUtility.primaryText,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 8),

            // Subtitle
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyleUtility.bodyText.copyWith(
                  color: ColorUtility.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 32),

            // Button
            if (customButton != null)
              customButton!
            else if (buttonText != null && onButtonPressed != null)
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtility.primaryColor,
                  foregroundColor: ColorUtility.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: TextStyleUtility.buttonText.copyWith(
                    color: ColorUtility.whiteColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CommonErrorState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onRetry;
  final Widget? customAction;

  const CommonErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onRetry,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return CommonEmptyState(
      title: title ?? TextUtility.errorStateTitle,
      subtitle: subtitle ?? TextUtility.errorStateSubtitle,
      iconData: Icons.error_outline,
      iconColor: ColorUtility.errorColor,
      buttonText: buttonText ?? TextUtility.tryAgain,
      onButtonPressed: onRetry,
      customButton: customAction,
    );
  }
}
