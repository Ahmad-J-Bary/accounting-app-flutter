import 'package:flutter/material.dart';
import 'package:design_system/src/components/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
  });

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: contentWidget ?? (content != null ? Text(content!) : null),
      actions: [
        if (cancelText != null)
          AppButton(
            text: cancelText!,
            type: AppButtonType.text,
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
          ),
        AppButton(
          text: confirmText ?? 'Confirm',
          type: isDanger ? AppButtonType.danger : AppButtonType.primary,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
