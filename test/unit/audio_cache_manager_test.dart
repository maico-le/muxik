import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:musical/data/db/app_database.dart';
import 'package:musical/audio/audio_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Milestone 8 - AudioCacheManager (LRU Disk Cache) Tests', () {
    late AppDatabase db;
    late Directory tempCacheDir;
    late AudioCacheManager cacheManager;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      tempCacheDir = await Directory.systemTemp.createTemp('musical_cache_test_');
      cacheManager = AudioCacheManager(
        db: db,
        customCacheDir: tempCacheDir,
        maxCacheMb: 1, // 1 MB limit for easy testing of LRU
      );
    });

    tearDown(() async {
      await db.close();
      if (await tempCacheDir.exists()) {
        await tempCacheDir.delete(recursive: true);
      }
    });

    test('getFilePath produces deterministic safe filenames', () async {
      final path = await cacheManager.getFilePath('dQw4w9WgXcQ', 251);
      expect(path, contains('dQw4w9WgXcQ_251.audio'));
    });

    test('getCachedFile returns null for missing or empty files and removes stale records', () async {
      final nonExistent = await cacheManager.getCachedFile('unknown', 251);
      expect(nonExistent, isNull);

      // Register non-existent file path
      await db.into(db.cacheIndex).insert(
            CacheIndexCompanion.insert(
              videoId: 'ghost_id',
              itag: 251,
              path: '${tempCacheDir.path}/ghost.audio',
              bytes: 1000,
            ),
          );

      final ghostFile = await cacheManager.getCachedFile('ghost_id', 251);
      expect(ghostFile, isNull);

      // Stale record should be cleaned from DB
      final records = await db.select(db.cacheIndex).get();
      expect(records, isEmpty);
    });

    test('registerCacheEntry and getCachedFile successfully cache and touch track', () async {
      final testFile = File('${tempCacheDir.path}/track1_250.audio');
      await testFile.writeAsBytes(List.filled(5000, 42));

      await cacheManager.registerCacheEntry('track1', 250, testFile.path, 5000);

      final cached = await cacheManager.getCachedFile('track1', 250);
      expect(cached, isNotNull);
      expect(await cached!.length(), equals(5000));

      final totalBytes = await cacheManager.getTotalCacheBytes();
      expect(totalBytes, equals(5000));
    });

    test('LRU Eviction deletes oldest accessed files when exceeding maxCacheBytes', () async {
      // 1 MB = 1,048,576 bytes
      // Create 3 files of 400KB each (Total = 1.2 MB > 1 MB limit)
      final file1 = File('${tempCacheDir.path}/track_old_250.audio');
      await file1.writeAsBytes(List.filled(400 * 1024, 1));

      final file2 = File('${tempCacheDir.path}/track_mid_250.audio');
      await file2.writeAsBytes(List.filled(400 * 1024, 2));

      final file3 = File('${tempCacheDir.path}/track_new_250.audio');
      await file3.writeAsBytes(List.filled(400 * 1024, 3));

      // Register file 1 (oldest)
      await db.into(db.cacheIndex).insert(
            CacheIndexCompanion.insert(
              videoId: 'track_old',
              itag: 250,
              path: file1.path,
              bytes: 400 * 1024,
              lastAccess: Value(DateTime.now().subtract(const Duration(hours: 3))),
            ),
          );

      // Register file 2 (middle)
      await db.into(db.cacheIndex).insert(
            CacheIndexCompanion.insert(
              videoId: 'track_mid',
              itag: 250,
              path: file2.path,
              bytes: 400 * 1024,
              lastAccess: Value(DateTime.now().subtract(const Duration(hours: 1))),
            ),
          );

      // Register file 3 (newest, triggers evictIfNeeded)
      await cacheManager.registerCacheEntry('track_new', 250, file3.path, 400 * 1024);

      // track_old should have been evicted from disk and db!
      expect(await file1.exists(), isFalse);
      expect(await file2.exists(), isTrue);
      expect(await file3.exists(), isTrue);

      final remaining = await db.select(db.cacheIndex).get();
      expect(remaining.length, equals(2));
      expect(remaining.any((r) => r.videoId == 'track_old'), isFalse);
      expect(remaining.any((r) => r.videoId == 'track_mid'), isTrue);
      expect(remaining.any((r) => r.videoId == 'track_new'), isTrue);
    });

    test('clearCache purges all files on disk and removes all database records', () async {
      final file1 = File('${tempCacheDir.path}/t1.audio');
      await file1.writeAsBytes([1, 2, 3]);
      await cacheManager.registerCacheEntry('t1', 250, file1.path, 3);

      final file2 = File('${tempCacheDir.path}/t2.audio');
      await file2.writeAsBytes([4, 5, 6]);
      await cacheManager.registerCacheEntry('t2', 250, file2.path, 3);

      expect(await cacheManager.getTotalCacheBytes(), equals(6));

      await cacheManager.clearCache();

      expect(await cacheManager.getTotalCacheBytes(), equals(0));
      expect(await file1.exists(), isFalse);
      expect(await file2.exists(), isFalse);
      final records = await db.select(db.cacheIndex).get();
      expect(records, isEmpty);
    });
  });
}
