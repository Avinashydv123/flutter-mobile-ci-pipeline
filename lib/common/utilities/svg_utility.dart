import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  final String icon;
  final Size? iconSize;
  final Alignment? alignment;
  final Color? iconColor;
  final BoxFit? fit;
  final BlendMode? blendMode;

  const SvgImage({
    super.key,
    required this.icon,
    this.iconSize,
    this.alignment,
    this.iconColor,
    this.fit,
    this.blendMode,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      height: iconSize?.height,
      width: iconSize?.width,
      fit: fit ?? BoxFit.contain,
      alignment: alignment ?? Alignment.center,
      colorFilter: (iconColor != null)
          ? ColorFilter.mode(iconColor!, blendMode ?? BlendMode.srcIn)
          : null,
    );
  }
}
