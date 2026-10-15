import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/yt/innertube_parser.dart';
import 'package:musical/data/repo/library_repo.dart';

class MockYtClient extends Mock implements YtClient {}

void main() {
  group('LibraryRepo Tests', () {
    late AppDatabase db;
    late MockYtClient mockYtClient;
    late LibraryRepo libraryRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockYtClient = MockYtClient();
      libraryRepo = LibraryRepo(db: db, ytClient: mockYtClient);
    });

    tearDown(() async {
      await db.close();
    });

    test('fetchLibraryPlaylists saves playlists to SQLite DB and streams updates', () async {
      final jsonStr = File('test/fixtures/library_playlists.json').readAsStringSync();
      final samplePage = InnerTubeParser.parseLibraryPlaylists(jsonStr);

      when(() => mockYtClient.getLibraryPlaylistsPage(continuation: any(named: 'continuation')))
          .thenAnswer((_) async => samplePage);

      // Act
      final result = await libraryRepo.fetchLibraryPlaylists();

      // Assert
      expect(result.items.length, equals(2));

      final cachedPlaylists = await db.select(db.playlists).get();
      expect(cachedPlaylists.length, equals(2));
      expect(cachedPlaylists.first.id, equals('PLretro_pixel_chiptune_01'));
      expect(cachedPlaylists.first.title, equals('Pixel Chiptune Hits'));
      expect(cachedPlaylists.first.trackCount, equals(42));
    });

    test('fetchPlaylistTracks saves tracks and playlist_tracks mapping to SQLite', () async {
      final jsonStr = File('test/fixtures/playlist_tracks.json').readAsStringSync();
      final samplePage = InnerTubeParser.parsePlaylistTracks(jsonStr);

      when(() => mockYtClient.getPlaylistTracksPage(
            'PLretro_pixel_chiptune_01',
            continuation: any(named: 'continuation'),
          )).thenAnswer((_) async => samplePage);

      // Act
      final result = await libraryRepo.fetchPlaylistTracks('PLretro_pixel_chiptune_01');

      // Assert
      expect(result.items.length, equals(2));

      final cachedTracks = await db.select(db.tracks).get();
      expect(cachedTracks.length, equals(2));
      expect(cachedTracks.first.videoId, equals('dQw4w9WgXcQ'));
      expect(cachedTracks.first.title, equals('Never Gonna Give You Up'));
      expect(cachedTracks.first.artists, equals('Rick Astley'));

      // Verify playlist-to-track relation
      final mappings = await (db.select(db.playlistTracks)
            ..where((m) => m.playlistId.equals('PLretro_pixel_chiptune_01')))
          .get();
      expect(mappings.length, equals(2));
      expect(mappings[0].position, equals(0));
      expect(mappings[0].videoId, equals('dQw4w9WgXcQ'));
      expect(mappings[1].position, equals(1));
      expect(mappings[1].videoId, equals('9bZkp7q19f0'));
    });
  });
}
