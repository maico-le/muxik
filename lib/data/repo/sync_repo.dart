import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../yt/yt_client.dart';
import '../yt/yt_models.dart';

/// Repository responsible for offline-first playlist mutations, pending operations queue,
/// sync retry with exponential backoff, and Random Shuffle Bag.
class SyncRepo {
  final AppDatabase _db;
  final YtClient _ytClient;
  final bool autoSync;
  bool _isProcessing = false;

  SyncRepo({
    required AppDatabase db,
    required YtClient ytClient,
    this.autoSync = false,
  })  : _db = db,
        _ytClient = ytClient;

  // --- Stream Pending Ops Count for UI Badges ---

  Stream<int> watchPendingOpsCount() {
    return _db.select(_db.pendingOps).watch().map((ops) => ops.length);
  }

  // --- 1. Offline-First Playlist Mutations (Spec 6.1 & 6.4) ---

  /// Create a new playlist (optimistic local insert + enqueued sync)
  Future<String> createPlaylist(
    String title, {
    String? description,
    String privacyStatus = 'PRIVATE',
  }) async {
    final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    // 1. Optimistic insert in local database
    await _db.into(_db.playlists).insert(
          PlaylistsCompanion(
            id: Value(tempId),
            title: Value(title),
            thumbUrl: const Value(''),
            trackCount: const Value(0),
            syncedAt: Value(DateTime.now()),
            source: const Value('local'),
          ),
        );

    // 2. Enqueue pending op
    final payload = {
      'tempId': tempId,
      'title': title,
      'description': description,
      'privacyStatus': privacyStatus,
    };

    await _enqueueOp('create_playlist', payload);

    // 3. Trigger async sync attempt
    if (autoSync) unawaited(processPendingOps());

    return tempId;
  }

  /// Delete a playlist (optimistic local delete + enqueued sync)
  Future<void> deletePlaylist(String playlistId) async {
    // 1. Delete from local DB
    await _db.transaction(() async {
      await (_db.delete(_db.playlistTracks)..where((t) => t.playlistId.equals(playlistId))).go();
      await (_db.delete(_db.playlists)..where((p) => p.id.equals(playlistId))).go();
    });

    // 2. If it was purely local and never synced, remove its pending create op
    if (playlistId.startsWith('local_')) {
      final pendingCreates = await (_db.select(_db.pendingOps)
            ..where((o) => o.type.equals('create_playlist')))
          .get();
      for (final op in pendingCreates) {
        final data = jsonDecode(op.payloadJson) as Map<String, dynamic>;
        if (data['tempId'] == playlistId) {
          await (_db.delete(_db.pendingOps)..where((o) => o.id.equals(op.id))).go();
        }
      }
      return;
    }

    // 3. Enqueue pending op for YouTube
    await _enqueueOp('delete_playlist', {'playlistId': playlistId});
    if (autoSync) unawaited(processPendingOps());
  }

  /// Rename a playlist
  Future<void> renamePlaylist(String playlistId, String newTitle) async {
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(
        title: Value(newTitle),
        syncedAt: Value(DateTime.now()),
      ),
    );

    if (!playlistId.startsWith('local_')) {
      await _enqueueOp('rename_playlist', {
        'playlistId': playlistId,
        'newTitle': newTitle,
      });
      if (autoSync) unawaited(processPendingOps());
    }
  }

  /// Add a track to playlist
  Future<void> addTrackToPlaylist(String playlistId, YtTrack track) async {
    await _db.transaction(() async {
      // 1. Upsert track in tracks table
      await _db.into(_db.tracks).insertOnConflictUpdate(
            TracksCompanion(
              videoId: Value(track.videoId),
              title: Value(track.title),
              artists: Value(track.artists.join(', ')),
              album: Value(track.album),
              durationMs: Value(track.durationMs),
              thumbUrl: Value(track.thumbUrl),
              isPlayable: Value(track.isPlayable),
            ),
          );

      // 2. Find max position
      final tracksInPlaylist = await (_db.select(_db.playlistTracks)
            ..where((t) => t.playlistId.equals(playlistId))
            ..orderBy([(t) => OrderingTerm.desc(t.position)]))
          .get();
      final nextPos = tracksInPlaylist.isEmpty ? 0 : tracksInPlaylist.first.position + 1;

      // 3. Insert playlist_tracks mapping
      await _db.into(_db.playlistTracks).insert(
            PlaylistTracksCompanion(
              playlistId: Value(playlistId),
              position: Value(nextPos),
              videoId: Value(track.videoId),
              setVideoId: Value(track.setVideoId),
            ),
          );

      // 4. Increment trackCount on playlist
      final pl = await (_db.select(_db.playlists)..where((p) => p.id.equals(playlistId))).getSingleOrNull();
      if (pl != null) {
        await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
          PlaylistsCompanion(
            trackCount: Value(pl.trackCount + 1),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }
    });

    if (!playlistId.startsWith('local_')) {
      await _enqueueOp('add_track', {
        'playlistId': playlistId,
        'videoId': track.videoId,
      });
      if (autoSync) unawaited(processPendingOps());
    }
  }

  /// Remove a track from playlist
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String videoId, {
    String? setVideoId,
    required int position,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(_db.playlistTracks)
            ..where((t) => t.playlistId.equals(playlistId) & t.position.equals(position)))
          .go();

      // Decrement playlist trackCount
      final pl = await (_db.select(_db.playlists)..where((p) => p.id.equals(playlistId))).getSingleOrNull();
      if (pl != null && pl.trackCount > 0) {
        await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
          PlaylistsCompanion(
            trackCount: Value(pl.trackCount - 1),
            syncedAt: Value(DateTime.now()),
          ),
        );
      }
    });

    if (!playlistId.startsWith('local_')) {
      await _enqueueOp('remove_track', {
        'playlistId': playlistId,
        'videoId': videoId,
        'setVideoId': setVideoId,
      });
      if (autoSync) unawaited(processPendingOps());
    }
  }

  /// Reorder a track in playlist
  Future<void> reorderTrack(String playlistId, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final tracks = await (_db.select(_db.playlistTracks)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    if (oldIndex < 0 || oldIndex >= tracks.length || newIndex < 0 || newIndex >= tracks.length) {
      return;
    }

    final moved = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, moved);

    await _db.transaction(() async {
      // Phase 1: Set temporary negative positions to prevent primaryKey (playlistId, position) collisions
      for (var i = 0; i < tracks.length; i++) {
        await (_db.update(_db.playlistTracks)
              ..where((t) =>
                  t.playlistId.equals(playlistId) &
                  t.videoId.equals(tracks[i].videoId) &
                  t.position.equals(tracks[i].position)))
            .write(PlaylistTracksCompanion(position: Value(-(i + 1))));
      }

      // Phase 2: Set final zero-based positions
      for (var i = 0; i < tracks.length; i++) {
        await (_db.update(_db.playlistTracks)
              ..where((t) =>
                  t.playlistId.equals(playlistId) &
                  t.videoId.equals(tracks[i].videoId) &
                  t.position.equals(-(i + 1))))
            .write(PlaylistTracksCompanion(position: Value(i)));
      }
    });

    if (!playlistId.startsWith('local_')) {
      final predecessorSetVideoId = newIndex > 0 ? tracks[newIndex - 1].setVideoId : null;
      await _enqueueOp('reorder_track', {
        'playlistId': playlistId,
        'setVideoId': moved.setVideoId,
        'predecessorSetVideoId': predecessorSetVideoId,
      });
      if (autoSync) unawaited(processPendingOps());
    }
  }

  // --- 2. Random Shuffle Bag ("Trộn ngẫu nhiên" - Spec 6.1) ---

  /// Extract N random tracks (default 50) from synced DB or selected playlist
  Future<List<YtTrack>> getRandomTracks({String? playlistId, int count = 50}) async {
    List<Track> candidateTracks;

    if (playlistId != null && playlistId.isNotEmpty) {
      final query = _db.select(_db.playlistTracks).join([
        innerJoin(_db.tracks, _db.tracks.videoId.equalsExp(_db.playlistTracks.videoId)),
      ])..where(_db.playlistTracks.playlistId.equals(playlistId));

      final rows = await query.get();
      candidateTracks = rows.map((r) => r.readTable(_db.tracks)).toList();
    } else {
      // From all local synced tracks across library
      candidateTracks = await _db.select(_db.tracks).get();
    }

    if (candidateTracks.isEmpty) return [];

    // Shuffle using Fisher-Yates
    final list = List<Track>.from(candidateTracks);
    list.shuffle(Random.secure());

    final selected = list.take(count).toList();

    return selected
        .map((t) => YtTrack(
              videoId: t.videoId,
              title: t.title,
              artists: t.artists.split(', ').where((a) => a.isNotEmpty).toList(),
              album: t.album,
              durationMs: t.durationMs,
              thumbUrl: t.thumbUrl ?? '',
              isPlayable: t.isPlayable,
            ))
        .toList();
  }

  /// Option "Lưu thành playlist mới" from random queue
  Future<String> saveRandomQueueAsPlaylist(String title, List<YtTrack> tracks) async {
    final playlistId = await createPlaylist(title);
    for (final track in tracks) {
      await addTrackToPlaylist(playlistId, track);
    }
    return playlistId;
  }

  // --- 3. Pending Operations Processor (Sync Engine) ---

  Future<void> _enqueueOp(String type, Map<String, dynamic> payload) async {
    await _db.into(_db.pendingOps).insert(
          PendingOpsCompanion(
            type: Value(type),
            payloadJson: Value(jsonEncode(payload)),
            createdAt: Value(DateTime.now()),
            attempts: const Value(0),
          ),
        );
  }

  /// Process pending operations with exponential backoff
  Future<void> processPendingOps() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final ops = await (_db.select(_db.pendingOps)
            ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
          .get();

      for (final op in ops) {
        if (op.attempts >= 5) {
          // Log conflict / maximum retry reached per Spec 6.1
          continue;
        }

        try {
          final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;

          switch (op.type) {
            case 'create_playlist':
              final title = payload['title'] as String;
              final desc = payload['description'] as String?;
              final privacy = payload['privacyStatus'] as String? ?? 'PRIVATE';
              final tempId = payload['tempId'] as String;

              final realId = await _ytClient.createPlaylist(
                title,
                description: desc,
                privacyStatus: privacy,
              );

              // Update local playlist ID with real YouTube playlist ID
              await _db.transaction(() async {
                await (_db.update(_db.playlists)..where((p) => p.id.equals(tempId)))
                    .write(PlaylistsCompanion(
                  id: Value(realId),
                  source: const Value('youtube'),
                ));
                await (_db.update(_db.playlistTracks)..where((t) => t.playlistId.equals(tempId)))
                    .write(PlaylistTracksCompanion(playlistId: Value(realId)));
              });

              // Also update any subsequent pending ops that reference tempId
              final subsequentOps = await _db.select(_db.pendingOps).get();
              for (final subOp in subsequentOps) {
                if (subOp.id != op.id && subOp.payloadJson.contains(tempId)) {
                  final updatedPayload = subOp.payloadJson.replaceAll(tempId, realId);
                  await (_db.update(_db.pendingOps)..where((o) => o.id.equals(subOp.id)))
                      .write(PendingOpsCompanion(payloadJson: Value(updatedPayload)));
                }
              }
              break;

            case 'delete_playlist':
              final playlistId = payload['playlistId'] as String;
              await _ytClient.deletePlaylist(playlistId);
              break;

            case 'rename_playlist':
              final playlistId = payload['playlistId'] as String;
              final newTitle = payload['newTitle'] as String;
              await _ytClient.editPlaylist(playlistId, [
                {'action': 'ACTION_SET_PLAYLIST_NAME', 'playlistName': newTitle}
              ]);
              break;

            case 'add_track':
              final playlistId = payload['playlistId'] as String;
              final videoId = payload['videoId'] as String;
              await _ytClient.editPlaylist(playlistId, [
                {'action': 'ACTION_ADD_VIDEO', 'addedVideoId': videoId}
              ]);
              break;

            case 'remove_track':
              final playlistId = payload['playlistId'] as String;
              final setVideoId = payload['setVideoId'] as String?;
              if (setVideoId != null && setVideoId.isNotEmpty) {
                await _ytClient.editPlaylist(playlistId, [
                  {'action': 'ACTION_REMOVE_VIDEO_BY_POST_ID', 'setVideoId': setVideoId}
                ]);
              }
              break;

            case 'reorder_track':
              final playlistId = payload['playlistId'] as String;
              final setVideoId = payload['setVideoId'] as String?;
              final predecessor = payload['predecessorSetVideoId'] as String?;
              if (setVideoId != null && setVideoId.isNotEmpty) {
                await _ytClient.editPlaylist(playlistId, [
                  {
                    'action': 'ACTION_MOVE_VIDEO_BEFORE',
                    'setVideoId': setVideoId,
                    if (predecessor != null) 'movedSetVideoIdPredecessor': predecessor,
                  }
                ]);
              }
              break;
          }

          // Operation succeeded: delete from pending_ops
          await (_db.delete(_db.pendingOps)..where((o) => o.id.equals(op.id))).go();
        } catch (e) {
          // Record failure and increment attempts with exponential backoff
          await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id))).write(
            PendingOpsCompanion(
              attempts: Value(op.attempts + 1),
              lastError: Value(e.toString()),
            ),
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}
