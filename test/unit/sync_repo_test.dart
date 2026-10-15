import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/yt/yt_models.dart';
import 'package:musical/data/repo/sync_repo.dart';

class MockYtClient extends Mock implements YtClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Milestone 7: SyncRepo Offline Mutations & Sync Engine Tests', () {
    late AppDatabase db;
    late MockYtClient mockYtClient;
    late SyncRepo syncRepo;

    const sampleTrack1 = YtTrack(
      videoId: 'v_01',
      title: 'Track One',
      artists: ['Artist A'],
      album: 'Album A',
      durationMs: 180000,
      thumbUrl: 'https://example.com/1.jpg',
      setVideoId: 'set_01',
    );

    const sampleTrack2 = YtTrack(
      videoId: 'v_02',
      title: 'Track Two',
      artists: ['Artist B'],
      album: 'Album B',
      durationMs: 210000,
      thumbUrl: 'https://example.com/2.jpg',
      setVideoId: 'set_02',
    );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockYtClient = MockYtClient();
      syncRepo = SyncRepo(db: db, ytClient: mockYtClient);

      // Default mock responses
      when(() => mockYtClient.createPlaylist(
            any(),
            description: any(named: 'description'),
            privacyStatus: any(named: 'privacyStatus'),
            videoIds: any(named: 'videoIds'),
          )).thenAnswer((_) async => 'VL_YOUTUBE_PLAYLIST_REAL_ID');

      when(() => mockYtClient.deletePlaylist(any())).thenAnswer((_) async => true);
      when(() => mockYtClient.editPlaylist(any(), any())).thenAnswer((_) async => {'status': 'STATUS_SUCCEEDED'});
    });

    tearDown(() async {
      await db.close();
    });

    test('createPlaylist inserts local playlist and queues pending op', () async {
      final tempId = await syncRepo.createPlaylist('My Retro Chiptunes', privacyStatus: 'PRIVATE');

      expect(tempId.startsWith('local_'), isTrue);

      final localPlaylists = await db.select(db.playlists).get();
      expect(localPlaylists.length, equals(1));
      expect(localPlaylists.first.id, equals(tempId));
      expect(localPlaylists.first.title, equals('My Retro Chiptunes'));
      expect(localPlaylists.first.source, equals('local'));

      final pendingOps = await db.select(db.pendingOps).get();
      expect(pendingOps.length, equals(1));
      expect(pendingOps.first.type, equals('create_playlist'));
    });

    test('addTrackToPlaylist adds track, creates mapping and increments trackCount', () async {
      final plId = await syncRepo.createPlaylist('Favorites');

      await syncRepo.addTrackToPlaylist(plId, sampleTrack1);
      await syncRepo.addTrackToPlaylist(plId, sampleTrack2);

      final tracks = await db.select(db.tracks).get();
      expect(tracks.length, equals(2));

      final mappings = await (db.select(db.playlistTracks)..where((t) => t.playlistId.equals(plId))).get();
      expect(mappings.length, equals(2));
      expect(mappings[0].position, equals(0));
      expect(mappings[0].videoId, equals('v_01'));
      expect(mappings[1].position, equals(1));
      expect(mappings[1].videoId, equals('v_02'));

      final pl = await (db.select(db.playlists)..where((p) => p.id.equals(plId))).getSingle();
      expect(pl.trackCount, equals(2));
    });

    test('removeTrackFromPlaylist removes mapping and decrements trackCount', () async {
      final plId = await syncRepo.createPlaylist('Temp PL');
      await syncRepo.addTrackToPlaylist(plId, sampleTrack1);
      await syncRepo.addTrackToPlaylist(plId, sampleTrack2);

      await syncRepo.removeTrackFromPlaylist(plId, sampleTrack1.videoId, position: 0);

      final remaining = await (db.select(db.playlistTracks)..where((t) => t.playlistId.equals(plId))).get();
      expect(remaining.length, equals(1));
      expect(remaining.first.videoId, equals('v_02'));

      final pl = await (db.select(db.playlists)..where((p) => p.id.equals(plId))).getSingle();
      expect(pl.trackCount, equals(1));
    });

    test('reorderTrack updates track positions', () async {
      final plId = await syncRepo.createPlaylist('Reorder PL');
      await syncRepo.addTrackToPlaylist(plId, sampleTrack1);
      await syncRepo.addTrackToPlaylist(plId, sampleTrack2);

      // Reorder track 0 to position 1
      await syncRepo.reorderTrack(plId, 0, 1);

      final mappings = await (db.select(db.playlistTracks)
            ..where((t) => t.playlistId.equals(plId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

      expect(mappings[0].videoId, equals('v_02'));
      expect(mappings[1].videoId, equals('v_01'));
    });

    test('processPendingOps pushes operations to InnerTube and clears queue', () async {
      // Create playlist on remote YouTube
      await syncRepo.createPlaylist('Online Sync Playlist');

      await syncRepo.processPendingOps();

      verify(() => mockYtClient.createPlaylist(
            'Online Sync Playlist',
            description: any(named: 'description'),
            privacyStatus: any(named: 'privacyStatus'),
          )).called(1);

      // Pending ops queue should be completely empty after successful push
      final pendingOps = await db.select(db.pendingOps).get();
      expect(pendingOps, isEmpty);

      // Playlist ID in SQLite should be updated to YouTube real ID
      final updatedPlaylists = await db.select(db.playlists).get();
      expect(updatedPlaylists.first.id, equals('VL_YOUTUBE_PLAYLIST_REAL_ID'));
      expect(updatedPlaylists.first.source, equals('youtube'));
    });

    test('getRandomTracks retrieves non-repeating random subset of tracks', () async {
      final plId = await syncRepo.createPlaylist('All Songs');
      await syncRepo.addTrackToPlaylist(plId, sampleTrack1);
      await syncRepo.addTrackToPlaylist(plId, sampleTrack2);

      final randomTracks = await syncRepo.getRandomTracks(playlistId: plId, count: 50);

      expect(randomTracks.length, equals(2));
      final ids = randomTracks.map((t) => t.videoId).toSet();
      expect(ids.contains('v_01'), isTrue);
      expect(ids.contains('v_02'), isTrue);
    });

    test('saveRandomQueueAsPlaylist creates a playlist populated with given tracks', () async {
      final savedId = await syncRepo.saveRandomQueueAsPlaylist(
        'My Saved Random Playlist',
        [sampleTrack1, sampleTrack2],
      );

      final pl = await (db.select(db.playlists)..where((p) => p.id.equals(savedId))).getSingle();
      expect(pl.title, equals('My Saved Random Playlist'));
      expect(pl.trackCount, equals(2));
    });
  });
}
