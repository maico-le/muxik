import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/providers/library_providers.dart';
import '../../core/providers/auth_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final playlistsAsync = ref.watch(localPlaylistsStreamProvider);
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIBRARY'),
        actions: [
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
