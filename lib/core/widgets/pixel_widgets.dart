import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

/// Retro Pixel Button with hard border and stepped press effect
class PixelButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final bool isPrimary;
  final bool isSmall;

  const PixelButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isPrimary = false,
    this.isSmall = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final enabled = widget.onPressed != null;

    final bgColor = !enabled
        ? Colors.grey.shade400
        : (widget.backgroundColor ??
            (widget.isPrimary ? theme.primary : theme.surface));

    final effectivePadding = widget.isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : widget.padding;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: Duration.zero, // Stepped instant response
        margin: EdgeInsets.only(
          top: _isPressed ? theme.shadowOffset : 0,
          left: _isPressed ? theme.shadowOffset : 0,
          right: _isPressed ? 0 : theme.shadowOffset,
          bottom: _isPressed ? 0 : theme.shadowOffset,
        ),
        padding: effectivePadding,
        decoration: theme.boxDecoration(
          fillColor: bgColor,
          pressed: _isPressed,
          hasShadow: enabled && !_isPressed,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: widget.isSmall ? 12 : 14,
            color: widget.textColor ??
                (widget.isPrimary ? Colors.white : theme.textPrimary),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Retro Pixel Card with 0-radius and offset shadow
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasShadow;

  const PixelCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    final content = Container(
      padding: padding,
      decoration: theme.boxDecoration(
        fillColor: backgroundColor ?? theme.surface,
        hasShadow: hasShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

/// Stepped Pixel Progress Bar (discrete blocks or hard rectangular bar)
class PixelProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? barColor;
  final Color? backgroundColor;
  final int? segments; // If provided, renders discrete 8-bit block chunks

  const PixelProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.barColor,
    this.backgroundColor,
    this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final clampedValue = value.clamp(0.0, 1.0);
    final activeColor = barColor ?? theme.primary;
    final bgColor = backgroundColor ?? theme.surface;

    if (segments != null && segments! > 0) {
      final activeSegments = (clampedValue * segments!).round();
      return Container(
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: theme.border, width: theme.borderWidth),
        ),
        child: Row(
          children: List.generate(segments!, (index) {
            final isActive = index < activeSegments;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                color: isActive ? activeColor : Colors.transparent,
              ),
            );
          }),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: theme.border, width: theme.borderWidth),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedValue,
        child: Container(color: activeColor),
      ),
    );
  }
}

/// Retro Pixel Slider for seek & volume
class PixelSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final Color? activeColor;

  const PixelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final normalized = (value - min) / (max - min);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final localPos = renderBox.globalToLocal(details.globalPosition);
              final ratio = (localPos.dx / constraints.maxWidth).clamp(0.0, 1.0);
              onChanged(min + ratio * (max - min));
            }
          },
          onTapDown: (details) {
            final ratio = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
            onChanged(min + ratio * (max - min));
          },
          child: Container(
            height: 24,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    border: Border.all(color: theme.border, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: normalized.clamp(0.0, 1.0),
                    child: Container(color: activeColor ?? theme.amber),
                  ),
                ),
                // Pixel Thumb
                Positioned(
                  left: (normalized.clamp(0.0, 1.0) * (constraints.maxWidth - 14)),
                  child: Container(
                    width: 14,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      border: Border.all(color: theme.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.border,
                          offset: const Offset(1, 1),
                          blurRadius: 0,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
