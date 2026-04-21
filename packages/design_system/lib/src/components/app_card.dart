import 'package:flutter/material.dart';
import 'package:design_system/src/colors/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final String? title;
  final Widget? trailing;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.leading,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: backgroundColor ?? AppColors.surface,
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || leading != null)
              Row(
                children: [
                  if (leading != null) leading!,
                  if (title != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            if (title != null || leading != null) const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}
