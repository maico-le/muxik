import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../yt/yt_client.dart';
import '../yt/yt_models.dart';
import '../yt/innertube_parser.dart';

class _SearchCacheEntry {
  final PageResult<YtSearchResultItem> result;
  final DateTime cachedAt;

  _SearchCacheEntry(this.result) : cachedAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(cachedAt) > const Duration(minutes: 5);
}

/// Repository managing search requests, 5-minute memory caching, request cancellation,
/// and local SQLite search history persistence.
class SearchRepo {
  final YtClient _ytClient;
  final AppDatabase _db;

  // In-memory cache with 5-minute TTL (per Spec 7.5)
  final Map<String, _SearchCacheEntry> _cache = {};

  // Active cancel token for in-flight requests
  CancelToken? _activeCancelToken;

  SearchRepo({
    required YtClient ytClient,
    required AppDatabase db,
  })  : _ytClient = ytClient,
        _db = db;

  /// Perform search with query, filter, and optional continuation.
  /// Automatically cancels preceding pending request if any.
  Future<PageResult<YtSearchResultItem>> search(
    String query, {
    SearchFilter filter = SearchFilter.all,
    String? continuation,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty && (continuation == null || continuation.isEmpty)) {
      return const PageResult(items: []);
    }

    final cacheKey = '$trimmed|${filter.name}|${continuation ?? ''}';

    // 1. Check 5-minute cache
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.result;
    }

    // 2. Cancel previous in-flight search request
    _activeCancelToken?.cancel('New search initiated');
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    try {
      final result = await _ytClient.search(
        trimmed,
        filter: filter,
        continuation: continuation,
        cancelToken: cancelToken,
      );

      // Cache result for 5 minutes
      _cache[cacheKey] = _SearchCacheEntry(result);

      // Record to search history on non-empty initial query
      if (continuation == null || continuation.isEmpty) {
        await addHistory(trimmed);
      }

      return result;
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        // Request was cancelled by user typing faster
        rethrow;
      }
      rethrow;
    } finally {
      if (_activeCancelToken == cancelToken) {
        _activeCancelToken = null;
      }
    }
  }

  // --- Search History Management (SQLite) ---

  /// Stream recent search history ordered by most recent first (up to 20 entries)
  Stream<List<SearchHistoryData>> watchHistory({int limit = 20}) {
    return (_db.select(_db.searchHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.at)])
          ..limit(limit))
        .watch();
  }

  /// Get recent search history
  Future<List<SearchHistoryData>> getHistory({int limit = 20}) {
    return (_db.select(_db.searchHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.at)])
          ..limit(limit))
        .get();
  }

  /// Add or update a search query in history
  Future<void> addHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    await _db.into(_db.searchHistory).insertOnConflictUpdate(
          SearchHistoryCompanion(
            query: Value(trimmed),
            at: Value(DateTime.now()),
          ),
        );
  }

  /// Delete a single query from history
  Future<void> removeHistory(String query) async {
    await (_db.delete(_db.searchHistory)..where((t) => t.query.equals(query))).go();
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    await _db.delete(_db.searchHistory).go();
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _cache.clear();
  }
}
