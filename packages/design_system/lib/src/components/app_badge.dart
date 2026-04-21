import 'package:flutter/material.dart';
import 'package:design_system/src/colors/app_colors.dart';

enum AppBadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeType type;
  final double? fontSize;

  const AppBadge({
    super.key,
    required this.text,
    required this.type,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case AppBadgeType.success:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case AppBadgeType.warning:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case AppBadgeType.error:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case AppBadgeType.info:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case AppBadgeType.neutral:
        backgroundColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
