import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_dialog.dart';
import '../../core/providers/library_providers.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/sync_providers.dart';
import '../../core/providers/player_providers.dart';
import '../../data/yt/yt_models.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isSyncing = false;
  String? _nextContinuation;
  bool _hasMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto sync on first mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLibrary(isRefresh: false);
    });
  }

  Future<void> _syncLibrary({bool isRefresh = true}) async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(libraryRepoProvider);
      final continuation = isRefresh ? null : _nextContinuation;

      final page = await repo.fetchLibraryPlaylists(continuation: continuation);

      setState(() {
        _isSyncing = false;
        _nextContinuation = page.continuation;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showCreatePlaylistDialog() {
    final titleController = TextEditingController();
    String privacy = 'PRIVATE';

    PixelDialog.show(
      context: context,
      title: 'TẠO PLAYLIST MỚI',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = ctx.pixelTheme;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tên danh sách phát:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: theme.boxDecoration(fillColor: theme.surface),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: titleController,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: theme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập tên...',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Quyền riêng tư:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: privacy,
                isExpanded: true,
                dropdownColor: theme.surface,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(value: 'PRIVATE', child: Text('Riêng tư (Private)')),
                  DropdownMenuItem(value: 'UNLISTED', child: Text('Không công khai (Unlisted)')),
                  DropdownMenuItem(value: 'PUBLIC', child: Text('Công khai (Public)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => privacy = val);
                  }
                },
              ),
            ],
          );
        },
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
            final title = titleController.text.trim();
            if (title.isNotEmpty) {
              Navigator.of(context).pop();
              final syncRepo = ref.read(syncRepoProvider);
              await syncRepo.createPlaylist(title, privacyStatus: privacy);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã tạo playlist "$title"', style: const TextStyle(fontFamily: 'monospace')),
                  ),
                );
              }
            }
          },
          child: const Text('TẠO'),
        ),
      ],
    );
  }

  Future<void> _shuffleRandomTracks() async {
    final syncRepo = ref.read(syncRepoProvider);
    final randomTracks = await syncRepo.getRandomTracks(count: 50);

    if (randomTracks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa có bài hát nào được đồng bộ trong thư viện!', style: TextStyle(fontFamily: 'monospace')),
          ),
        );
      }
      return;
    }

    // Play in player
    final playerService = ref.read(playerServiceProvider);
    await playerService.playQueue(randomTracks, startIndex: 0);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang phát ngẫu nhiên ${randomTracks.length} bài hát!', style: const TextStyle(fontFamily: 'monospace')),
          action: SnackBarAction(
            label: 'LƯU PLAYLIST',
            textColor: Colors.amber,
            onPressed: () => _promptSaveRandomQueueAsPlaylist(randomTracks),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _promptSaveRandomQueueAsPlaylist(List<YtTrack> tracks) {
    final now = DateTime.now();
    final titleController = TextEditingController(text: 'Trộn ngẫu nhiên ${now.day}/${now.month}');
    PixelDialog.show(
      context: context,
      title: 'LƯU THÀNH PLAYLIST MỚI',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Đặt tên cho danh sách phát ngẫu nhiên:',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: context.pixelTheme.boxDecoration(fillColor: context.pixelTheme.surface),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: titleController,
              autofocus: true,
              style: TextStyle(
                fontFamily: 'monospace',
                color: context.pixelTheme.textPrimary,
                fontSize: 13,
              ),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${tracks.length} bài hát sẽ được thêm vào danh sách phát.',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: context.pixelTheme.textSecondary,
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
            final title = titleController.text.trim();
            if (title.isNotEmpty) {
              Navigator.of(context).pop();
              final syncRepo = ref.read(syncRepoProvider);
              await syncRepo.saveRandomQueueAsPlaylist(title, tracks);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã lưu playlist "$title"!', style: const TextStyle(fontFamily: 'monospace')),
                  ),
                );
              }
            }
          },
          child: const Text('LƯU'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final playlistsAsync = ref.watch(localPlaylistsStreamProvider);
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final pendingOpsCountAsync = ref.watch(pendingOpsCountStreamProvider);
    final pendingOps = pendingOpsCountAsync.valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIBRARY'),
        actions: [
          if (pendingOps > 0)
            Center(
              child: GestureDetector(
                onTap: () async {
                  await ref.read(syncRepoProvider).processPendingOps();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã kích hoạt đồng bộ thay đổi!', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.accentRed,
                    border: Border.all(color: theme.border, width: 1),
                  ),
                  child: Text(
                    'SYNC: $pendingOps',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const PixelIcon(PixelIconType.add, size: 20),
            tooltip: 'Tạo playlist mới',
            onPressed: _showCreatePlaylistDialog,
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const PixelIcon(PixelIconType.sync, size: 20),
            tooltip: 'Sync Playlists',
            onPressed: _isSyncing ? null : () => _syncLibrary(isRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _syncLibrary(isRefresh: true),
        color: theme.primary,
        backgroundColor: theme.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Quick Actions: Trộn ngẫu nhiên (Spec 6.1) & Tạo Playlist
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: PixelButton(
                        isPrimary: true,
                        onPressed: _shuffleRandomTracks,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PixelIcon(PixelIconType.shuffle, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text('TRỘN NGẪU NHIÊN', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PixelButton(
                      onPressed: _showCreatePlaylistDialog,
                      child: const Row(
                        children: [
                          PixelIcon(PixelIconType.add, size: 14),
                          SizedBox(width: 6),
                          Text('TẠO', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Account / Auth Banner if guest
            SliverToBoxAdapter(
              child: activeAccountAsync.when(
                data: (account) => account == null
                    ? Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: theme.boxDecoration(
                          fillColor: theme.amber.withValues(alpha: 0.15),
                        ),
                        child: Row(
                          children: [
                            const PixelIcon(PixelIconType.settings, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You are in Guest mode. Sign in to view your private library.',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ),
                            PixelButton(
                              isSmall: true,
                              isPrimary: true,
                              onPressed: () => context.push('/login'),
                              child: const Text('LOGIN'),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        onPressed: () => _syncLibrary(isRefresh: true),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              ),

            // Playlists Grid
            playlistsAsync.when(
              data: (playlists) {
                if (playlists.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelIcon(PixelIconType.queue, size: 48, color: theme.amber),
                          const SizedBox(height: 16),
                          Text(
                            'NO PLAYLISTS FOUND',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull down to refresh or check your internet connection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PixelButton(
                            isPrimary: true,
                            onPressed: () => _syncLibrary(isRefresh: true),
                            child: const Text('SYNC NOW'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final playlist = playlists[index];
                        return GestureDetector(
                          onTap: () => context.push('/playlist/${playlist.id}'),
                          child: PixelCard(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: PixelImage(
                                    imageUrl: playlist.thumbUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  playlist.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${playlist.trackCount} tracks',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: playlists.length,
                    ),
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

            // Pagination Load More
            if (_hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PixelButton(
                    onPressed: _isSyncing ? null : () => _syncLibrary(isRefresh: false),
                    child: Center(
                      child: Text(_isSyncing ? 'LOADING MORE...' : 'LOAD MORE PLAYLISTS'),
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
