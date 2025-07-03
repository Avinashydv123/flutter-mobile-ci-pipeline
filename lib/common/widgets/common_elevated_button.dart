import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';

class CommonElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? leadingIcon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const CommonElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = 26,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? ColorUtility.buttonBorderColor,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorUtility.buttonBackground,
          foregroundColor: foregroundColor ?? ColorUtility.primaryText,
          elevation: 0,
          side: BorderSide(
            color: borderColor ?? ColorUtility.buttonBorderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 12),
            ],
            Text(text, style: textStyle ?? TextStyleUtility.buttonText),
          ],
        ),
      ),
    );
  }
}
