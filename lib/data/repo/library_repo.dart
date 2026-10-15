import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../yt/yt_client.dart';
import '../yt/yt_models.dart';
import '../yt/innertube_parser.dart';

/// Repository responsible for Library playlists, tracks, pagination, and local caching
class LibraryRepo {
  final AppDatabase db;
  final YtClient ytClient;

  LibraryRepo({required this.db, required this.ytClient});

  // --- PLAYLISTS ---

  /// Watch local playlists cached in database
  Stream<List<Playlist>> watchLocalPlaylists() {
    return (db.select(db.playlists)
          ..orderBy([(p) => OrderingTerm.asc(p.title)]))
        .watch();
  }

  /// Fetch library playlists from YouTube Music InnerTube and sync to local DB
  Future<PageResult<YtPlaylist>> fetchLibraryPlaylists({String? continuation}) async {
    final page = await ytClient.getLibraryPlaylistsPage(continuation: continuation);

    // Cache playlists into SQLite
    await db.transaction(() async {
      for (final p in page.items) {
        await db.into(db.playlists).insertOnConflictUpdate(
              PlaylistsCompanion(
                id: Value(p.id),
                title: Value(p.title),
                thumbUrl: Value(p.thumbUrl),
                owner: Value(p.owner),
                trackCount: Value(p.trackCount),
                syncedAt: Value(DateTime.now()),
                source: const Value('youtube'),
              ),
            );
      }
    });

    return page;
  }

  // --- PLAYLIST TRACKS ---

  /// Watch tracks for a playlist from local database
  Stream<List<Track>> watchPlaylistTracks(String playlistId) {
    final query = db.select(db.playlistTracks).join([
      innerJoin(
        db.tracks,
        db.tracks.videoId.equalsExp(db.playlistTracks.videoId),
      ),
    ])
      ..where(db.playlistTracks.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(db.playlistTracks.position)]);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(db.tracks)).toList();
    });
  }

  /// Fetch playlist tracks from YouTube Music InnerTube with continuation and cache locally
  Future<PageResult<YtTrack>> fetchPlaylistTracks(
    String playlistId, {
    String? continuation,
    int startPosition = 0,
  }) async {
    final page = await ytClient.getPlaylistTracksPage(
      playlistId,
      continuation: continuation,
    );

    await db.transaction(() async {
      // If first page, update playlist title / thumbnail if provided
      if (continuation == null) {
        if (page.title != null || page.thumbUrl != null) {
          await (db.update(db.playlists)..where((p) => p.id.equals(playlistId)))
              .write(
            PlaylistsCompanion(
              title: page.title != null ? Value(page.title!) : const Value.absent(),
              thumbUrl: page.thumbUrl != null ? Value(page.thumbUrl!) : const Value.absent(),
              syncedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      var currentPos = startPosition;
      for (final t in page.items) {
        // Upsert track
        await db.into(db.tracks).insertOnConflictUpdate(
              TracksCompanion(
                videoId: Value(t.videoId),
                title: Value(t.title),
                artists: Value(t.artists.join(', ')),
                album: Value(t.album),
                durationMs: Value(t.durationMs),
                thumbUrl: Value(t.thumbUrl),
                isPlayable: Value(t.isPlayable),
              ),
            );

        // Upsert playlist_tracks mapping
        await db.into(db.playlistTracks).insertOnConflictUpdate(
              PlaylistTracksCompanion(
                playlistId: Value(playlistId),
                position: Value(currentPos),
                videoId: Value(t.videoId),
                setVideoId: Value(t.setVideoId),
              ),
            );
        currentPos++;
      }
    });

    return page;
  }

  /// Get single playlist metadata from DB
  Future<Playlist?> getPlaylist(String id) async {
    return (db.select(db.playlists)..where((p) => p.id.equals(id))).getSingleOrNull();
  }
}
