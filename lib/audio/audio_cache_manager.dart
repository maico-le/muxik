import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/db/app_database.dart';

/// LRU Disk Audio Cache Manager indexing downloaded streams in SQLite
class AudioCacheManager extends ChangeNotifier {
  final AppDatabase _db;
  final Directory? _customCacheDir;
  int _maxCacheMb;

  AudioCacheManager({
    required AppDatabase db,
    Directory? customCacheDir,
    int maxCacheMb = 500,
  })  : _db = db,
        _customCacheDir = customCacheDir,
        _maxCacheMb = maxCacheMb;

  int get maxCacheMb => _maxCacheMb;
  int get maxCacheBytes => _maxCacheMb * 1024 * 1024;

  /// Get audio cache directory
  Future<Directory> getCacheDir() async {
    if (_customCacheDir != null) {
      if (!await _customCacheDir.exists()) {
        await _customCacheDir.create(recursive: true);
      }
      return _customCacheDir;
    }

    final baseDir = await getApplicationSupportDirectory();
    final cacheDir = Directory(p.join(baseDir.path, 'audio_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Get deterministic path for videoId + itag
  Future<String> getFilePath(String videoId, int itag) async {
    final dir = await getCacheDir();
    // Sanitize videoId for filename
    final safeId = videoId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return p.join(dir.path, '${safeId}_$itag.audio');
  }

  /// Check if track is cached and file exists
  Future<File?> getCachedFile(String videoId, int itag) async {
    final entry = await (_db.select(_db.cacheIndex)
          ..where((c) => c.videoId.equals(videoId) & c.itag.equals(itag)))
        .getSingleOrNull();

    if (entry != null) {
      final file = File(entry.path);
      if (await file.exists() && (await file.length()) > 0) {
        // Touch last access time
        await (_db.update(_db.cacheIndex)
              ..where((c) => c.videoId.equals(videoId) & c.itag.equals(itag)))
            .write(CacheIndexCompanion(lastAccess: Value(DateTime.now())));
        return file;
      } else {
        // File is missing on disk, remove stale record
        await (_db.delete(_db.cacheIndex)
              ..where((c) => c.videoId.equals(videoId) & c.itag.equals(itag)))
            .go();
      }
    }

    // Also check if file exists on disk even if not indexed
    final path = await getFilePath(videoId, itag);
    final file = File(path);
    if (await file.exists()) {
      final length = await file.length();
      if (length > 0) {
        await registerCacheEntry(videoId, itag, path, length);
        return file;
      }
    }

    return null;
  }

  /// Register or update a cache entry in database
  Future<void> registerCacheEntry(
    String videoId,
    int itag,
    String path,
    int bytes,
  ) async {
    await _db.into(_db.cacheIndex).insertOnConflictUpdate(
          CacheIndexCompanion(
            videoId: Value(videoId),
            itag: Value(itag),
            path: Value(path),
            bytes: Value(bytes),
            lastAccess: Value(DateTime.now()),
          ),
        );

    await evictIfNeeded();
    notifyListeners();
  }

  /// Calculate total cached bytes
  Future<int> getTotalCacheBytes() async {
    final entries = await _db.select(_db.cacheIndex).get();
    return entries.fold<int>(0, (sum, e) => sum + e.bytes);
  }

  /// LRU Eviction: Remove oldest accessed entries when exceeding limit
  Future<int> evictIfNeeded() async {
    final totalBytes = await getTotalCacheBytes();
    if (totalBytes <= maxCacheBytes) return 0;

    int bytesToFree = totalBytes - maxCacheBytes;
    int freedBytes = 0;

    // Order by oldest access first
    final entries = await (_db.select(_db.cacheIndex)
          ..orderBy([(c) => OrderingTerm.asc(c.lastAccess)]))
        .get();

    for (final entry in entries) {
      if (freedBytes >= bytesToFree) break;

      final file = File(entry.path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      await (_db.delete(_db.cacheIndex)
            ..where((c) => c.videoId.equals(entry.videoId) & c.itag.equals(entry.itag)))
          .go();

      freedBytes += entry.bytes;
    }

    notifyListeners();
    return freedBytes;
  }

  /// Delete all cached audio files and purge database index
  Future<void> clearCache() async {
    final entries = await _db.select(_db.cacheIndex).get();
    for (final entry in entries) {
      final file = File(entry.path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    await _db.delete(_db.cacheIndex).go();

    // Clean any orphaned files in directory
    final dir = await getCacheDir();
    if (await dir.exists()) {
      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File) {
          try {
            entity.deleteSync();
          } catch (_) {}
        }
      }
    }

    notifyListeners();
  }

  /// Update max cache size in MB
  Future<void> setMaxCacheMb(int mb) async {
    _maxCacheMb = mb;
    await evictIfNeeded();
    notifyListeners();
  }
}
