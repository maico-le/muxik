import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import 'pixel_icon.dart';

/// Retro Pixel Image that downscales and renders with FilterQuality.none for crisp pixelation
class PixelImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const PixelImage({
    super.key,
    required this.imageUrl,
    this.width = 48.0,
    this.height = 48.0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    Widget placeholder() {
      return Container(
        width: width,
        height: height,
        color: theme.surface,
        alignment: Alignment.center,
        child: PixelIcon(
          PixelIconType.play,
          size: width * 0.4,
          color: theme.amber,
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder();
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: theme.border, width: theme.borderWidth),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.none, // Crisp pixelation without blur
        placeholder: (context, url) => placeholder(),
        errorWidget: (context, url, error) => placeholder(),
      ),
    );
  }
}
