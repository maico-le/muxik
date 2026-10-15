import 'package:flutter/material.dart';

enum PixelIconType {
  play,
  pause,
  next,
  prev,
  shuffle,
  loopOff,
  loopOne,
  loopAll,
  loopOneTimesN,
  queue,
  search,
  sync,
  add,
  heart,
  heartFilled,
  menu,
  settings,
  close,
  wifi,
  cellular,
  battery,
}

/// Retro 8-bit Pixel Icon drawn crisp on a discrete pixel grid
class PixelIcon extends StatelessWidget {
  final PixelIconType type;
  final double size;
  final Color? color;

  const PixelIcon(
    this.type, {
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Colors.black;

    return CustomPaint(
      size: Size(size, size),
      painter: _PixelIconPainter(type: type, color: iconColor),
    );
  }
}

class _PixelIconPainter extends CustomPainter {
  final PixelIconType type;
  final Color color;

  _PixelIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // We draw on an 8x8 or 12x12 discrete pixel matrix
    const gridDim = 8;
    final pixelSize = size.width / gridDim;

    void drawPixel(int x, int y) {
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }

    switch (type) {
      case PixelIconType.play:
        // Play triangle facing right
        for (var x = 2; x <= 6; x++) {
          final height = 7 - x;
          for (var y = 4 - height ~/ 2; y <= 4 + height ~/ 2; y++) {
            drawPixel(x, y);
          }
        }
        break;

      case PixelIconType.pause:
        // Two vertical bars
        for (var y = 1; y <= 6; y++) {
          drawPixel(2, y);
          drawPixel(3, y);
          drawPixel(5, y);
          drawPixel(6, y);
        }
        break;

      case PixelIconType.next:
        // Triangle + vertical bar
        for (var x = 1; x <= 4; x++) {
          final height = 6 - x;
          for (var y = 4 - height ~/ 2; y <= 4 + height ~/ 2; y++) {
            drawPixel(x, y);
          }
        }
        for (var y = 1; y <= 6; y++) {
          drawPixel(6, y);
        }
        break;

      case PixelIconType.prev:
        // Vertical bar + triangle facing left
        for (var y = 1; y <= 6; y++) {
          drawPixel(1, y);
        }
        for (var x = 3; x <= 6; x++) {
          final height = x;
          for (var y = 4 - height ~/ 2; y <= 4 + height ~/ 2; y++) {
            drawPixel(7 - x + 2, y);
          }
        }
        break;

      case PixelIconType.shuffle:
        // Crossed arrows
        drawPixel(1, 2);
        drawPixel(2, 2);
        drawPixel(3, 3);
        drawPixel(4, 4);
        drawPixel(5, 5);
        drawPixel(6, 5);
        // arrow head
        drawPixel(5, 4);
        drawPixel(6, 6);

        drawPixel(1, 5);
        drawPixel(2, 5);
        drawPixel(3, 4);
        drawPixel(4, 3);
        drawPixel(5, 2);
        drawPixel(6, 2);
        // arrow head
        drawPixel(5, 1);
        drawPixel(6, 3);
        break;

      case PixelIconType.loopOff:
      case PixelIconType.loopAll:
        // Circular loop arrows
        for (var x = 2; x <= 5; x++) {
          drawPixel(x, 1);
          drawPixel(x, 6);
        }
        drawPixel(1, 2);
        drawPixel(1, 3);
        drawPixel(6, 4);
        drawPixel(6, 5);
        // arrows
        drawPixel(5, 0);
        drawPixel(5, 2);
        drawPixel(2, 5);
        drawPixel(2, 7);
        break;

      case PixelIconType.loopOne:
        // Loop box with '1' inside
        for (var x = 1; x <= 6; x++) {
          drawPixel(x, 1);
          drawPixel(x, 6);
        }
        drawPixel(1, 2);
        drawPixel(6, 5);
        // '1' in middle
        drawPixel(4, 3);
        drawPixel(4, 4);
        drawPixel(3, 3);
        break;

      case PixelIconType.loopOneTimesN:
        // Loop box with 'N' inside
        for (var x = 1; x <= 6; x++) {
          drawPixel(x, 1);
          drawPixel(x, 6);
        }
        drawPixel(1, 2);
        drawPixel(6, 5);
        // 'N' in middle
        drawPixel(3, 3);
        drawPixel(3, 4);
        drawPixel(5, 3);
        drawPixel(5, 4);
        drawPixel(4, 3);
        break;

      case PixelIconType.queue:
        // 3 horizontal bars
        for (var x = 1; x <= 6; x++) {
          drawPixel(x, 2);
          drawPixel(x, 4);
          drawPixel(x, 6);
        }
        break;

      case PixelIconType.search:
        // Pixel magnifying glass
        drawPixel(2, 1);
        drawPixel(3, 1);
        drawPixel(1, 2);
        drawPixel(4, 2);
        drawPixel(1, 3);
        drawPixel(4, 3);
        drawPixel(2, 4);
        drawPixel(3, 4);
        // handle
        drawPixel(4, 4);
        drawPixel(5, 5);
        drawPixel(6, 6);
        break;

      case PixelIconType.sync:
        // Circular sync arrows
        drawPixel(2, 1);
        drawPixel(3, 1);
        drawPixel(4, 1);
        drawPixel(5, 2);
        drawPixel(1, 3);
        drawPixel(5, 4);
        drawPixel(2, 6);
        drawPixel(3, 6);
        drawPixel(4, 6);
        drawPixel(1, 5);
        break;

      case PixelIconType.add:
        // Plus sign
        for (var i = 1; i <= 6; i++) {
          drawPixel(i, 3);
          drawPixel(i, 4);
          drawPixel(3, i);
          drawPixel(4, i);
        }
        break;

      case PixelIconType.heart:
        // Pixel heart outline
        drawPixel(2, 1);
        drawPixel(3, 1);
        drawPixel(5, 1);
        drawPixel(6, 1);
        drawPixel(1, 2);
        drawPixel(4, 2);
        drawPixel(7, 2);
        drawPixel(1, 3);
        drawPixel(7, 3);
        drawPixel(2, 4);
        drawPixel(6, 4);
        drawPixel(3, 5);
        drawPixel(5, 5);
        drawPixel(4, 6);
        break;

      case PixelIconType.heartFilled:
        // Pixel heart filled
        drawPixel(2, 1);
        drawPixel(3, 1);
        drawPixel(5, 1);
        drawPixel(6, 1);
        for (var x = 1; x <= 7; x++) {
          drawPixel(x, 2);
          drawPixel(x, 3);
        }
        for (var x = 2; x <= 6; x++) {
          drawPixel(x, 4);
        }
        for (var x = 3; x <= 5; x++) {
          drawPixel(x, 5);
        }
        drawPixel(4, 6);
        break;

      case PixelIconType.menu:
        // 3 horizontal dots
        drawPixel(2, 3);
        drawPixel(2, 4);
        drawPixel(4, 3);
        drawPixel(4, 4);
        drawPixel(6, 3);
        drawPixel(6, 4);
        break;

      case PixelIconType.settings:
        // Gear block
        for (var x = 2; x <= 5; x++) {
          for (var y = 2; y <= 5; y++) {
            if (x != 3 && y != 3) drawPixel(x, y);
          }
        }
        drawPixel(3, 0);
        drawPixel(4, 0);
        drawPixel(3, 7);
        drawPixel(4, 7);
        drawPixel(0, 3);
        drawPixel(0, 4);
        drawPixel(7, 3);
        drawPixel(7, 4);
        break;

      case PixelIconType.close:
        for (var i = 1; i <= 6; i++) {
          drawPixel(i, i);
          drawPixel(7 - i, i);
        }
        break;

      case PixelIconType.wifi:
        for (var x = 1; x <= 6; x++) {
          drawPixel(x, 1);
        }
        for (var x = 2; x <= 5; x++) {
          drawPixel(x, 3);
        }
        drawPixel(3, 5);
        drawPixel(4, 5);
        drawPixel(3, 7);
        drawPixel(4, 7);
        break;

      case PixelIconType.cellular:
        // Signal bars
        drawPixel(1, 6);
        drawPixel(2, 6);
        drawPixel(3, 5);
        drawPixel(3, 6);
        drawPixel(4, 4);
        drawPixel(4, 5);
        drawPixel(4, 6);
        drawPixel(5, 3);
        drawPixel(5, 4);
        drawPixel(5, 5);
        drawPixel(5, 6);
        break;

      case PixelIconType.battery:
        // Battery block
        for (var x = 1; x <= 5; x++) {
          drawPixel(x, 2);
          drawPixel(x, 6);
        }
        for (var y = 2; y <= 6; y++) {
          drawPixel(1, y);
          drawPixel(5, y);
        }
        drawPixel(6, 3);
        drawPixel(6, 4);
        drawPixel(6, 5);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PixelIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
