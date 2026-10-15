import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/player_providers.dart';

/// Retro bottom sheet displaying the current Queue with reordering and deletion
class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QueueBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final queueController = ref.watch(queueControllerProvider);
    final playerService = ref.watch(playerServiceProvider);
    final queue = queueController.queue;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(
          top: BorderSide(color: theme.border, width: theme.borderWidth),
          left: BorderSide(color: theme.border, width: theme.borderWidth),
          right: BorderSide(color: theme.border, width: theme.borderWidth),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary,
              border: Border.all(color: theme.border, width: theme.borderWidth),
            ),
            child: Row(
              children: [
                Text(
                  'UP NEXT (${queue.length} TRACKS)',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (queue.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Queue is empty',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: theme.textSecondary,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                itemCount: queue.length,
                onReorderItem: (oldIndex, newIndex) {
                  queueController.reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final track = queue[index];
                  final isCurrent = index == queueController.currentIndex;

                  return Container(
                    key: ValueKey('${track.videoId}_$index'),
                    color: isCurrent
                        ? theme.amber.withValues(alpha: 0.15)
                        : Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.drag_handle,
                              size: 18, color: theme.textSecondary),
                          const SizedBox(width: 8),
                          PixelImage(
                            imageUrl: track.thumbUrl,
                            width: 36,
                            height: 36,
                          ),
                        ],
                      ),
                      title: Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                          color: isCurrent ? theme.primary : theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        track.artistsDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: theme.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent)
                            const PixelIcon(PixelIconType.play, size: 14)
                          else
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => queueController.removeAt(index),
                            ),
                        ],
                      ),
                      onTap: () {
                        playerService.playTrackAtIndex(index);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
