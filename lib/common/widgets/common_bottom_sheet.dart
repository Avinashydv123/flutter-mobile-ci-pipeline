import 'package:flutter/material.dart';
import '../utilities/color_utility.dart';
import '../utilities/text_style_utility.dart';
import '../utilities/text_utility.dart';

class CommonBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool useRootNavigator = false,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor ?? ColorUtility.whiteColor,
      shape:
          shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyleUtility.welcomeTitle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: ColorUtility.secondaryText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Flexible(child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showScrollable<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool useRootNavigator = false,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor ?? ColorUtility.whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyleUtility.welcomeTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: ColorUtility.secondaryText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<int?> showActionSheet(
    BuildContext context, {
    required String title,
    required List<BottomSheetAction> actions,
    String? cancelText,
    bool showCancel = true,
  }) {
    return show<int>(
      context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return ListTile(
              leading: action.icon != null
                  ? Icon(action.icon, color: action.iconColor)
                  : null,
              title: Text(
                action.title,
                style: TextStyleUtility.bodyText.copyWith(
                  color: action.titleColor ?? ColorUtility.primaryText,
                  fontWeight: action.isDestructive ? FontWeight.w600 : null,
                ),
              ),
              onTap: () {
                Navigator.pop(context, index);
                action.onTap?.call();
              },
            );
          }),
          if (showCancel) ...[
            const Divider(),
            ListTile(
              title: Text(
                cancelText ?? TextUtility.cancel,
                style: TextStyleUtility.bodyText.copyWith(
                  color: ColorUtility.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

class BottomSheetAction {
  final String title;
  final IconData? icon;
  final Color? titleColor;
  final Color? iconColor;
  final bool isDestructive;
  final VoidCallback? onTap;

  const BottomSheetAction({
    required this.title,
    this.icon,
    this.titleColor,
    this.iconColor,
    this.isDestructive = false,
    this.onTap,
  });
}
