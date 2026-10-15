import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repo/search_repo.dart';
import '../../data/yt/yt_models.dart';
import '../../data/db/app_database.dart';
import 'auth_providers.dart';

/// SearchRepo Provider
final searchRepoProvider = Provider<SearchRepo>((ref) {
  final ytClient = ref.watch(ytClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return SearchRepo(ytClient: ytClient, db: db);
});

/// Search history stream provider
final searchHistoryStreamProvider = StreamProvider<List<SearchHistoryData>>((ref) {
  final repo = ref.watch(searchRepoProvider);
  return repo.watchHistory();
});

/// Selected filter chip provider
final searchFilterProvider = StateProvider<SearchFilter>((ref) => SearchFilter.all);

/// Search state model
class SearchResultState {
  final String query;
  final SearchFilter filter;
  final List<YtSearchResultItem> items;
  final String? continuation;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const SearchResultState({
    this.query = '',
    this.filter = SearchFilter.all,
    this.items = const [],
    this.continuation,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasMore => continuation != null && continuation!.isNotEmpty;
  bool get isEmpty => items.isEmpty && !isLoading && query.isNotEmpty;

  SearchResultState copyWith({
    String? query,
    SearchFilter? filter,
    List<YtSearchResultItem>? items,
    String? continuation,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return SearchResultState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      continuation: continuation ?? this.continuation,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Search controller notifier managing search execution and pagination
class SearchNotifier extends StateNotifier<SearchResultState> {
  final SearchRepo _repo;

  SearchNotifier(this._repo) : super(const SearchResultState());

  Future<void> search(String query, {SearchFilter filter = SearchFilter.all}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = SearchResultState(query: '', filter: filter);
      return;
    }

    state = state.copyWith(
      query: trimmed,
      filter: filter,
      isLoading: true,
      error: null,
    );

    try {
      final page = await _repo.search(trimmed, filter: filter);
      state = state.copyWith(
        items: page.items,
        continuation: page.continuation,
        isLoading: false,
      );
    } catch (e) {
      // Don't show error if request was cancelled due to typing faster
      if (e.toString().contains('cancelled')) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _repo.search(
        state.query,
        filter: state.filter,
        continuation: state.continuation,
      );

      state = state.copyWith(
        items: [...state.items, ...page.items],
        continuation: page.continuation,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clear() {
    state = const SearchResultState();
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchResultState>((ref) {
  final repo = ref.watch(searchRepoProvider);
  return SearchNotifier(repo);
});
