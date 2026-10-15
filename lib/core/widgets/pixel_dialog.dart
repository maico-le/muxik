import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import 'pixel_widgets.dart';

/// Retro Pixel Dialog with 0-radius, solid border, and pixel buttons
class PixelDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const PixelDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PixelDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'XÁC NHẬN',
    String cancelText = 'HUỶ',
  }) {
    return show<bool>(
      context: context,
      title: title,
      content: Text(message),
      actions: [
        PixelButton(
          isSmall: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        const SizedBox(width: 8),
        PixelButton(
          isSmall: true,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: theme.boxDecoration(
          fillColor: theme.background,
          hasShadow: true,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primary,
                border: Border.all(color: theme.border, width: theme.borderWidth),
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Body Content
            Flexible(
              child: SingleChildScrollView(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: theme.textPrimary,
                    fontSize: 13,
                  ),
                  child: content,
                ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Retro Pixel Switch (toggle)
class PixelSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PixelSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? theme.primary : theme.surface,
          border: Border.all(color: theme.border, width: theme.borderWidth),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(2),
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: value ? Colors.white : theme.border,
          ),
        ),
      ),
    );
  }
}
