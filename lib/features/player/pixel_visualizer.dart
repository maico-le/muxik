import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/pixel_theme.dart';

/// Retro 8-bit stepped equalizer bar visualizer
class PixelVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;
  final Color? color;

  const PixelVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 7,
    this.height = 28,
    this.color,
  });

  @override
  State<PixelVisualizer> createState() => _PixelVisualizerState();
}

class _PixelVisualizerState extends State<PixelVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => _rand.nextDouble());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Stepped 8-bit ticks
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (var i = 0; i < widget.barCount; i++) {
              _barHeights[i] = 0.2 + _rand.nextDouble() * 0.8;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PixelVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        setState(() {
          for (var i = 0; i < widget.barCount; i++) {
            _barHeights[i] = 0.15;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final activeColor = widget.color ?? theme.primary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          final factor = _barHeights[index].clamp(0.1, 1.0);
          final barH = widget.height * factor;

          return Container(
            width: 4,
            height: barH,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            color: activeColor,
          );
        }),
      ),
    );
  }
}
