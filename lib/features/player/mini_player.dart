import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/player_providers.dart';
import 'player_screen.dart';

/// Retro persistent Mini Player appearing above Bottom Navigation bar
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final playerService = ref.watch(playerServiceProvider);
    final track = playerService.currentTrack;

    if (track == null) {
      return const SizedBox.shrink();
    }

    final durationMs = playerService.duration.inMilliseconds;
    final progress = durationMs > 0
        ? (playerService.position.inMilliseconds / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        PlayerScreen.show(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(
            top: BorderSide(color: theme.border, width: theme.borderWidth),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.border,
              offset: const Offset(0, -2),
              blurRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top mini progress line
            PixelProgressBar(
              value: progress,
              height: 3,
              barColor: theme.primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  PixelImage(
                    imageUrl: track.thumbUrl,
                    width: 38,
                    height: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          track.artistsDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Controls
                  IconButton(
                    icon: playerService.isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primary,
                            ),
                          )
                        : PixelIcon(
                            playerService.isPlaying
                                ? PixelIconType.pause
                                : PixelIconType.play,
                            size: 20,
                            color: theme.primary,
                          ),
                    onPressed: () => playerService.togglePlayPause(),
                  ),
                  IconButton(
                    icon: const PixelIcon(PixelIconType.next, size: 20),
                    onPressed: () => playerService.next(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
