import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_dialog.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/library_providers.dart';
import '../../core/providers/sync_providers.dart';
import '../../data/yt/yt_models.dart';

/// Shows a retro pixel dialog allowing the user to pick a playlist to add [track] to
Future<void> showAddToPlaylistDialog(
  BuildContext context,
  WidgetRef ref,
  YtTrack track,
) async {
  final playlists = await ref.read(localPlaylistsStreamProvider.future);

  if (!context.mounted) return;

  if (playlists.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Chưa có playlist nào. Hãy tạo playlist mới trong Thư viện!',
          style: TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
    return;
  }

  await PixelDialog.show(
    context: context,
    title: 'THÊM VÀO PLAYLIST',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chọn danh sách phát cho bài hát:',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: context.pixelTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: context.pixelTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: playlists.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, index) {
              final pl = playlists[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: const PixelIcon(PixelIconType.queue, size: 16),
                title: Text(
                  pl.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ctx.pixelTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${pl.trackCount} bài hát',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: ctx.pixelTheme.textSecondary,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(syncRepoProvider).addTrackToPlaylist(pl.id, track);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm vào "${pl.title}"',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    ),
    actions: [
      PixelButton(
        isSmall: true,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('ĐÓNG'),
      ),
    ],
  );
}
