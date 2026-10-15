import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/library_providers.dart';

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
    final seconds = ms ~/ 1000;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final metaAsync = ref.watch(playlistMetaProvider(widget.playlistId));
    final tracksAsync = ref.watch(playlistTracksStreamProvider(widget.playlistId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAYLIST'),
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
                                  onPressed: () {},
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelIcon(PixelIconType.play, size: 14, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text('PLAY ALL'),
                                    ],
                                  ),
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

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = tracks[index];
                      return Container(
                        decoration: BoxDecoration(
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
                              color: theme.textPrimary,
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
                          trailing: Text(
                            _formatDuration(track.durationMs),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                          onTap: () {
                            // Queue and player trigger in M4
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
