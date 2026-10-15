import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/player_providers.dart';
import '../../audio/queue_controller.dart';
import 'pixel_visualizer.dart';
import 'queue_bottom_sheet.dart';

/// Full screen retro pixel music player
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PlayerScreen(),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final playerService = ref.watch(playerServiceProvider);
    final queueController = ref.watch(queueControllerProvider);
    final track = playerService.currentTrack;

    if (track == null) {
      return Container(
        color: theme.background,
        child: const Center(child: Text('No song playing')),
      );
    }

    final duration = playerService.duration;
    final position = playerService.position;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    PixelIconType loopIcon;
    switch (queueController.loopMode) {
      case LoopMode.off:
        loopIcon = PixelIconType.loopOff;
        break;
      case LoopMode.one:
        loopIcon = PixelIconType.loopOne;
        break;
      case LoopMode.all:
        loopIcon = PixelIconType.loopAll;
        break;
      case LoopMode.oneTimesN:
        loopIcon = PixelIconType.loopOneTimesN;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(
          top: BorderSide(color: theme.border, width: theme.borderWidth),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'NOW PLAYING',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
              color: theme.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const PixelIcon(PixelIconType.queue, size: 22),
              tooltip: 'Queue',
              onPressed: () => QueueBottomSheet.show(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pixel Album Artwork with 0-radius and offset shadow
              Center(
                child: Container(
                  decoration: theme.boxDecoration(
                    hasShadow: true,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: PixelImage(
                      imageUrl: track.thumbUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),

              // Title, Artist, & Equalizer
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                fontSize: 16,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artistsDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      PixelVisualizer(
                        isPlaying: playerService.isPlaying,
                        height: 24,
                        barCount: 5,
                      ),
                    ],
                  ),
                ],
              ),

              // Seek Slider and Times
              Column(
                children: [
                  PixelSlider(
                    value: progress,
                    onChanged: (val) {
                      final targetMs = (val * duration.inMilliseconds).round();
                      playerService.seek(Duration(milliseconds: targetMs));
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Main Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle button
                  IconButton(
                    icon: PixelIcon(
                      PixelIconType.shuffle,
                      size: 24,
                      color: queueController.shuffleOn
                          ? theme.primary
                          : theme.textSecondary,
                    ),
                    onPressed: () => queueController.toggleShuffle(),
                  ),
                  // Previous button
                  IconButton(
                    icon: const PixelIcon(PixelIconType.prev, size: 28),
                    onPressed: () => playerService.previous(),
                  ),
                  // Big Retro Play/Pause button
                  PixelButton(
                    isPrimary: true,
                    padding: const EdgeInsets.all(16),
                    onPressed: () => playerService.togglePlayPause(),
                    child: PixelIcon(
                      playerService.isPlaying
                          ? PixelIconType.pause
                          : PixelIconType.play,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  // Next button
                  IconButton(
                    icon: const PixelIcon(PixelIconType.next, size: 28),
                    onPressed: () => playerService.next(),
                  ),
                  // Loop button
                  IconButton(
                    icon: PixelIcon(
                      loopIcon,
                      size: 24,
                      color: queueController.loopMode != LoopMode.off
                          ? theme.primary
                          : theme.textSecondary,
                    ),
                    onPressed: () => queueController.cycleLoopMode(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
