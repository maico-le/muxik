import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_dialog.dart';
import '../../core/providers/library_providers.dart';
import '../../core/providers/player_providers.dart';
import '../../core/providers/sync_providers.dart';
import '../../data/yt/yt_models.dart';
import '../player/player_screen.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  bool _isLoading = false;
  String? _nextContinuation;
  bool _hasMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTracks(isRefresh: false);
    });
  }

  Future<void> _loadTracks({bool isRefresh = true}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(libraryRepoProvider);
      final continuation = isRefresh ? null : _nextContinuation;

      final existingTracks = await ref.read(
        playlistTracksStreamProvider(widget.playlistId).future,
      );
      final startPos = isRefresh ? 0 : existingTracks.length;

      final page = await repo.fetchPlaylistTracks(
        widget.playlistId,
        continuation: continuation,
        startPosition: startPos,
      );

      setState(() {
        _isLoading = false;
        _nextContinuation = page.continuation;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String _formatDuration(int ms) {
    if (ms <= 0) return '--:--';
    final seconds = ms ~/ 1000;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool _isReorderMode = false;

  void _showRenamePlaylistDialog(String currentTitle) {
    final titleController = TextEditingController(text: currentTitle);
    PixelDialog.show(
      context: context,
      title: 'ĐỔI TÊN PLAYLIST',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Nhập tên mới cho playlist:', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: context.pixelTheme.boxDecoration(fillColor: context.pixelTheme.surface),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: titleController,
              autofocus: true,
              style: TextStyle(fontFamily: 'monospace', color: context.pixelTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
      actions: [
        PixelButton(
          isSmall: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('HUỶ'),
        ),
        const SizedBox(width: 8),
        PixelButton(
          isSmall: true,
          isPrimary: true,
          onPressed: () async {
            final newTitle = titleController.text.trim();
            if (newTitle.isNotEmpty) {
              Navigator.of(context).pop();
              await ref.read(syncRepoProvider).renamePlaylist(widget.playlistId, newTitle);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã đổi tên thành "$newTitle"', style: const TextStyle(fontFamily: 'monospace'))),
                );
              }
            }
          },
          child: const Text('LƯU'),
        ),
      ],
    );
  }

  void _showDeletePlaylistDialog(String title) {
    PixelDialog.show(
      context: context,
      title: 'XOÁ PLAYLIST',
      content: Text('Bạn có chắc chắn muốn xoá playlist "$title"? Thao tác này sẽ đồng bộ lên YouTube.'),
      actions: [
        PixelButton(
          isSmall: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('HUỶ'),
        ),
        const SizedBox(width: 8),
        PixelButton(
          isSmall: true,
          isPrimary: true,
          onPressed: () async {
            Navigator.of(context).pop();
            await ref.read(syncRepoProvider).deletePlaylist(widget.playlistId);
            if (mounted) {
              Navigator.of(context).pop(); // Back to library
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xoá playlist "$title"', style: const TextStyle(fontFamily: 'monospace'))),
              );
            }
          },
          child: const Text('XOÁ'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final metaAsync = ref.watch(playlistMetaProvider(widget.playlistId));
    final tracksAsync = ref.watch(playlistTracksStreamProvider(widget.playlistId));
    final playlistTitle = metaAsync.valueOrNull?.title ?? 'PLAYLIST';

    return Scaffold(
      appBar: AppBar(
        title: Text(playlistTitle),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const PixelIcon(PixelIconType.sync, size: 20),
            tooltip: 'Sync Tracks',
            onPressed: _isLoading ? null : () => _loadTracks(isRefresh: true),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: theme.surface,
            onSelected: (val) {
              if (val == 'rename') {
                _showRenamePlaylistDialog(playlistTitle);
              } else if (val == 'delete') {
                _showDeletePlaylistDialog(playlistTitle);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'rename',
                child: Text('Đổi tên playlist', style: TextStyle(fontFamily: 'monospace', color: theme.textPrimary, fontSize: 12)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Xoá playlist', style: TextStyle(fontFamily: 'monospace', color: theme.accentRed, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadTracks(isRefresh: true),
        color: theme.primary,
        backgroundColor: theme.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Playlist Header Banner
            SliverToBoxAdapter(
              child: metaAsync.when(
                data: (meta) => Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.surface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PixelImage(
                        imageUrl: meta?.thumbUrl,
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meta?.title ?? 'PLAYLIST',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${meta?.trackCount ?? 0} tracks',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: theme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                PixelButton(
                                  isSmall: true,
                                  isPrimary: true,
                                  onPressed: tracksAsync.valueOrNull == null ||
                                          tracksAsync.valueOrNull!.isEmpty
                                      ? null
                                      : () {
                                          final ytTracks = tracksAsync.valueOrNull!
                                              .map((t) => YtTrack(
                                                    videoId: t.videoId,
                                                    title: t.title,
                                                    artists: t.artists.split(', '),
                                                    album: t.album,
                                                    durationMs: t.durationMs,
                                                    thumbUrl: t.thumbUrl ?? '',
                                                    isPlayable: t.isPlayable,
                                                  ))
                                              .toList();
                                          ref
                                              .read(playerServiceProvider)
                                              .playQueue(ytTracks, startIndex: 0);
                                        },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelIcon(PixelIconType.play, size: 14, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text('PLAY ALL'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                PixelButton(
                                  isSmall: true,
                                  onPressed: tracksAsync.valueOrNull == null ||
                                          tracksAsync.valueOrNull!.isEmpty
                                      ? null
                                      : () async {
                                          final syncRepo = ref.read(syncRepoProvider);
                                          final randomTracks = await syncRepo.getRandomTracks(
                                            playlistId: widget.playlistId,
                                            count: 50,
                                          );
                                          if (randomTracks.isNotEmpty) {
                                            ref
                                                .read(playerServiceProvider)
                                                .playQueue(randomTracks, startIndex: 0);
                                          }
                                        },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelIcon(PixelIconType.shuffle, size: 14),
                                      SizedBox(width: 6),
                                      Text('TRỘN'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                PixelButton(
                                  isSmall: true,
                                  onPressed: () {
                                    setState(() => _isReorderMode = !_isReorderMode);
                                  },
                                  child: Text(_isReorderMode ? 'XONG' : 'XẾP'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 100),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(10),
                  color: theme.accentRed.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: theme.accentRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: theme.accentRed,
                          ),
                        ),
                      ),
                      PixelButton(
                        isSmall: true,
                        onPressed: () => _loadTracks(isRefresh: true),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              ),

            // Tracks List
            tracksAsync.when(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelIcon(PixelIconType.queue, size: 40, color: theme.amber),
                          const SizedBox(height: 12),
                          Text(
                            'NO TRACKS IN THIS PLAYLIST',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PixelButton(
                            isSmall: true,
                            onPressed: () => _loadTracks(isRefresh: true),
                            child: const Text('SYNC NOW'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_isReorderMode) {
                  return SliverReorderableList(
                    itemCount: tracks.length,
                    onReorderItem: (oldIdx, newIdx) {
                      ref.read(syncRepoProvider).reorderTrack(
                            widget.playlistId,
                            oldIdx,
                            newIdx,
                          );
                    },
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return Container(
                        key: ValueKey('reorder_${track.videoId}_$index'),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.border.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Text(
                            '${index + 1}',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: theme.textSecondary),
                          ),
                          title: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                          ),
                          subtitle: Text(
                            track.artists,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: theme.textSecondary),
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle, size: 20),
                          ),
                        ),
                      );
                    },
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = tracks[index];
                      final playerService = ref.watch(playerServiceProvider);
                      final isCurrentTrack =
                          playerService.currentTrack?.videoId == track.videoId;
                      final isPlaying = isCurrentTrack && playerService.isPlaying;

                      final ytTracks = tracks
                          .map((t) => YtTrack(
                                videoId: t.videoId,
                                title: t.title,
                                artists: t.artists.split(', '),
                                album: t.album,
                                durationMs: t.durationMs,
                                thumbUrl: t.thumbUrl ?? '',
                                isPlayable: t.isPlayable,
                              ))
                          .toList();

                      return Container(
                        decoration: BoxDecoration(
                          color: isCurrentTrack
                              ? theme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.border.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ),
                              PixelImage(
                                imageUrl: track.thumbUrl,
                                width: 44,
                                height: 44,
                              ),
                            ],
                          ),
                          title: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isCurrentTrack
                                  ? theme.primary
                                  : theme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            track.artists,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: PixelIcon(
                                  isPlaying
                                      ? PixelIconType.pause
                                      : PixelIconType.play,
                                  size: 16,
                                  color: isCurrentTrack
                                      ? theme.primary
                                      : theme.textPrimary,
                                ),
                                tooltip: isPlaying ? 'Tạm dừng' : 'Phát bài này',
                                onPressed: () {
                                  if (isCurrentTrack) {
                                    playerService.togglePlayPause();
                                  } else {
                                    playerService.playQueue(ytTracks,
                                        startIndex: index);
                                  }
                                },
                              ),
                              Text(
                                _formatDuration(track.durationMs),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: theme.textSecondary,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 16),
                                color: theme.surface,
                                onSelected: (val) {
                                  if (val == 'remove') {
                                    ref.read(syncRepoProvider).removeTrackFromPlaylist(
                                          widget.playlistId,
                                          track.videoId,
                                          position: index,
                                        );
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: Text(
                                      'Xoá khỏi playlist',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: theme.accentRed,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!isCurrentTrack ||
                                playerService.status == PlayerStatus.error) {
                              playerService.playQueue(ytTracks,
                                  startIndex: index);
                            } else if (!playerService.isPlaying) {
                              playerService.play();
                            }
                            PlayerScreen.show(context);
                          },
                        ),
                      );
                    },
                    childCount: tracks.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error: $err',
                    style: TextStyle(fontFamily: 'monospace', color: theme.accentRed),
                  ),
                ),
              ),
            ),

            // Pagination continuation button
            if (_hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PixelButton(
                    onPressed: _isLoading ? null : () => _loadTracks(isRefresh: false),
                    child: Center(
                      child: Text(_isLoading ? 'LOADING TRACKS...' : 'LOAD MORE TRACKS'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
