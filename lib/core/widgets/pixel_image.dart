import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/pixel_theme.dart';
import '../providers/network_providers.dart';
import 'pixel_icon.dart';

/// Retro Pixel Image that downscales and renders with FilterQuality.none for crisp pixelation.
/// Respects NetworkPolicy: disables image download in Super Data Saver mode and downscales on cellular.
class PixelImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final networkPolicy = ref.watch(networkPolicyProvider);

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

    // Spec 7.5: Super Data Saver disables remote thumbnail downloading
    if (!networkPolicy.shouldLoadThumbnails) {
      return placeholder();
    }

    // On cellular, optimize thumbnail size parameters if supported by YouTube/Google URLs
    String finalUrl = imageUrl!;
    if (networkPolicy.isCellular) {
      if (finalUrl.contains('=w') || finalUrl.contains('=s')) {
        finalUrl = finalUrl.replaceAll(RegExp(r'=w\d+-h\d+.*$'), '=w60-h60-c');
        finalUrl = finalUrl.replaceAll(RegExp(r'=s\d+.*$'), '=s120');
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: theme.border, width: theme.borderWidth),
      ),
      child: CachedNetworkImage(
        imageUrl: finalUrl,
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
