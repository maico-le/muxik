import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/providers/search_providers.dart';
import '../../core/providers/player_providers.dart';
import '../../data/yt/yt_models.dart';
import '../playlist/add_to_playlist_dialog.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchNotifierProvider.notifier).loadMore();
    }
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    // 400ms debounce per Spec 6.3
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final filter = ref.read(searchFilterProvider);
      ref.read(searchNotifierProvider.notifier).search(query, filter: filter);
    });
    setState(() {});
  }

  void _onFilterSelected(SearchFilter filter) {
    ref.read(searchFilterProvider.notifier).state = filter;
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(searchNotifierProvider.notifier).search(query, filter: filter);
    }
  }

  void _executeSearch(String query) {
    _searchController.text = query;
    _debounceTimer?.cancel();
    final filter = ref.read(searchFilterProvider);
    ref.read(searchNotifierProvider.notifier).search(query, filter: filter);
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    ref.read(searchNotifierProvider.notifier).clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final searchState = ref.watch(searchNotifierProvider);
    final activeFilter = ref.watch(searchFilterProvider);
    final historyAsync = ref.watch(searchHistoryStreamProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('SEARCH'),
        backgroundColor: theme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Pixel Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: theme.boxDecoration(
                fillColor: theme.surface,
                hasShadow: true,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                children: [
                  PixelIcon(PixelIconType.search, size: 18, color: theme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onQueryChanged,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: theme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'SEARCH SONGS, ARTISTS, ALBUMS...',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: theme.border,
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: theme.surface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: SearchFilter.values.map((filter) {
                final isSelected = activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () => _onFilterSelected(filter),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primary : theme.surface,
                        border: Border.all(color: theme.border, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Text(
                        filter.label,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.surface : theme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1, thickness: 2),

          // 3. Search Results or Search History
          Expanded(
            child: _searchController.text.trim().isEmpty
                ? _buildHistoryView(theme, historyAsync)
                : _buildResultsView(theme, searchState),
          ),
        ],
      ),
    );
  }

  /// History view displayed when search bar is empty
  Widget _buildHistoryView(
    PixelTheme theme,
    AsyncValue<List<dynamic>> historyAsync,
  ) {
    return historyAsync.when(
      data: (historyList) {
        if (historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PixelIcon(PixelIconType.search, size: 36, color: theme.border),
                const SizedBox(height: 12),
                Text(
                  'NO RECENT SEARCHES',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT SEARCHES',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(searchRepoProvider).clearHistory(),
                  child: Text(
                    'CLEAR ALL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.accentRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...historyList.map((item) {
              final queryText = item.query as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: theme.boxDecoration(fillColor: theme.surface),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.history, size: 18, color: theme.textSecondary),
                  title: Text(
                    queryText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: theme.textPrimary,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => ref.read(searchRepoProvider).removeHistory(queryText),
                    child: Icon(Icons.close, size: 16, color: theme.textSecondary),
                  ),
                  onTap: () => _executeSearch(queryText),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading history: $e', style: TextStyle(color: theme.accentRed)),
      ),
    );
  }

  /// Results view displayed when query is present
  Widget _buildResultsView(PixelTheme theme, SearchResultState state) {
    if (state.isLoading && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'SEARCHING...',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 36, color: theme.accentRed),
              const SizedBox(height: 12),
              Text(
                'FAILED TO SEARCH',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.accentRed,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              PixelButton(
                onPressed: () => ref.read(searchNotifierProvider.notifier).search(
                      _searchController.text.trim(),
                      filter: ref.read(searchFilterProvider),
                    ),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelIcon(PixelIconType.search, size: 36, color: theme.border),
            const SizedBox(height: 12),
            Text(
              'NO RESULTS FOUND',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: state.isLoadingMore
                  ? const CircularProgressIndicator()
                  : PixelButton(
                      isSmall: true,
                      onPressed: () => ref.read(searchNotifierProvider.notifier).loadMore(),
                      child: const Text('LOAD MORE'),
                    ),
            ),
          );
        }

        final item = state.items[index];
        return _buildResultCard(theme, item, state.items);
      },
    );
  }

  Widget _buildResultCard(
    PixelTheme theme,
    YtSearchResultItem item,
    List<YtSearchResultItem> allItems,
  ) {
    Color badgeColor;
    String badgeLabel;

    switch (item.type) {
      case SearchResultType.song:
        badgeColor = theme.primary;
        badgeLabel = 'SONG';
        break;
      case SearchResultType.video:
        badgeColor = theme.accentRed;
        badgeLabel = 'VIDEO';
        break;
      case SearchResultType.album:
        badgeColor = theme.amber;
        badgeLabel = 'ALBUM';
        break;
      case SearchResultType.artist:
        badgeColor = theme.gold;
        badgeLabel = 'ARTIST';
        break;
      case SearchResultType.playlist:
        badgeColor = theme.border;
        badgeLabel = 'PLAYLIST';
        break;
      default:
        badgeColor = theme.border;
        badgeLabel = 'MEDIA';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PixelCard(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            if (item.isPlayable) {
              final playableTracks = allItems
                  .where((i) => i.isPlayable)
                  .map((i) => i.toYtTrack())
                  .toList();
              final startIndex =
                  playableTracks.indexWhere((t) => t.videoId == item.id);
              if (startIndex != -1) {
                ref
                    .read(playerServiceProvider)
                    .playQueue(playableTracks, startIndex: startIndex);
              }
            } else if (item.type == SearchResultType.playlist ||
                item.type == SearchResultType.album) {
              context.push('/playlist/${item.id}');
            }
          },
          child: Row(
            children: [
              PixelImage(
                imageUrl: item.thumbUrl,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
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
              Container(
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              if (item.isPlayable) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  padding: EdgeInsets.zero,
                  color: theme.surface,
                  onSelected: (val) {
                    if (val == 'add') {
                      showAddToPlaylistDialog(context, ref, item.toYtTrack());
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'add',
                      child: Text(
                        'Thêm vào playlist',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: theme.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
